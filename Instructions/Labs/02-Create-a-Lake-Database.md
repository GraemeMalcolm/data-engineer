---
lab:
    title: 'Analyze data in a lake database'
    module: 'Module 2: Analyze data in a lake database'
---

# Analyze data in a lake database

Azure Synapse Analytics enables you to combine the flexibility of file storage in a data lake with the structured schema and SQL querying capabilities of a relational database through the ability to create a *lake database*. A lake database is a relational database schema defined on a data lake file store that enables data storage to be separated from the compute used to query it, while providing the benefits of a structured schema that includes support for data types, relationships, and other features typically only found in relational database systems. Essentially, the lake database "overlays" a relational schema onto files in folders in the data lake.

This lab will take approximately **60** minutes to complete.

## Before you start

You'll need an [Azure subscription](https://azure.microsoft.com/free)!

## Provision an Azure Synapse Analytics workspace

To support a lake database, you need an Azure Synapse Analytics workspace with access to data lake storage. There is no need for a dedicated SQL pool, since you can define the lake database using the built-in serverless SQL pool. Optionally, you can also use a Spark pool to work with data in the lake database.

In this exercise, you'll use a combination of a PowerShell script and an ARM template to provision an Azure Synapse Analytics workspace.

1. Sign into the [Azure portal](https://portal.azure.com).
2. Use the **[\>_]** button to the right of the search bar at the top of the page to create a new Cloud Shell in the Azure portal, selecting a ***PowerShell*** environment and creating storage if prompted. The cloud shell provides a command line interface in a pane at the bottom of the Azure portal, as shown here:

    ![Azure portal with a cloud shell pane](./images/cloud-shell.png)

    > **Note**: If you have previously created a cloud shell that uses a *Bash* environment, use the the drop-down menu at the top left of the cloud shell pane to change it to ***PowerShell***.

3. Note that you can resize the cloud shell by dragging the separator bar at the top of the pane, or by using the **&#8212;**, **&#9723;**, and **X** icons at the top right of the pane to minimize, maximize, and close the pane. For more information about using the Azure Cloud Shell, see the [Azure Cloud Shell documentation](https://docs.microsoft.com/azure/cloud-shell/overview).

4. In the PowerShell pane, enter the following command to clone this repo:

    ```
    git clone https://github.com/GraemeMalcolm/data-engineer dp-000
    ```

5. After the repo has been cloned, enter the following commands to change to the folder for this lab and run the **setup.ps1** script it contains:

    ```
    cd dp-000/Allfiles/Labs/02
    ./setup.ps1
    ```

6. When prompted, enter a suitable password to be set for your Azure Synapse SQL pool.

    > **Note**: Be sure to remember this password!

7. Wait for the script to complete - this typically takes around 10 minutes, but in some cases may take longer. While you are waiting, review the [Lake database](https://docs.microsoft.com/azure/synapse-analytics/database-designer/concepts-lake-database) and [Lake database templates](https://docs.microsoft.com/azure/synapse-analytics/database-designer/concepts-database-templates) articles in the Azure Synapse Analytics documentation.

## Create a lake database

A lake database is a type of database that you can define in your workspace, and work with using the built-in serverless SQL pool.

1. After the deployment script has completed, in the Azure portal, go to the **dp000-*xxxxxxx*** resource group that it created, and notice that this resource group contains your Synapse workspace, a Storage account for your data lake, and an Apache Spark pool.
2. Select your Synapse workspace, and in its **Overview** page, in **Open Synapse Studio** card, select **Open** to open Synapse Studio in a new browser tab; signing in if prompted.
3. On the left side of Synapse Studio, use the **&rsaquo;&rsaquo;** icon to expand the menu - this reveals the different pages within Synapse Studio that you'll use to manage resources and perform data analytics tasks.
4. On the **Data** page, view the **Linked** tab and verify that your workspace includes a link to your Azure Data Lake Storage Gen2 storage account.
5. On the **Data** page, switch back to the **Workspace** tab and note that there are no databases in your workspace.
6. In the **+** menu, select **Lake database** to open a new pane in which you can design your database schema.
7. In the **Properties** pane for the new database, change the **Name** to **RetailDB** and verify that the **Input folder** property is automatically updated to **files/RetailDB**. Leave the **Data format** as **Delimited Text** (you could also use *Parquet* format, and you can override the file format for individual tables - we'll use comma-delimited data in this exercise.)
8. At the top of the **RetailDB** pane, select **Publish** to save the database so far.

## Create a table from a database template

... *more to come* ...
