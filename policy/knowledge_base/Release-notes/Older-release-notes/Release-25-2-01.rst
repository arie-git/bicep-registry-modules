Release 25-2 01
===============
Release date: April 8, 2025


.. warning:: Upcoming breaking change: during Release **25-2 02** (April 22, 2025), DRCP will remove extra permissions of ADO repository creators. `[SAA-12249] <https://jira.office01.internalcorp.net:8443/browse/SAA-12249>`__

.. warning:: Upcoming breaking change: during Release **25-2 05** (June 3, 2025), DRCP will enforce :doc:`build validation <../../Application-development/Azure-devops/Build-validation>` for all Azure DevOps projects. `[SAA-8974] <https://jira.office01.internalcorp.net:8443/browse/SAA-8974>`__

.. warning:: Upcoming breaking change: during Release **25-2 05** (June 3, 2025), DRCP will enforce new restrictions (with policy effect Deny) on user-defined routes with next hop type ``Internet``. Updated DRCP policies ensures that routes with destinations to ``AzureActiveDirectory`` and ``AzureMonitor`` are no longer allowed to point directly to Internet. Traffic must instead route through the central firewalls. **Tip:** Follow `this link <https://portal.azure.com/#view/HubsExtension/ArgQueryBlade/query/resources%20%7C%20where%20type%20%3D%3D%20%22microsoft.network%2Froutetables%22%20%7C%20mv-expand%20routes%20%3D%20properties.routes%20%7C%20extend%20routeName%20%3D%20routes.name%2C%20addressPrefix%20%3D%20tostring(routes.properties.addressPrefix)%2C%20nextHopType%20%3D%20tostring(routes.properties.nextHopType)%2C%20resourceGroup%20%3D%20tostring(resourceGroup)%2C%20routeTableId%20%3D%20id%2C%20subscriptionId%20%3D%20subscriptionId%20%7C%20where%20nextHopType%20%3D%3D%20%22Internet%22%20%7C%20where%20addressPrefix%20!in%20(%22GatewayManager%22)%20%7C%20where%20not((resourceGroup%20endswith%20%22-agw-rg%22%20and%20addressPrefix%20%3D%3D%20%220.0.0.0%2F0%22))%20%7C%20join%20kind%3Dinner%20(ResourceContainers%20%7C%20where%20type%20%3D%3D%20%22microsoft.resources%2Fsubscriptions%22%20%7C%20where%20name%20contains%20%22-ENV%22%20%7C%20project%20subscriptionId%2C%20subscriptionName%20%3D%20name)%20on%20subscriptionId%20%7C%20project%20subscriptionName%2C%20subscriptionId%2C%20resourceGroup%2C%20routeTableId%2C%20routeName%2C%20addressPrefix%2C%20nextHopType>`__ to run a KQL query (in your user context) to find current deviating routes. `[SAA-10105] <https://jira.office01.internalcorp.net:8443/browse/SAA-10105>`__ and `[SAA-11692] <https://jira.office01.internalcorp.net:8443/browse/SAA-11692>`__

What's new for users
--------------------
- The user can no longer use the option `Create DNS record in private DNS zone appserviceenvironment.net` under request ``Request a manual action by SIS (Azure only)``, so it has been disabled. `[SAA-12974] <https://jira.office01.internalcorp.net:8443/browse/SAA-12974>`__
- The permissions for the APG Engineers and Contributers groups get restricted to reader rights on the DRCPVariables library group. `[SAA-12243] <https://jira.office01.internalcorp.net:8443/browse/SAA-12243>`__

Fixed issues
------------
- Fixed an issue by adding the Subscription ids `2cc76c84-c65f-4b1e-b565-cca1884e8991` and `1608a26a-c231-4f69-ab2c-9bcb5a915b8e` to the policy `APG DRCP AI Search Network Private endpoints private link service connections` to ensure outbound connectivity between AI Language and AI Search for the 'question answering' feature is working as expected. `[SAA-11528] <https://jira.office01.internalcorp.net:8443/browse/SAA-11528>`__
- Fixed an issue in the policy ``"APG DRCP Application Gateway Web Application Firewall should not contain exclusions on managed rules"``, where deletion of the Firewall policy rules was impossible. `[SAA-11453] <https://jira.office01.internalcorp.net:8443/browse/SAA-13360>`__
- Fixed an issue where the policy ``"APG DRCP Application Gateway Web Application Firewall shouldn't contain custom rules other than rule type rate limit"`` incorrectly marked compliant configurations as non-compliant, even when no exclusions. `[SAA-13630] <https://jira.office01.internalcorp.net:8443/browse/SAA-13630>`__

Preparing for the future
------------------------
- In preparation for the upcoming breaking change in Release **25-2 05** (June 3, 2025), DRCP now audits user-defined routes with next hop type ``Internet`` as required by :doc:`security baseline <../../Azure-components/Subscription/Subscription-Baseline>` control ``drcp-sub-03``. Routes with destinations to ``AzureActiveDirectory`` and ``AzureMonitor`` are no longer allowed to point directly to Internet (adhering the scenarios described on page :doc:`Networking <../../Platform/Networking>`). `[SAA-10105] <https://jira.office01.internalcorp.net:8443/browse/SAA-10105>`__

Internal platform improvements
------------------------------
- The ServiceNow variable store populates the Subscription ids used in the policy `APG DRCP AI Search Network Private endpoints private link service connections` for better manageability. `[SAA-11329] <https://jira.office01.internalcorp.net:8443/browse/SAA-11329>`__
- Added policy compliance tests for ``usedBy`` tag for AI Search in DRCP regression tests. `[SAA-12631] <https://jira.office01.internalcorp.net:8443/browse/SAA-12631>`__