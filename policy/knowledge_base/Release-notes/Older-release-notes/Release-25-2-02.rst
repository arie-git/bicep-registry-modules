Release 25-2 02
===============
Release date: April 22, 2025

.. warning:: Upcoming breaking change: during Release **25-2 03** (May 6, 2025), DRCP will remove extra permissions of ADO repository creators. `[SAA-12249] <https://jira.office01.internalcorp.net:8443/browse/SAA-12249>`__

.. warning:: | Upcoming breaking change: during Release **25-2 03** (May 6, 2025), DRCP denies Azure SQL servers without a minimum TLS version specified, to conform to security baseline control ``drcp-sql-05``.
  | **Tip:** Follow `this link <https://portal.azure.com/#view/HubsExtension/ArgQueryBlade/query/resources%20%7C%20where%20type%20%3D%3D%20%22microsoft.sql%2Fservers%22%20%7C%20extend%20minimalTlsVersion%20%3D%20tostring(properties.minimalTlsVersion)%20%7C%20where%20minimalTlsVersion%20%3D%3D%20%22None%22%20%7C%20project%20name%2C%20location%2C%20resourceGroup%2C%20subscriptionId%2C%20minimalTlsVersion>`__ to run a KQL query (in your user context) to find current deviating SQL servers. `[SAA-13606] <https://jira.office01.internalcorp.net:8443/browse/SAA-13606>`__

.. vale Microsoft.SentenceLength = NO

.. warning:: | Upcoming breaking change: during Release **25-2 03** (May 6, 2025), DRCP denies deployments of Azure SQL sub-resource types that fall outside the scope of the Azure :doc:`SQL Database component <../../Azure-components/SQL-Database>`, for usages Development and Test. During Release **25-2 04** (May 20, 2025), DRCP also denies usages Acceptance and Production.
  | **Tip:** Follow `this link <https://portal.azure.com/#view/HubsExtension/ArgQueryBlade/query/resources%20%7C%20where%20type%20in~%20%28%22microsoft.sql%2Fservers%2Felasticpools%22%2C%20%22microsoft.sql%2Fservers%2Fdatabases%2FsyncGroups%22%2C%20%22microsoft.sql%2Fservers%2FjobAgents%22%2C%20%22microsoft.sql%2Fservers%2FdnsAliases%22%29%20%7C%20project%20name%2C%20type%2C%20location%2C%20resourceGroup%2C%20subscriptionId>`__ to run a KQL query (in your user context) to find current deviating resources. `[SAA-13642] <https://jira.office01.internalcorp.net:8443/browse/SAA-13642>`__

.. vale Microsoft.SentenceLength = YES

.. warning:: Upcoming breaking change: during Release **25-2 04** (May 20, 2025), DRCP will define specific names for release and hotfix branches, and apply branch policies like requiring pull requests. `[SAA-13551] <https://jira.office01.internalcorp.net:8443/browse/SAA-13351>`__

.. warning:: Upcoming breaking change: during Release **25-2 05** (June 3, 2025), DRCP will enforce :doc:`build validation <../../Application-development/Azure-devops/Build-validation>` for all Azure DevOps projects. `[SAA-8974] <https://jira.office01.internalcorp.net:8443/browse/SAA-8974>`__

.. warning:: | Upcoming breaking change: during Release **25-2 05** (June 3, 2025), DRCP will enforce new restrictions (with policy effect Deny) on user-defined routes with next hop type ``Internet``. Updated DRCP policies ensures that routes with destinations to ``AzureActiveDirectory`` and ``AzureMonitor`` are no longer allowed to point directly to Internet. Traffic must instead route through the central firewalls.
  | **Tip:** Follow `this link <https://portal.azure.com/#view/HubsExtension/ArgQueryBlade/query/resources%20%7C%20where%20type%20%3D%3D%20%22microsoft.network%2Froutetables%22%20%7C%20mv-expand%20routes%20%3D%20properties.routes%20%7C%20extend%20routeName%20%3D%20routes.name%2C%20addressPrefix%20%3D%20tostring(routes.properties.addressPrefix)%2C%20nextHopType%20%3D%20tostring(routes.properties.nextHopType)%2C%20resourceGroup%20%3D%20tostring(resourceGroup)%2C%20routeTableId%20%3D%20id%2C%20subscriptionId%20%3D%20subscriptionId%20%7C%20where%20nextHopType%20%3D%3D%20%22Internet%22%20%7C%20where%20addressPrefix%20!in%20(%22GatewayManager%22)%20%7C%20where%20not((resourceGroup%20endswith%20%22-agw-rg%22%20and%20addressPrefix%20%3D%3D%20%220.0.0.0%2F0%22))%20%7C%20join%20kind%3Dinner%20(ResourceContainers%20%7C%20where%20type%20%3D%3D%20%22microsoft.resources%2Fsubscriptions%22%20%7C%20where%20name%20contains%20%22-ENV%22%20%7C%20project%20subscriptionId%2C%20subscriptionName%20%3D%20name)%20on%20subscriptionId%20%7C%20project%20subscriptionName%2C%20subscriptionId%2C%20resourceGroup%2C%20routeTableId%2C%20routeName%2C%20addressPrefix%2C%20nextHopType>`__ to run a KQL query (in your user context) to find current deviating routes. `[SAA-10105] <https://jira.office01.internalcorp.net:8443/browse/SAA-10105>`__ and `[SAA-11692] <https://jira.office01.internalcorp.net:8443/browse/SAA-11692>`__

Preparing for the future
------------------------
- In preparation for the upcoming breaking change in Release **25-2 03** (May 6, 2025), DRCP adds a temporary audit-policy for Azure SQL servers that don't have a valid TLS version specified (property ``minimalTlsVersion`` with value ``None`` is no longer allowed) to conform with security baseline control ``drcp-sql-05``. In upcoming Release **25-2 03** this change adds to the existing Deny-policy ``APG DRCP SQL Minimum TLS version``.  `[SAA-13600] <https://jira.office01.internalcorp.net:8443/browse/SAA-13600>`__
- In preparation for the upcoming breaking change in Release **25-2 03** (May 6, 2025), DRCP adds a temporary audit-policy for Azure SQL sub-resource types that fall outside the scope of the Azure :doc:`SQL Database component <../../Azure-components/SQL-Database>`. See upcoming breaking change warning at the top of this page. This change will then add to the existing Deny-policy ``APG DRCP Generic blocked resource types``. `[SAA-12164] <https://jira.office01.internalcorp.net:8443/browse/SAA-12164>`__

Internal platform improvements
------------------------------
- Added a scheduled pipeline to identify technical garbage objects throughout the DRCP platform. `[SAA-4878] <https://jira.office01.internalcorp.net:8443/browse/SAA-4878>`__
- Adjusted policy ``APG DRCP StorageAccount Disallow network ACL and firewall bypassing`` to report Storage Accounts as compliant for Capture feature Event Hubs with Bypass AzureServices enabled. This requires the appropriate tag configured and to restrict the use to Event Hubs. See documentation :doc:`here <../../Azure-components/Event-Hubs/Use-cases>`. `[SAA-12712] <https://jira.office01.internalcorp.net:8443/browse/SAA-12712>`_
- Generic text improvements throughout the KB.