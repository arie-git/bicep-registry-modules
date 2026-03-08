Release 23-3 07
===============
Release date: September 26, 2023


What's new for users
--------------------
- The built-in Azure RBAC roles belonging to DRCP MVP components are now restricted to certain identities. For more info, please see the documentation :doc:`here <../../Azure-components/Subscription/Role-Based-Access-Control-policies>`. `[SAA-3498] <https://jira.office01.internalcorp.net:8443/browse/SAA-3498>`__
- Added documentation for ``admin consent`` in :doc:`App registrations <../../Platform/Microsoft-Entra-ID/App-registrations>`. `[SAA-4151] <https://jira.office01.internalcorp.net:8443/browse/SAA-4151>`__
- Added a warning note in the dialog that appears when a user tries to remove an environment. `[SAA-4158] <https://jira.office01.internalcorp.net:8443/browse/SAA-4158>`__
- Added user documentation for :doc:`Log Analytics Workspaces <../../Azure-components/Log-Analytics-Workspace/Use-cases>` & :doc:`Application Insights <../../Azure-components/Application-Insights/Use-cases>`. `[SAA-3417] <https://jira.office01.internalcorp.net:8443/browse/SAA-3417>`__
- Added a new custom role named ``APG Custom - DRCP - Monitoring Contributor (FP)-MG)``, which allows all Monitoring Contributor actions except for listing Log Analytics Workspace Agent keys. `[SAA-3417] <https://jira.office01.internalcorp.net:8443/browse/SAA-3417>`__
- Disabled ``Monitoring Contributor`` and ``Automation Contributor`` builtin roles because these allow for listing the Log Analytics Workspace agent keys. `[SAA-3417] <https://jira.office01.internalcorp.net:8443/browse/SAA-3417>`__
- Updated the effect of the Local authentication policy for Application Insights to "Audit" due to this being a breaking change. `[SAA-3417] <https://jira.office01.internalcorp.net:8443/browse/SAA-3417>`__
- A Subscription-level diagnostic setting which exports data to QRadar. `[SAA-3503] <https://jira.office01.internalcorp.net:8443/browse/SAA-3503>`__


Fixed issues
------------
- Fixed an issue where the Infoblox call failed when the Grid Master moves to another Grid Member. `[SAA-4533] <https://jira.office01.internalcorp.net:8443/browse/SAA-4533>`__
- Fixed an issue where two LLDC service principals weren't whitelisted from the ``Monitoring Contributor`` role, resulting in an incompliant policy ``APG DRCP RBAC Monitoring Contributor role``. `[SAA-3417] <https://jira.office01.internalcorp.net:8443/browse/SAA-3417>`__
- Updated the DRCP automation to be compatible with upcoming breaking changes in ``Microsoft.Graph`` PowerShell module version 2.x. `[SAA-3851] <https://jira.office01.internalcorp.net:8443/browse/SAA-3851>`__
- Updated the DRCP automation to set the default DRCP tags to all auto generated resources, such as the Network Watcher.  `[SAA-3115] <https://jira.office01.internalcorp.net:8443/browse/SAA-3115>`__
- Fixed an issue where the removal of an environment sometimes failed when the APIs of Microsoft weren't in sync (yet).  `[SAA-4449] <https://jira.office01.internalcorp.net:8443/browse/SAA-4449>`__
- Fixed an issue where approvals on Quick actions were sometimes skipped.  `[SAA-4764] <https://jira.office01.internalcorp.net:8443/browse/SAA-4764>`__
- Merged the Knowledge base Quick action pages into a single :doc:`Quick action <../../Platform/DRDC-portal/Quick-actions>` page and created a new :doc:`Approval overview <../../Platform/DRDC-portal/Approval-overview>` page. `[SAA-4764] <https://jira.office01.internalcorp.net:8443/browse/SAA-4764>`__


Preparing for the future
------------------------
- The policy effect for the built-in Azure RBAC roles belonging to DRCP MVP components will change from "Audit" to "Deny" in next release on October 10th 2023. Please prepare and check if your environments are compliant to this policy before the policy effect becomes "Deny." `[SAA-3498] <https://jira.office01.internalcorp.net:8443/browse/SAA-3498>`__
- The policy effect for the local authentication for Application Insights will change from "Audit" to "Deny" in next release on October 10th 2023. Please prepare and check if your environments are compliant to this policy before the policy effect becomes "Deny." `[SAA-3417] <https://jira.office01.internalcorp.net:8443/browse/SAA-3417>`__
- A new Azure DevOps build agent pool (``H01-P1-Infrastructure-BuildAgent-Ubuntu-latest`` with a recent image version) is now **in preview** available to test if there is an impact on your code. Please note that this new pool might not be fully configured yet. The current image version of pool ``H01-P1-Infrastructure-BuildAgent-MAN03-pool`` is ``20230517.1``. There will be another announcement later on how to act on the future lifecycle of the agent pools and their image versions. `[SAA-4383] <https://jira.office01.internalcorp.net:8443/browse/SAA-4383>`__

.. warning:: Note that using the ``Microsoft.Graph`` PowerShell module in your pipelines might break your scripts after switching to the new pool due to a change in the ``Connect-MgGraph`` command needs. Please adapt your scripts to be compatible with major version 2 of the ``Microsoft.Graph`` PowerShell module. Also other tool upgrades may affect your codebase. For more information, see section **PowerShell** in the article :doc:`Scripting knowledge <../../Application-development/Scripting-guide>`.
