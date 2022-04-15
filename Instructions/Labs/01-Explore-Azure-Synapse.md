---
lab:
    title: 'Explore Data with Azure Synapse Analytics'
    module: 'Module 1: Get Started with Data Engineering'
---

# Explore Data with Azure Synapse Analytics

Azure Synapse Analytics provides a single, consolidated data analytics platform for end-to end data analytics. In this lab, you'll explore various ways to ingest and explore data. This lab is designed as a high-level overview of the various core capabilities of Azure Synapse Analytics; which you'll explore in more depth in later labs.

This lab will take approximately **90** minutes to complete.

## Before you start

You'll need an [Azure subscription](https://azure.microsoft.com/free)!

## Provision an Azure Synapse Analytics workspace

An Azure Synapse Analytics *workspace* provides a central point for managing data and data processing runtimes. You can provision a workspace using the interactive interface in the Azure portal, or you can deploy a workspace and resources within it by using a script or template. In most production scenarios, it's best to automate provisioning with scripts and templates so that you can incorporate resource deployment into a repeatable development and operations (*DevOps*) process.

In this exercise, you'll use a combination of a PowerShell script and an ARM template to provision Azure Synapse Analytics.

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
    cd dp-000/Allfiles/Labs/01
    ./setup.ps1
    ```

6. When prompted, enter a suitable password to be set for your Azure Synapse SQL pool.

    > **Note**: Be sure to remember this password!

7. Wait for the script to complete - this typically takes around 15 minutes, but in some cases may take longer. While you are waiting, review the [What is Azure Synapse Analytics?](https://docs.microsoft.com/azure/synapse-analytics/overview-what-is) article in the Azure Synapse Analytics documentation.

## Explore Synapse Studio

*Synapse Studio* is a web-based portal in which you can manage and work with the resources in your Azure Synapse Analytics workspace.