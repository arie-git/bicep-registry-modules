Release 25-2 05
===============
Release date: June 3, 2025

.. warning::
  | **Breaking changes**

  - DRCP will enforce :doc:`build validation <../../Application-development/Azure-devops/Build-validation>` for all Azure DevOps projects. `[SAA-8974] <https://jira.office01.internalcorp.net:8443/browse/SAA-8974>`__
  - DRCP enforces restrictions (with policy effect Deny for usages Dev and Test) on user-defined routes with next hop type ``Internet``. DRCP policy ``APG DRCP Network Deny routes with next hop type Internet bypassing central firewalls`` ensures that routes with destinations to ``AzureActiveDirectory`` and ``AzureMonitor`` are no longer allowed to point directly to Internet. Traffic must instead route through the central firewalls. Follow `this link <https://portal.azure.com/#view/HubsExtension/ArgQueryBlade/query/resources%20%7C%20where%20type%20%3D%3D%20%22microsoft.network%2Froutetables%22%20%7C%20mv-expand%20routes%20%3D%20properties.routes%20%7C%20extend%20routeName%20%3D%20routes.name%2C%20addressPrefix%20%3D%20tostring(routes.properties.addressPrefix)%2C%20nextHopType%20%3D%20tostring(routes.properties.nextHopType)%2C%20resourceGroup%20%3D%20tostring(resourceGroup)%2C%20routeTableId%20%3D%20id%2C%20subscriptionId%20%3D%20subscriptionId%20%7C%20where%20nextHopType%20%3D%3D%20%22Internet%22%20%7C%20where%20addressPrefix%20!in%20(%22GatewayManager%22)%20%7C%20where%20not((resourceGroup%20endswith%20%22-agw-rg%22%20and%20addressPrefix%20%3D%3D%20%220.0.0.0%2F0%22))%20%7C%20join%20kind%3Dinner%20(ResourceContainers%20%7C%20where%20type%20%3D%3D%20%22microsoft.resources%2Fsubscriptions%22%20%7C%20where%20name%20contains%20%22-ENV%22%20%7C%20project%20subscriptionId%2C%20subscriptionName%20%3D%20name)%20on%20subscriptionId%20%7C%20project%20subscriptionName%2C%20subscriptionId%2C%20resourceGroup%2C%20routeTableId%2C%20routeName%2C%20addressPrefix%2C%20nextHopType>`__ to run a KQL query (in your user context) to find current deviating routes. `[SAA-10105] <https://jira.office01.internalcorp.net:8443/browse/SAA-10105>`__ and `[SAA-11692] <https://jira.office01.internalcorp.net:8443/browse/SAA-11692>`__
  - DRCP moved the TempAccess for Application systems from the ServiceNow :doc:`Quick actions <../../Platform/DRDC-portal/Quick-actions>` to `Microsoft Entra Privileged Identity Management (PIM) <https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/CommonMenuBlade/~/quickStart>`__. `[SAA-12807] <https://jira.office01.internalcorp.net:8443/browse/SAA-12807>`__
  - DRCP will apply branch policies like requiring pull requests. `[SAA-11522] <https://jira.office01.internalcorp.net:8443/browse/SAA-11522>`__

  **Upcoming breaking changes**

  Release 25-2 06 (June 17, 2025)

  - DRCP enforces restrictions (with policy effect Deny for all usages (DTAP)) on user-defined routes with next hop type ``Internet``. DRCP policy ``APG DRCP Network Deny routes with next hop type Internet bypassing central firewalls`` ensures that routes with destinations to ``AzureActiveDirectory`` and ``AzureMonitor`` are no longer allowed to point directly to Internet. Traffic must instead route through the central firewalls. Follow `this link <https://portal.azure.com/#view/HubsExtension/ArgQueryBlade/query/resources%20%7C%20where%20type%20%3D%3D%20%22microsoft.network%2Froutetables%22%20%7C%20mv-expand%20routes%20%3D%20properties.routes%20%7C%20extend%20routeName%20%3D%20routes.name%2C%20addressPrefix%20%3D%20tostring(routes.properties.addressPrefix)%2C%20nextHopType%20%3D%20tostring(routes.properties.nextHopType)%2C%20resourceGroup%20%3D%20tostring(resourceGroup)%2C%20routeTableId%20%3D%20id%2C%20subscriptionId%20%3D%20subscriptionId%20%7C%20where%20nextHopType%20%3D%3D%20%22Internet%22%20%7C%20where%20addressPrefix%20!in%20(%22GatewayManager%22)%20%7C%20where%20not((resourceGroup%20endswith%20%22-agw-rg%22%20and%20addressPrefix%20%3D%3D%20%220.0.0.0%2F0%22))%20%7C%20join%20kind%3Dinner%20(ResourceContainers%20%7C%20where%20type%20%3D%3D%20%22microsoft.resources%2Fsubscriptions%22%20%7C%20where%20name%20contains%20%22-ENV%22%20%7C%20project%20subscriptionId%2C%20subscriptionName%20%3D%20name)%20on%20subscriptionId%20%7C%20project%20subscriptionName%2C%20subscriptionId%2C%20resourceGroup%2C%20routeTableId%2C%20routeName%2C%20addressPrefix%2C%20nextHopType>`__ to run a KQL query (in your user context) to find current deviating routes. `[SAA-10105] <https://jira.office01.internalcorp.net:8443/browse/SAA-10105>`__ and `[SAA-11692] <https://jira.office01.internalcorp.net:8443/browse/SAA-11692>`__
  - DRCP will remove the TempAccess for Environments from the ServiceNow :doc:`Quick actions <../../Platform/DRDC-portal/Quick-actions>`. `[SAA-12840] <https://jira.office01.internalcorp.net:8443/browse/SAA-12840>`__

