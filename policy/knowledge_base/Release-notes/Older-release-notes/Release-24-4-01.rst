Release 24-4 01
===============
Release date: October 8, 2024

.. warning:: Upcoming breaking change: During upcoming releases, DRCP enforces the enablement of zone redundancy for Cosmos DB production Environments. `[SAA-9149] <https://jira.office01.internalcorp.net:8443/browse/SAA-9149>`__

.. note:: In upcoming releases, DRCP redeploys Action Group ``DRCP-EnvironmentCode-ActionGroup`` to the region of the Environment. Do not use this Action Group until further notice. `[SAA-9389] <https://jira.office01.internalcorp.net:8443/browse/SAA-9389>`__

Fixed issues
------------
- Fixed an issue where the Cinc collector for Databricks provided false positives due to wrong inputs for control drcp-adb-w04. `[SAA-9809] <https://jira.office01.internalcorp.net:8443/browse/SAA-9809>`__
- Fixed an issue where the Cinc collector for Databricks failed due to removed config keys. `[SAA-10069] <https://jira.office01.internalcorp.net:8443/browse/SAA-10069>`__
- Improved the user experience for the ``Add Private Link service ID`` Quick action. `[SAA-7462] <https://jira.office01.internalcorp.net:8443/browse/SAA-7462>`__
- Fixed an issue where the creation or update of an Application system failed due to renamed permissions by Microsoft. `[SAA-10096] <https://jira.office01.internalcorp.net:8443/browse/SAA-10096>`__

What's new for users
--------------------
- Removed DRCP Alert Rules ``DRCP-EnvironmentCode-AuditPolicyEffectAlertRule`` and ``DRCP-EnvironmentCode-DenyPolicyEffectAlertRule`` since DRCP implements a new alerting method this PI. `[SAA-9475] <https://jira.office01.internalcorp.net:8443/browse/SAA-9475>`__
- Adjusted policy ``APG DRCP Generic Deny resource deletion`` that denied the deletion of the DRCP Action Group and Alert Rules. `[SAA-9475] <https://jira.office01.internalcorp.net:8443/browse/SAA-9475>`__
- Added extension attribute ``extension_aa2d81d469c9428d9eab99c0dba92066_extensionAttribute2`` for SailPoint to the Microsoft Entra ID group automation for DRCP Application systems. `[SAA-9844] <https://jira.office01.internalcorp.net:8443/browse/SAA-9844>`__
- Adjusted policy ``APG DRCP Storage Account Shared Key Access should be disabled`` to report Storage Accounts for Logic/Function Apps with the `shared key access <https://learn.microsoft.com/en-us/azure/storage/common/storage-account-keys-manage?tabs=azure-portal>`__ feature enabled as compliant. This requires the appropriate tag configured and restricted use to Logic/Function App. See documentation :doc:`here <../../Azure-components/App-Service/Use-cases>`. `[SAA-9890] <https://jira.office01.internalcorp.net:8443/browse/SAA-9890>`__
- Added the :doc:`Security baseline for Azure AI Search <../../Azure-components/AI-Search/Security-Baseline>` to the KB. `[SAA-8534] <https://jira.office01.internalcorp.net:8443/browse/SAA-8534>`__
- Added the :doc:`Security baseline for Language <../../Azure-components/AI-services/Security-Baseline>` to the KB. `[SAA-8484] <https://jira.office01.internalcorp.net:8443/browse/SAA-8484>`__
- Implemented the Azure policies for Azure AI Search. `[SAA-8548] <https://jira.office01.internalcorp.net:8443/browse/SAA-8548>`__

Preparing for the future
------------------------
- Created an API endpoint in ServiceNow to store Azure policy metadata for compliance reporting. `[SAA-9194] <https://jira.office01.internalcorp.net:8443/browse/SAA-9194>`__
