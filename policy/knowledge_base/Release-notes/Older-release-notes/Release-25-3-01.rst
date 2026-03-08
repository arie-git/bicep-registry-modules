Release 25-3 01
===============
Release date: July 1, 2025

What's new for users
--------------------
- DRCP allows download from data in Databricks to clients by removing security baselines `drcp-adb-w06` and `drcp-adb-w07`. `[SAA-14606] <https://jira.office01.internalcorp.net:8443/browse/SAA-14606>`__
- Added Subscription tags ``DRCPLastRefreshCoreBranch`` and ``DRCPLastRefreshDateTimeUtc`` to clarify when and by which core automation branch the Environment was last refreshed. `[SAA-14175] <https://jira.office01.internalcorp.net:8443/browse/SAA-14175>`__
- Added LCM review of April 2025 in :doc:`Use Cases Kubernetes Service <../../Azure-components/Kubernetes-Service/Use-cases>`. `[SAA-8347] <https://jira.office01.internalcorp.net:8443/browse/SAA-8347>`__
- Added draft pages of beta component :doc:`Azure Monitor <../../Azure-components/Monitor>`. `[SAA-14124] <https://jira.office01.internalcorp.net:8443/browse/SAA-14124>`__
- Removed ``RBACNewDRCPContributorRole`` policy because it referenced an obsolete role assignment ID. `[SAA-14684] <https://jira.office01.internalcorp.net:8443/browse/SAA-14684>`__

Fixed issues
------------
- DRCP no longer removes owners from non protected branches in Azure DevOps. `[SAA-14594] <https://jira.office01.internalcorp.net:8443/browse/SAA-14594>`__
- DRCP fixed an issue where the PO wasn't assigned as approver for Azure Privileged Identity Management (PIM) (INC0561691). `[SAA-14614] <https://jira.office01.internalcorp.net:8443/browse/SAA-14614>`__
- DRCP fixed an issue where the Environment groups weren't added to the Azure policies (INC0561683, INC0561952). `[SAA-14620] <https://jira.office01.internalcorp.net:8443/browse/SAA-14620>`__
- DRCP fixed an issue where the ``RBACAllowedDataRoles`` policy blocked Engineer privileged groups in Environments with usage Test and Acceptance from assigning data roles (INC0562792, INC0562803). `[SAA-14722] <https://jira.office01.internalcorp.net:8443/browse/SAA-14722>`__
- DRCP fixed an issue for Quick action ``Add VNet address space`` where the reservation failed. `[SAA-14754] <https://jira.office01.internalcorp.net:8443/browse/SAA-14754>`__

Internal platform improvements
------------------------------
- DRCP took the first step in adding conditional access to App registrations, by applying conditional access to App registrations in the internal DRCP DEV-stack. Customer App registrations aren't affected. `[SAA-7261] <https://jira.office01.internalcorp.net:8443/browse/SAA-7261>`__