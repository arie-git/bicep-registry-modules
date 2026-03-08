Release 25-1 01
===============
Release date: December 17, 2024

.. warning:: The peering to the hub disconnects for a brief moment during maintenance to complete the migration of Environment routing from V1 to V2.1. `[SAA-7578] <https://jira.office01.internalcorp.net:8443/browse/SAA-7578>`__

.. warning:: Breaking change: DRCP enforces all route tables to have the property 'disableBGPRoutePropagation' set to 'false' by configuring the effect of policy ``APG DRCP Network Route Table Disable BGP route propagation`` to Deny. `[SAA-7578] <https://jira.office01.internalcorp.net:8443/browse/SAA-7578>`__

.. warning:: Breaking change: Policy ``APG DRCP RBAC Role assignments principal type`` updates from Audit-mode to Deny-mode to prevent direct RBAC assignments to user objects. `[SAA-11382] <https://jira.office01.internalcorp.net:8443/browse/SAA-11382>`__

.. warning:: Upcoming breaking change: During **Release 25-1 03** (January 14, 2025), the Azure DevOps agent pool ``CPP-Ubuntu2204-Latest`` is removed. Please make sure to either use ``CPP-Ubuntu2204-Latest-A`` or ``CPP-Ubuntu2204-Latest-B`` in case of using the ``Latest`` agent version. `[SAA-11044] <https://jira.office01.internalcorp.net:8443/browse/SAA-11044>`__


