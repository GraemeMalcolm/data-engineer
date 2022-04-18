cls
write-host "Starting script at $(Get-Date)"

Install-Module -Name Az.Synapse

# Get ID of the current user (running this script)
$subscriptionId = (Get-AzContext).Subscription.Id
$userName = ((az ad signed-in-user show) | ConvertFrom-JSON).UserPrincipalName
write-host "User Name: $userName"
$userId = az ad signed-in-user show --query objectId -o tsv
Write-Host "User ID: $userId"


# Prompt user for a password for the SQL Database
$sqlUser = "SQLUser"
write-host ""
$sqlPassword = ""
$complexPassword = 0

while ($complexPassword -ne 1)
{
    $SqlPassword = Read-Host "Enter a password to use for the $sqlUser login.
    `The password must meet complexity requirements:
    ` - Minimum 8 characters. 
    ` - At least one upper case English letter [A-Z]
    ` - At least one lower case English letter [a-z]
    ` - At least one digit [0-9]
    ` - At least one special character (!,@,#,%,^,&,$)
    ` "

    if(($SqlPassword -cmatch '[a-z]') -and ($SqlPassword -cmatch '[A-Z]') -and ($SqlPassword -match '\d') -and ($SqlPassword.length -ge 8) -and ($SqlPassword -match '!|@|#|%|^|&|$'))
    {
        $complexPassword = 1
	    Write-Output "Password $SqlPassword accepted. Make sure you remember this!"
    }
    else
    {
        Write-Output "$SqlPassword does not meet the compexity requirements."
    }
}

# Register resource providers
Write-Host "Registering resource providers...";
Register-AzResourceProvider -ProviderNamespace Microsoft.Synapse
Register-AzResourceProvider -ProviderNamespace Microsoft.Sql
Register-AzResourceProvider -ProviderNamespace Microsoft.Storage
Register-AzResourceProvider -ProviderNamespace Microsoft.Compute

# Generate unique random suffix
[string]$suffix =  -join ((48..57) + (97..122) | Get-Random -Count 7 | % {[char]$_})
Write-Host "Your randomly-generated suffix for Azure resources is $suffix"
$resourceGroupName = "dp000-$suffix"

# Choose a random region
Write-Host "Finding an available region. This may take several minutes...";
$preferred_list = "australiaeast","centralus","southcentralus","eastus2","northeurope","southeastasia","uksouth","westeurope","westus","westus2"
$locations = Get-AzLocation | Where-Object {
    $_.Providers -contains "Microsoft.Synapse" -and
    $_.Providers -contains "Microsoft.Sql" -and
    $_.Providers -contains "Microsoft.Storage" -and
    $_.Providers -contains "Microsoft.Compute" -and
    $_.Location -in $preferred_list
}
$max_index = $locations.Count - 1
$rand = (0..$max_index) | Get-Random
$Region = $locations.Get($rand).Location

# Test for subscription Azure SQL capacity constraints in randomly selected regions
# (for some subsription types, quotas are adjusted dynamically based on capacity)
 $success = 0
 $tried_list = New-Object Collections.Generic.List[string]

 while ($success -ne 1){
    write-host "Trying $Region"
    $capability = Get-AzSqlCapability -LocationName $Region
    if($capability.Status -eq "Available")
    {
        $success = 1
        write-host "Using $Region"
    }
    else
    {
        $success = 0
        $tried_list.Add($Region)
        $locations = $locations | Where-Object {$_.Location -notin $tried_list}
        $rand = (0..$($locations.Count - 1)) | Get-Random
        $Region = $locations.Get($rand).Location
    }
}
Write-Host "Creating $resourceGroupName resource group in $Region ..."
New-AzResourceGroup -Name $resourceGroupName -Location $Region | Out-Null

# Create Synapse workspace
$synapseWorkspace = "synapse$suffix"
$sqlDatabaseName = "sql$suffix"
$adxpool = "adx$suffix"
$dataLakeAccountName = "datalake$suffix"

write-host "Creating $synapseWorkspace Synapse Analytics workspace in $resourceGroupName resource group..."
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
  -TemplateFile "setup.json" `
  -Mode Complete `
  -workspaceName $synapseWorkspace `
  -uniqueSuffix $suffix `
  -sqlDatabaseName $sqlDatabaseName `
  -sqlUser $sqlUser `
  -sqlPassword $sqlPassword `
  -adxPoolName $adxpool `
  -Force

# Pause Data Explorer pool
write-host "Pausing the $adxpool Data Explorer Pool..."
Stop-AzSynapseKustoPool -Name $adxpool -ResourceGroupName $resourceGroupName -WorkspaceName $synapseWorkspace -NoWait

# Add the current userto Admin roles
Write-Host "Granting $userName admin permissions..."
Assign-SynapseRole -WorkspaceName $synapseWorkspace -RoleId "6e4bf58a-b8e1-4cc3-bbf9-d73143322b78" -PrincipalId $userId  # Workspace Admin
Assign-SynapseRole -WorkspaceName $synapseWorkspace -RoleId "7af0c69a-a548-47d6-aea3-d00e69bd83aa" -PrincipalId $userId  # SQL Admin
Assign-SynapseRole -WorkspaceName $synapseWorkspace -RoleId "c3a6d2f1-a26f-4810-9b0f-591308d5cbf1" -PrincipalId $userId  # Apache Spark Admin

#add the permission to the datalake to workspace
$id = (Get-AzADServicePrincipal -DisplayName $synapseWorkspace).id
New-AzRoleAssignment -Objectid $id -RoleDefinitionName "Storage Blob Data Owner" -Scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Storage/storageAccounts/$dataLakeAccountName" -ErrorAction SilentlyContinue;
New-AzRoleAssignment -SignInName $userName -RoleDefinitionName "Storage Blob Data Owner" -Scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Storage/storageAccounts/$dataLakeAccountName" -ErrorAction SilentlyContinue;


# Create database
write-host "Creating the $sqlDatabaseName database..."
sqlcmd -S "$synapseWorkspace.sql.azuresynapse.net" -U $sqlUser -P $sqlPassword -d $sqlDatabaseName -I -i setup.sql

# Load data
write-host "Loading data..."
Get-ChildItem "./data/*.txt" -File | Foreach-Object {
    write-host ""
    $file = $_.FullName
    Write-Host "$file"
    $table = $_.Name.Replace(".txt","")
    bcp dbo.$table in $file -S "$synapseWorkspace.sql.azuresynapse.net" -U $sqlUser -P $sqlPassword -d $sqlDatabaseName -f $file.Replace("txt", "fmt") -q -k -E -b 5000
}

# Pause SQL Pool
write-host "Pausing the $sqlDatabaseName SQL Pool..."
Suspend-AzSynapseSqlPool -WorkspaceName $synapseWorkspace -Name $sqlDatabaseName -AsJob

write-host "Script completed at $(Get-Date)"