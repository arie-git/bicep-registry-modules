Release 25-2 03
===============
Release date: May 06, 2025

.. warning:: | Breaking change: DRCP denies Azure SQL servers without a minimum TLS version specified, to conform to security baseline control ``drcp-sql-05``.
  | **Tip:** Follow `this link <https://portal.azure.com/#view/HubsExtension/ArgQueryBlade/query/resources%20%7C%20where%20type%20%3D%3D%20%22microsoft.sql%2Fservers%22%20%7C%20extend%20minimalTlsVersion%20%3D%20tostring(properties.minimalTlsVersion)%20%7C%20where%20minimalTlsVersion%20%3D%3D%20%22None%22%20%7C%20project%20name%2C%20location%2C%20resourceGroup%2C%20subscriptionId%2C%20minimalTlsVersion>`__ to run a KQL query (in your user context) to find current deviating SQL servers. `[SAA-13606] <https://jira.office01.internalcorp.net:8443/browse/SAA-13606>`__

.. vale Microsoft.SentenceLength = NO

.. warning:: | Breaking change: DRCP denies deployments of Azure SQL sub-resource types that fall outside the scope of the Azure :doc:`SQL Database component <../../Azure-components/SQL-Database>`, for usages Development and Test. During Release **25-2 04** (May 20, 2025), DRCP also denies usages Acceptance and Production.
  | **Tip:** Follow `this link <https://portal.azure.com/#view/HubsExtension/ArgQueryBlade/query/resources%20%7C%20where%20type%20in~%20%28%22microsoft.sql%2Fservers%2Felasticpools%22%2C%20%22microsoft.sql%2Fservers%2Fdatabases%2FsyncGroups%22%2C%20%22microsoft.sql%2Fservers%2FjobAgents%22%2C%20%22microsoft.sql%2Fservers%2FdnsAliases%22%29%20%7C%20project%20name%2C%20type%2C%20location%2C%20resourceGroup%2C%20subscriptionId>`__ to run a KQL query (in your user context) to find current deviating resources. `[SAA-13642] <https://jira.office01.internalcorp.net:8443/browse/SAA-13642>`__

.. vale Microsoft.SentenceLength = YES

.. warning:: Upcoming breaking change: during Release **25-2 04** (May 20, 2025), DRCP will remove extra permissions of ADO repository creators. `[SAA-13808] <https://jira.office01.internalcorp.net:8443/browse/SAA-13808>`__

.. warning:: Upcoming breaking change: during Release **25-2 05** (June 3, 2025), DRCP will enforce :doc:`build validation <../../Application-development/Azure-devops/Build-validation>` for all Azure DevOps projects. `[SAA-8974] <https://jira.office01.internalcorp.net:8443/browse/SAA-8974>`__

.. warning:: Upcoming breaking change: during Release **25-2 05** (June 3, 2025), DRCP will define specific names for release and hotfix branches, and apply branch policies like requiring pull requests. `[SAA-11522] <https://jira.office01.internalcorp.net:8443/browse/SAA-11522>`__

.. warning:: | Upcoming breaking change: during Release **25-2 05** (June 3, 2025), DRCP will enforce new restrictions (with policy effect Deny) on user-defined routes with next hop type ``Internet``. Updated DRCP policies ensures that routes with destinations to ``AzureActiveDirectory`` and ``AzureMonitor`` are no longer allowed to point directly to Internet. Traffic must instead route through the central firewalls.
  | **Tip:** Follow `this link <https://portal.azure.com/#view/HubsExtension/ArgQueryBlade/query/resources%20%7C%20where%20type%20%3D%3D%20%22microsoft.network%2Froutetables%22%20%7C%20mv-expand%20routes%20%3D%20properties.routes%20%7C%20extend%20routeName%20%3D%20routes.name%2C%20addressPrefix%20%3D%20tostring(routes.properties.addressPrefix)%2C%20nextHopType%20%3D%20tostring(routes.properties.nextHopType)%2C%20resourceGroup%20%3D%20tostring(resourceGroup)%2C%20routeTableId%20%3D%20id%2C%20subscriptionId%20%3D%20subscriptionId%20%7C%20where%20nextHopType%20%3D%3D%20%22Internet%22%20%7C%20where%20addressPrefix%20!in%20(%22GatewayManager%22)%20%7C%20where%20not((resourceGroup%20endswith%20%22-agw-rg%22%20and%20addressPrefix%20%3D%3D%20%220.0.0.0%2F0%22))%20%7C%20join%20kind%3Dinner%20(ResourceContainers%20%7C%20where%20type%20%3D%3D%20%22microsoft.resources%2Fsubscriptions%22%20%7C%20where%20name%20contains%20%22-ENV%22%20%7C%20project%20subscriptionId%2C%20subscriptionName%20%3D%20name)%20on%20subscriptionId%20%7C%20project%20subscriptionName%2C%20subscriptionId%2C%20resourceGroup%2C%20routeTableId%2C%20routeName%2C%20addressPrefix%2C%20nextHopType>`__ to run a KQL query (in your user context) to find current deviating routes. `[SAA-10105] <https://jira.office01.internalcorp.net:8443/browse/SAA-10105>`__ and `[SAA-11692] <https://jira.office01.internalcorp.net:8443/browse/SAA-11692>`__

What's new for users
--------------------
- Added specific Azure SQL Server subtypes to the policy ``APG DRCP Generic blocked resource types`` for Development and Test usage. `[SAA-13642] <https://jira.office01.internalcorp.net:8443/browse/SAA-13642>`_
- Added new documentation for :doc:`Branch protection <../../Application-development/Azure-devops/Branch-protection>`. `[SAA-13778] <https://jira.office01.internalcorp.net:8443/browse/SAA-13778>`_
- Scheduled a refresh of all Application systems every day at 03.00h, to ensure desired state. `[SAA-13808] <https://jira.office01.internalcorp.net:8443/browse/SAA-13808>`_

Fixed issues
------------
- Fixed an issue where the pipeline Invoke-SecBaselineDatabricks failed due to upgrade of dependend packages. `[SAA-13784] <https://jira.office01.internalcorp.net:8443/browse/SAA-13784>`_
- Adjusted policy ``APG DRCP AISearchAllowApprovedAPIVersions`` to report AI Search as compliant. This requires adding a new AI search version in the list of allowed values. `[SAA-13612] <https://jira.office01.internalcorp.net:8443/browse/SAA-13612>`__
- Fixed an issue in the policy ``APG DRCP SQL Minimum TLS version`` where it now requires to specify the TLS version. `[SAA-13606] <https://jira.office01.internalcorp.net:8443/browse/SAA-13606>`__

Internal platform improvements
------------------------------
- Added policy compliance tests for SQL to regression testing. `[SAA-13606] <https://jira.office01.internalcorp.net:8443/browse/SAA-13606>`__
- Added checks in garabage collection pipeline for Azure Subscriptions. `[SAA-4877] <https://jira.office01.internalcorp.net:8443/browse/SAA-4877>`__
- Created ADO command to remove explicit permissions of the repository creator. `[SAA-12249] <https://jira.office01.internalcorp.net:8443/browse/SAA-12249>`__
