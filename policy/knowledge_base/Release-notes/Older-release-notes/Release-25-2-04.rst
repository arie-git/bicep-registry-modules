Release 25-2 04
===============
Release date: May 20, 2025

.. warning::
  | **Breaking changes**

  - DRCP denies deployments of Azure SQL sub-resource types that fall outside the scope of the Azure :doc:`SQL Database component <../../Azure-components/SQL-Database>`, for all usages (DTAP). Follow `this link <https://portal.azure.com/#view/HubsExtension/ArgQueryBlade/query/resources%20%7C%20where%20type%20in~%20%28%22microsoft.sql%2Fservers%2Felasticpools%22%2C%20%22microsoft.sql%2Fservers%2Fdatabases%2FsyncGroups%22%2C%20%22microsoft.sql%2Fservers%2FjobAgents%22%2C%20%22microsoft.sql%2Fservers%2FdnsAliases%22%29%20%7C%20project%20name%2C%20type%2C%20location%2C%20resourceGroup%2C%20subscriptionId>`__ to run a KQL query (in your user context) to find current deviating resources. `[SAA-13642] <https://jira.office01.internalcorp.net:8443/browse/SAA-13642>`__
  - DRCP will remove extra permissions of ADO repository creators. `[SAA-13808] <https://jira.office01.internalcorp.net:8443/browse/SAA-13808>`__

  **Upcoming breaking changes**

  Release 25-2 05 (June 3, 2025)

  - DRCP will enforce :doc:`build validation <../../Application-development/Azure-devops/Build-validation>` for all Azure DevOps projects. `[SAA-8974] <https://jira.office01.internalcorp.net:8443/browse/SAA-8974>`__
  - DRCP will apply branch policies like requiring pull requests. `[SAA-11522] <https://jira.office01.internalcorp.net:8443/browse/SAA-11522>`__
  - DRCP will enforce new restrictions (with policy effect Deny) on user-defined routes with next hop type ``Internet``. Updated DRCP policies ensures that routes with destinations to ``AzureActiveDirectory`` and ``AzureMonitor`` are no longer allowed to point directly to Internet. Traffic must instead route through the central firewalls. Follow `this link <https://portal.azure.com/#view/HubsExtension/ArgQueryBlade/query/resources%20%7C%20where%20type%20%3D%3D%20%22microsoft.network%2Froutetables%22%20%7C%20mv-expand%20routes%20%3D%20properties.routes%20%7C%20extend%20routeName%20%3D%20routes.name%2C%20addressPrefix%20%3D%20tostring(routes.properties.addressPrefix)%2C%20nextHopType%20%3D%20tostring(routes.properties.nextHopType)%2C%20resourceGroup%20%3D%20tostring(resourceGroup)%2C%20routeTableId%20%3D%20id%2C%20subscriptionId%20%3D%20subscriptionId%20%7C%20where%20nextHopType%20%3D%3D%20%22Internet%22%20%7C%20where%20addressPrefix%20!in%20(%22GatewayManager%22)%20%7C%20where%20not((resourceGroup%20endswith%20%22-agw-rg%22%20and%20addressPrefix%20%3D%3D%20%220.0.0.0%2F0%22))%20%7C%20join%20kind%3Dinner%20(ResourceContainers%20%7C%20where%20type%20%3D%3D%20%22microsoft.resources%2Fsubscriptions%22%20%7C%20where%20name%20contains%20%22-ENV%22%20%7C%20project%20subscriptionId%2C%20subscriptionName%20%3D%20name)%20on%20subscriptionId%20%7C%20project%20subscriptionName%2C%20subscriptionId%2C%20resourceGroup%2C%20routeTableId%2C%20routeName%2C%20addressPrefix%2C%20nextHopType>`__ to run a KQL query (in your user context) to find current deviating routes. `[SAA-10105] <https://jira.office01.internalcorp.net:8443/browse/SAA-10105>`__ and `[SAA-11692] <https://jira.office01.internalcorp.net:8443/browse/SAA-11692>`__
  - DRCP will remove the TempAccess for Application systems from the ServiceNow :doc:`Quick actions <../../Platform/DRDC-portal/Quick-actions>`. `[SAA-12807] <https://jira.office01.internalcorp.net:8443/browse/SAA-12807>`__

What's new for users
--------------------
- Added specific :doc:`Azure SQL Server subtypes <../../Azure-components/SQL-Database/Use-cases>` to policy ``APG DRCP Generic blocked resource types`` for all usages (DTAP), and updated KB page :doc:`Use cases SQL Database <../../Azure-components/SQL-Database/Use-cases>`. `[SAA-13750] <https://jira.office01.internalcorp.net:8443/browse/SAA-13750>`__
- Added beta component :doc:`PostgreSQL <../../Azure-components/PostgreSQL>` to the :doc:`overview of Azure components <../../Azure-components>`. `[SAA-10015] <https://jira.office01.internalcorp.net:8443/browse/SAA-10015>`_
- Added warning for all Azure component to **not use** new AI features, see :doc:`Frequently asked questions <../../Frequently-asked-questions>`. `[SAA-7883] <https://jira.office01.internalcorp.net:8443/browse/SAA-7883>`__
- For production usage, unused resource providers are disabled. To re-enable these resource providers use the :doc:`Quick action <../../Platform/DRDC-portal/Quick-actions>` 'Enable resource provider' `[ISF-7685] <https://jira.office01.internalcorp.net:8443/browse/ISF-7685>`__
- Added new :doc:`IAM role for TempAcces <../../Getting-started/Roles-and-authorizations>` to Application systems which uses `Privileged Identity Management (PIM) for Groups` for Just In Time (JIT) access. Product owners now need add users to new role. `[SAA-12801] <https://jira.office01.internalcorp.net:8443/browse/SAA-12801>`__
- Added serverless to :doc:`Use cases Databricks <../../Azure-components/Databricks/Use-cases>`. `[SAA-13172] <https://jira.office01.internalcorp.net:8443/browse/SAA-13172>`__
- Added new permissions to the authorization model. `[SAA-12267] <https://jira.office01.internalcorp.net:8443/browse/SAA-12267>`__

Internal platform improvements
------------------------------
- Performed LCM for :doc:`Databricks <../../Azure-components/Databricks>`. `[SAA-7883] <https://jira.office01.internalcorp.net:8443/browse/SAA-7883>`__
- Extended the internal DRCP regression test with tests related to policy ``APG DRCP Generic blocked resource types``. `[SAA-13750] <https://jira.office01.internalcorp.net:8443/browse/SAA-13750>`__
- Added checks for Azure DevOps projects in the internal DRCP garbage collection pipeline. `[SAA-4875] <https://jira.office01.internalcorp.net:8443/browse/SAA-4875>`__
- Added checks for Infoblox and Mule in the internal DRCP garbage collection pipeline. `[SAA-4871] <https://jira.office01.internalcorp.net:8443/browse/SAA-4871>`__
- Added checks for Service Connections in the internal DRCP garbage collection pipeline. `[SAA-4876] <https://jira.office01.internalcorp.net:8443/browse/SAA-4876>`__