What's new for users
--------------------
- Removed the Quick action ``Request temporary access for LZ3`` for Application systems. `[SAA-12807] <https://jira.office01.internalcorp.net:8443/browse/SAA-12807>`__
- DRCP will apply branch policies for branch protection of release and hotfix branches. `[SAA-11522] <https://jira.office01.internalcorp.net:8443/browse/SAA-11522>`__
- Closed vulnerabilities are no longer shown in the DRDC portal. `[SAA-14167] <https://jira.office01.internalcorp.net:8443/browse/SAA-14167>`__
- Adjusted :doc:`Databricks security baselines <../../Azure-components/Databricks/Security-Baseline>` for accessible system tables. `[SAA-12943] <https://jira.office01.internalcorp.net:8443/browse/SAA-12943>`__
- DRCP implemented new :doc:`Databricks security baselines <../../Azure-components/Databricks/Security-Baseline>` ``drcp-adb-w24``, ``drcp-adb-w25``, ``drcp-adb-w26``, and ``drcp-adb-w27``. `[SAA-13136] <https://jira.office01.internalcorp.net:8443/browse/SAA-13136>`__
- Added new :doc:`IAM role for Production Engineer <../../Getting-started/Roles-and-authorizations>` to Application systems which uses `Privileged Identity Management (PIM) for Groups` for Just In Time (JIT) access to Production Environments. Product owners now need add users to new role. `[SAA-12834] <https://jira.office01.internalcorp.net:8443/browse/SAA-12834>`__

Fixed issues
------------
- Added extra check to skip creator user removal on disabled repositories. `[SAA-14047] <https://jira.office01.internalcorp.net:8443/browse/SAA-14047>`__
- The Azure LLDC team initiates a phased rollout of Azure Private DNS Internet Fallback to reduce NXDOMAIN errors, application downtime, and lower operational overhead in the APG multi-tenant, multi-Subscription Azure landscape. `[CHG2122335] <https://apgprd.service-now.com/now/nav/ui/classic/params/target/change_request.do%3Fsys_id%3Dc055df872ba16e14de9cf7cafe91bf21%26sysparm_view%3D%26sysparm_domain%3Dnull%26sysparm_domain_scope%3Dnull%26sysparm_record_row%3D2%26sysparm_record_rows%3D26%26sysparm_record_list%3Dassignment_group%25253D68f64e2bdbbb7f88ac00f05c0c96192d%25255Eactive%25253Dtrue%25255Estate%252521%25253D6%25255EORDERBYnumber>`__

Internal platform improvements
------------------------------
- Created API for reading Azure DevOps repository commits. `[SAA-10947] <https://jira.office01.internalcorp.net:8443/browse/SAA-10947>`__