What's new for users
--------------------
- The Quick action "Remove Environment" now checks if there are resources left in the Subscription, if so it's impossible submit the request. `[SAA-10844] <https://jira.office01.internalcorp.net:8443/browse/SAA-10844>`__
- Completed the migration of Environment routing from V1 to V2.1 by enforcing BGP. `[SAA-7578] <https://jira.office01.internalcorp.net:8443/browse/SAA-7578>`__
- Implemented :doc:`Security baseline for Azure AI Search <../../Azure-components/AI-Search/Security-Baseline>`, policies and regression tests for disabling data ex-filtration possibility and enforcing certain API versions. `[SAA-11105] <https://jira.office01.internalcorp.net:8443/browse/SAA-11105>`__
- Completed missing metadata in all DRCP policies and updated the :doc:`Security baseline Subscription <../../Azure-components/Subscription/Subscription-Baseline>` to cover all policies related to baseline controls. `[SAA-10264] <https://jira.office01.internalcorp.net:8443/browse/SAA-10264>`__
- Added documentation :doc:`Tools for OpenTofu <../../Application-development/Tools/OpenTofu>` about the use of OpenTofu in Azure DevOps pipelines via Artifactory. `[SAA-9424] <https://jira.office01.internalcorp.net:8443/browse/SAA-9424>`__
- Implemented :doc:`Data protection and backup <../../Azure-components/SQL-Database/Use-cases>` to prevent deletion of an Environment with usage Production that holds on SQL LTR Backup `[SAA-9669] <https://jira.office01.internalcorp.net:8443/browse/SAA-9669>`__
- Extended documentation about routing on page :doc:`Networking <../../Platform/Networking>` . `[SAA-10732] <https://jira.office01.internalcorp.net:8443/browse/SAA-10732>`__
- Added documentation to page :doc:`Use cases SQL Database <../../Azure-components/SQL-Database/Use-cases>` about the removal request for Long Term Retention (LTR) SQL Database Backups. `[SAA-9659] <https://jira.office01.internalcorp.net:8443/browse/SAA-9659>`__
- Added option "Remove SQL Azure Backup" to the "`Request a manual action by SIS (Azure) <https://apgprd.service-now.com/drdc?id=drdc_sc_item&source=drdc_sc_ce_index&table=sc_category&sys_id=8bcfc88e87f5f1505ee3eb583cbb3543>`__ " request form in ServiceNow. `[SAA-9659] <https://jira.office01.internalcorp.net:8443/browse/SAA-9659>`__
- Added Quick action "Request support access for LZ3" to allow Inspark/Microsoft support access. For more information, see :doc:`InSpark/ Microsoft support <../../Need-help>`. `[SAA-9608] <https://jira.office01.internalcorp.net:8443/browse/SAA-9608>`__ and `[SAA-9616] <https://jira.office01.internalcorp.net:8443/browse/SAA-9616>`__
- Adjusted policy ``APG DRCP AI services Allow supported kinds`` to disallow OpenAI kind. `[SAA-11201] <https://jira.office01.internalcorp.net:8443/browse/SAA-11201>`__
- Enabled `shared private link <https://learn.microsoft.com/en-us/azure/search/search-indexer-howto-access-private?tabs=portal-create>`__ between AI Search and other supported data sources. `[SAA-11311] <https://jira.office01.internalcorp.net:8443/browse/SAA-11311>`__
- Created policies ``APG DRCP AI Search Network Private endpoints private link service connection`` and ``APG DRCP AI services Network Private endpoints private link service connections`` for preventing cross-Subscription private links in AI components. `[SAA-11323] <https://jira.office01.internalcorp.net:8443/browse/SAA-11323>`__
- Added :doc:`Use cases for OpenAI <../../Azure-components/AI-services/Use-cases>` to the KB. `[SAA-10377] <https://jira.office01.internalcorp.net:8443/browse/SAA-10377>`__
- Added :doc:`Use cases for AI Search <../../Azure-components/AI-Search/Use-cases>` to the KB. `[SAA-10342] <https://jira.office01.internalcorp.net:8443/browse/SAA-10342>`__
- Migrated existing DRCP role assignments for the role ``APG Custom - DRCP - Contributor (FP-MG)`` to role ``APG Custom - DRCP - Contributor (FP-MG) - (usage)``. `[SAA-11287] <https://jira.office01.internalcorp.net:8443/browse/SAA-11287>`__
- Added policy ``APG DRCP RBAC New custom contributor role`` which audits for the old DRCP custom contributor role assignments. `[SAA-11287] <https://jira.office01.internalcorp.net:8443/browse/SAA-11287>`__
- Restructured the SSL certificate information on the KB and added externally signed SSL certificate documentation. See section :doc:`Certificates <../../Application-development/Certificates>` . `[SAA-11354] <https://jira.office01.internalcorp.net:8443/browse/SAA-11354>`__
- Added documentation for the new component Notification Hubs which is in development: :doc:`Security baseline Notification Hubs <../../Azure-components/Notification-Hubs/Security-Baseline>`, :doc:`Use cases Notification Hubs <../../Azure-components/Notification-Hubs/Use-cases>` and :doc:`Incident remediation Notification Hubs <../../Azure-components/Notification-Hubs/Incident-remediation>`. `[SAA-6772] <https://jira.office01.internalcorp.net:8443/browse/SAA-6772>`__
- Standby is available from January when necessary for critical incidents outside office hours. For more information see :doc:`the support page <../../Need-help>`. `[SAA-9679] <https://jira.office01.internalcorp.net:8443/browse/SAA-9679>`__

Fixed issues
------------
- The automatic import of whitelisted Azure ServiceTags in the IP ACL of ServiceNow stopped working due to removal of the source URL by Microsoft. The integration now uses the Azure Management API. `[SAA-11347] <https://jira.office01.internalcorp.net:8443/browse/SAA-11347>`__
- The effect of policy ``APG DRCP RBAC Role assignments principal type`` updates from Audit-mode to Deny-mode to prevent direct RBAC assignments to user objects. `[SAA-11382] <https://jira.office01.internalcorp.net:8443/browse/SAA-11382>`__
- The automated controls for Databricks stopped working due to a change in the Databricks SDK for vector search. DRCP changed the error handling for the new working of the Databricks SDK.  `[SAA-11414] <https://jira.office01.internalcorp.net:8443/browse/SAA-11414>`__
