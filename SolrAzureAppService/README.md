# Setup Solr in an Azure App Service

## Introduction
It is possible to install Solr as a (managed) App Service in Azure. This can be preferable to custom Virtual Machines as they require much more setup and running maintenance (such as patch-management) and, not least, are more expensive to run.

Inspired by http://www.ilovetodeletecode.com/post/2017/06/01/running-apache-solr-6.5-on-an-azure-app-service-instance/.

The contents of `wwwroot` is merged into the zip distribution of [Solr-6.6.3](http://archive.apache.org/dist/lucene/solr/6.6.3/solr-6.6.3.zip) prior to being published to the App Service.

## Prerequisites
1. Azure subscription
2. Azure PowerShell

## Steps
1. Run `.\Scripts\Invoke-AzureDeployment.ps1 -SubscriptionId <subscription-id> -ResourceGroupName <resource-group-name> -AppServiceName <app-service-name>` to create a Resource Group with an App Service Plan and an App Service for Solr.

2. Run `.\Scripts\Publish-AzureAppService.ps1 -ResourceGroupName <resource-group-name> -AppServiceName <app-service-name>` to publish the contents of `wwwroot` to the App Service.

    2.1 The default Solr version is 6.6.3. If you need a different version, override the `SolrZipUrl` parameter and update `Web.config` accordingly.

3. Navigate to `https://<app-service-name>.azurewebsites.net/` to access the Solr dashboard.

4. The Solr installation is publicly available. Secure access to your App Service using Authentication or Networking tabs from the Azure portal.

