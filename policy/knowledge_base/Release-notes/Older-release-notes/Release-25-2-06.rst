Release 25-2 06
===============
Release date: June 17, 2025

.. warning::
  | **Breaking changes**

  - DRCP enforces restrictions (with policy effect Deny for all usages (DTAP)) on user-defined routes with next hop type ``Internet``. DRCP policy ``APG DRCP Network Deny routes with next hop type Internet bypassing central firewalls`` ensures that routes with destinations to ``AzureActiveDirectory`` and ``AzureMonitor`` are no longer allowed to point directly to Internet. Traffic must instead route through the central firewalls. Follow `this link <https://portal.azure.com/#view/HubsExtension/ArgQueryBlade/query/resources%20%7C%20where%20type%20%3D%3D%20%22microsoft.network%2Froutetables%22%20%7C%20mv-expand%20routes%20%3D%20properties.routes%20%7C%20extend%20routeName%20%3D%20routes.name%2C%20addressPrefix%20%3D%20tostring(routes.properties.addressPrefix)%2C%20nextHopType%20%3D%20tostring(routes.properties.nextHopType)%2C%20resourceGroup%20%3D%20tostring(resourceGroup)%2C%20routeTableId%20%3D%20id%2C%20subscriptionId%20%3D%20subscriptionId%20%7C%20where%20nextHopType%20%3D%3D%20%22Internet%22%20%7C%20where%20addressPrefix%20!in%20(%22GatewayManager%22)%20%7C%20where%20not((resourceGroup%20endswith%20%22-agw-rg%22%20and%20addressPrefix%20%3D%3D%20%220.0.0.0%2F0%22))%20%7C%20join%20kind%3Dinner%20(ResourceContainers%20%7C%20where%20type%20%3D%3D%20%22microsoft.resources%2Fsubscriptions%22%20%7C%20where%20name%20contains%20%22-ENV%22%20%7C%20project%20subscriptionId%2C%20subscriptionName%20%3D%20name)%20on%20subscriptionId%20%7C%20project%20subscriptionName%2C%20subscriptionId%2C%20resourceGroup%2C%20routeTableId%2C%20routeName%2C%20addressPrefix%2C%20nextHopType>`__ to run a KQL query (in your user context) to find current deviating routes. `[SAA-13761] <https://jira.office01.internalcorp.net:8443/browse/SAA-13761>`__
  - DRCP moved the TempAccess for Environments from the ServiceNow :doc:`Quick actions <../../Platform/DRDC-portal/Quick-actions>` to `Microsoft Entra Privileged Identity Management (PIM) <https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/CommonMenuBlade/~/quickStart>`__. `[SAA-12840] <https://jira.office01.internalcorp.net:8443/browse/SAA-12840>`__

What's new for users
--------------------
- Removed the Quick action ``Request temporary access for LZ3`` for Environment. `[SAA-12840] <https://jira.office01.internalcorp.net:8443/browse/SAA-12840>`__
- Added model ``GPT-4o-mini`` and ``Text-embedding-3-large`` for Azure OpenAI and updated :doc:`Use Cases AI Services <../../Azure-components/AI-services/Use-cases>`. `[SAA-14380] <https://jira.office01.internalcorp.net:8443/browse/SAA-14380>`__

Internal platform improvements
------------------------------
- Added the managed identities of the Azure DevOps commit API Function App to the Project Collection Readers of the connectdrcpapg1 organization. `[SAA-14009] <https://jira.office01.internalcorp.net:8443/browse/SAA-14009>`__
- Added testing for the new Azure DevOps commit API to the `DRCP service status <https://apgprd.service-now.com/drdc?id=drcp_status>`__ and to the internal DRCP regression test. `[SAA-13685] <https://jira.office01.internalcorp.net:8443/browse/SAA-13685>`__

Fixed issues
------------
- Fixed an issue in the internal DRCP regression test where Bicep no longer allows dynamic expressions in templates. `[SAA-14570] <https://jira.office01.internalcorp.net:8443/browse/SAA-14570>`__
