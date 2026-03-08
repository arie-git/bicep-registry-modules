Release 24-4 02
===============
Release date: October 22, 2024

.. warning:: Upcoming breaking change: During upcoming releases, DRCP enforces the enablement of zone redundancy for Cosmos DB production Environments. `[SAA-9149] <https://jira.office01.internalcorp.net:8443/browse/SAA-9149>`__

.. warning:: Upcoming breaking change: During upcoming releases, DRCP enforces the Load Balancer Private IP in frontend configuration. `[SAA-10168] <https://jira.office01.internalcorp.net:8443/browse/SAA-10168>`__

Fixed issues
------------
- Fixed an issue where no metastore assignment for a workspace resulted in a pipeline error for the "Run automated control" pipeline. `[SAA-10091] <https://jira.office01.internalcorp.net:8443/browse/SAA-10091>`__
- Fixed an issue where the Cinc collector for Databricks provided false positives due to wrong implementation for control drcp-adb-w21 and corrected description for drcp-adb-w05. `[SAA-9290] <https://jira.office01.internalcorp.net:8443/browse/SAA-9290>`__
- Fixed an issue where the Cinc collector for Databricks provided false positives due to wrong implementation for control drcp-adb-w04. `[SAA-10147] <https://jira.office01.internalcorp.net:8443/browse/SAA-10147>`__

What's new for users
--------------------
- Removed DRCP Alert Rules temporary removal script from the Environment automation, that removed the ``DRCP-EnvironmentCode-AuditPolicyEffectAlertRule`` and ``DRCP-EnvironmentCode-DenyPolicyEffectAlertRule`` since DRCP implements a new alerting method this PI. `[SAA-9475] <https://jira.office01.internalcorp.net:8443/browse/SAA-9475>`__
- Added baseline control metadata to all DRCP policies. `[SAA-9910] <https://jira.office01.internalcorp.net:8443/browse/SAA-9910>`__
- During maintenance or refresh of an Environment, DRCP redeploys Action Group ``DRCP-EnvironmentCode-ActionGroup`` to the region of the Environment. The Action Group remains in ``Global`` region for older West Europe based Environments. Don't use this Action Group until further notice. `[SAA-9389] <https://jira.office01.internalcorp.net:8443/browse/SAA-9389>`__
- Added network changes documentation in the :doc:`Networking <../../Platform/Networking>` page. `[SAA-9788] <https://jira.office01.internalcorp.net:8443/browse/SAA-9788>`__
- The :doc:`LLDC DNS API <../../Platform/DRCP-API/Endpoint-for-dns-assignment>` is now available to register DNS records (A and CNAME) for these zones: ``azurebase.net``, ``azurebase.local``, and ``appserviceenvironment.net``. `[SAA-8288] <https://jira.office01.internalcorp.net:8443/browse/SAA-8288>`__
- Added the :doc:`LLDC DNS API <../../Platform/DRCP-API/Endpoint-for-dns-assignment>` testing to the internal DRCP regression tests . `[SAA-8293] <https://jira.office01.internalcorp.net:8443/browse/SAA-8293>`__
- Added policy ``APG DRCP Load Balancer Private IP only in frontend`` to prevent usage of Load Balancer public addresses. The policy is in audit . `[SAA-10152] <https://jira.office01.internalcorp.net:8443/browse/SAA-10152>`__
- Added a :doc:`role <../../Getting-started/Roles-and-authorizations>` ``Production Operator`` to the Application system which provides Reader and assignable Roles to Environments with usage production. `[SAA-9859] <https://jira.office01.internalcorp.net:8443/browse/SAA-9859>`__
- Added Quick action in ServiceNow to change the routing version from V1 to V2.1 (and vice versa) on Environments. The routing version on Environments stays the same unless explicitly changed through this Quick action. `[SAA-8876] <https://jira.office01.internalcorp.net:8443/browse/SAA-8876>`__
- Newly created Environments have their routing versions set to V2.1 by default. `[SAA-9849] <https://jira.office01.internalcorp.net:8443/browse/SAA-9849>`__
- Added SQL Import/Export documentation in the :doc:`Use cases SQL Database <../../Azure-components/SQL-Database/Use-cases>` page. `[SAA-8795] <https://jira.office01.internalcorp.net:8443/browse/SAA-8795>`__
- Added the :doc:`Security baseline for OpenAI and Language <../../Azure-components/AI-services/Security-Baseline>` in the KB. `[SAA-9566] <https://jira.office01.internalcorp.net:8443/browse/SAA-9566>`__

Preparing for the future
------------------------
- Added policy ``APG DRCP Network Route table routes next hop type internet for BGP`` to prevent default outbound access. The policy remains disabled. `[SAA-9755] <https://jira.office01.internalcorp.net:8443/browse/SAA-9755>`__
- Added DRCP Policy Metadata Collector for managing Azure Policies in ServiceNow. `[SAA-9189] <https://jira.office01.internalcorp.net:8443/browse/SAA-9189>`__
- Created the possibility to recieve events from Azure Monitoring in ServiceNow. `[SAA-9219] <https://jira.office01.internalcorp.net:8443/browse/SAA-9219>`__
