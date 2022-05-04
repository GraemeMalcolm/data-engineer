Get-ChildItem "./data/*.parquet" -File | Foreach-Object {
    write-host ""
    Write-Host $_.Name
    $folder = $_.Name.Replace(".snappy.parquet", "")
    Write-Host $folder
    $file = $_.Name.Replace($folder, "orders")
    Write-Host $file
    $blobPath = "sales/parquet/$folder/$file"
    Write-Host $blobPath
}