Release 23-4 01
===============
Release date: October 10, 2023

.. warning:: ``Upcoming breaking change: on the release of October 24th, creating API Keys on Application Insight will be disabled.``

What's new for users
--------------------
- Static Web Apps (partition id's 1 to 5) are now automatically integrated with private DNS using a remediation policy. See :doc:`this article <../../Azure-components/App-Service/Use-cases>` to learn more about limitations. `[SAA-4653] <https://jira.office01.internalcorp.net:8443/browse/SAA-4653>`__
- On Log Analytics Workspaces, disabled the data sources which allow for integration with Legacy features. `[SAA-4602] <https://jira.office01.internalcorp.net:8443/browse/SAA-4602>`__

Fixed issues
------------
- Fixed an issue where the SonarQube service connection failed after an on-premise server migration. `[SAA-4779] <https://jira.office01.internalcorp.net:8443/browse/SAA-4779>`__
- Fixed an issue where the Event Hub policies contained faulty logic. `[SAA-4737] <https://jira.office01.internalcorp.net:8443/browse/SAA-4737>`__
- Disabled ``Application Insights Component Contributor`` and ``Website Contributor`` builtin roles because these allow creating API keys for Application Insights. `[SAA-4612] <https://jira.office01.internalcorp.net:8443/browse/SAA-4612>`__
- The policy effect for the local authentication on Dev usages for Application Insights remains "Audit" instead of "Deny" going forward after next release on October 10th 2023. `[SAA-3417] <https://jira.office01.internalcorp.net:8443/browse/SAA-3417>`__
- The policy effect for the local authentication for Application Insights will remain "Audit" instead of "Deny" in this release. `[SAA-3417] <https://jira.office01.internalcorp.net:8443/browse/SAA-3417>`__
- Fixed an issue where it takes up to 24 hour before an environment is accessible after creation due to collection of IAM data. `[SAA-4368] <https://jira.office01.internalcorp.net:8443/browse/SAA-4368>`__
- Fixed an issue where the registration of an environment in ServiceNow was incomplete when the first pipeline run failed. `[SAA-5386] <https://jira.office01.internalcorp.net:8443/browse/SAA-5386>`__
- Fixed an issue where the JSON definitions of the DRCP policies weren't fully matching the required JSON schema of Microsoft. `[SAA-5364] <https://jira.office01.internalcorp.net:8443/browse/SAA-5364>`__
- Adjusted the Pester test in the DRCP code quality gate to test the DRCP policies on the required JSON schema of Microsoft. `[SAA-5364] <https://jira.office01.internalcorp.net:8443/browse/SAA-5364>`__

Preparing for the future
------------------------
- The policy effect for the built-in Azure RBAC roles belonging to DRCP MVP components will change from "Audit" to "Deny" in this release. Please prepare and check if your environments are compliant to this policy before the policy effect becomes "Deny." `[SAA-3498] <https://jira.office01.internalcorp.net:8443/browse/SAA-3498>`__
- Disabled generating API keys for Application Insights on all RBAC roles, due to this feature being on a deprecation path. `[SAA-4612] <https://jira.office01.internalcorp.net:8443/browse/SAA-4612>`__
- On Event Hub Namespaces, remove the authorization rules except for "RootManagedSharedAccess." `[SAA-4737] <https://jira.office01.internalcorp.net:8443/browse/SAA-4737>`__
- On Event Hubs, remove the authorization rules. `[SAA-4737] <https://jira.office01.internalcorp.net:8443/browse/SAA-4737>`__
- On Event Hub Namespaces namespaces under Networking, remove any exceptions on the internal Firewall ACL and subnets in the allowed subnets section under selected networks. `[SAA-4737] <https://jira.office01.internalcorp.net:8443/browse/SAA-4737>`__
- On the Environment view in ServiceNow it's now possible to see alerts. Please note, this is in preparation for a future release of Azure Monitoring Alerts. `[SAA-3909] <https://jira.office01.internalcorp.net:8443/browse/SAA-3909>`__
- On the custom role named ``APG Custom - DRCP - Monitoring Contributor (FP)-MG`` disabled generating API keys for Application Insights. `[SAA-3417] <https://jira.office01.internalcorp.net:8443/browse/SAA-3417>`__ & `[SAA-4612] <https://jira.office01.internalcorp.net:8443/browse/SAA-4612>`__
- On custom role named ``APG Custom - DRCP - Contributor (FP)-MG``, disabled the generating of API keys for Application Insights. `[SAA-4612] <https://jira.office01.internalcorp.net:8443/browse/SAA-4612>`__


.. warning:: Note that using the ``Microsoft.Graph`` PowerShell module in your pipelines might break your scripts after switching to the new pool due to a change in the ``Connect-MgGraph`` command needs. Please adapt your scripts to be compatible with major version 2 of the ``Microsoft.Graph`` PowerShell module. Also other tool upgrades may affect your codebase. For more information, see section **PowerShell** in the article :doc:`Scripting knowledge <../../Application-development/Scripting-guide>`.
