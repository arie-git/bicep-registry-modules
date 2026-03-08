Release 26-1 05.1
=================
Release date: February 10, 2026

.. warning::
  | **Breaking changes**

  - DRCP configures policy ``APG DRCP ACR Connected Registries disabled`` effect from `audit` to `deny` for usages `acceptance` and `production`. `[SAA-17595] <https://jira.office01.internalcorp.net:8443/browse/SAA-17595>`__
  - DRCP configures policy ``APG DRCP AI Search Allow approved API versions`` allowed and default values `2024-06-01-preview`, `2021-04-01-Preview`, `2024-03-01-Preview` and `2025-02-01-Preview` get removed. `[SAA-17374] <https://jira.office01.internalcorp.net:8443/browse/SAA-17374>`__
  - DRCP configures policy ``APG DRCP Azure Monitor Data Collection Rules Restrict Data Collection Endpoint`` effect from `audit` to `deny` for all usages. `[SAA-15716] <https://jira.office01.internalcorp.net:8443/browse/SAA-15716>`__

Preparing for the future
------------------------
- Extended the create Environment pipeline to call FrontDoor API for ADO service connection principal. `[SAA-17211] <https://jira.office01.internalcorp.net:8443/browse/SAA-17211>`__
- Updated the :doc:`list of allowed DNS zones to manage <../Platform/DRCP-API/Endpoint-for-dns-assignment>` for the DNS API. `[SAA-18077] <https://jira.office01.internalcorp.net:8443/browse/SAA-18077>`__

What's new for users
--------------------
- Managed Prometheus is now in MVP state. `[SAA-15710] <https://jira.office01.internalcorp.net:8443/browse/SAA-15710>`__

Fixed issues
------------
- Fixed an issue where the `Business Continuity backup` failed. `[SAA-18083] <https://jira.office01.internalcorp.net:8443/browse/SAA-18083>`__
- Fixed an issue where pipelines couldn't pull templates from the ACR. `[SAA-18181] <https://jira.office01.internalcorp.net:8443/browse/SAA-18181>`__
- Fixed an issue on policy ``APG DRCP AI Search Disabled Data ex-filtration`` where the behavior changed after 2025-02-01 API version. The allowed value 'All' is added to the existing value `BlockAll` for older API versions. `[SAA-17374] <https://jira.office01.internalcorp.net:8443/browse/SAA-17374>`__
- Fixed an issue on policy ``APG DRCP Azure Monitor Data Collection Rules Restrict Data Collection Endpoint`` blocking the removing of data collection endpoints from the data collection rules with the policy effect set to `deny`. `[SAA-15716] <https://jira.office01.internalcorp.net:8443/browse/SAA-15716>`__

Internal platform improvements
------------------------------
- Moved DRCP pipelines to ubuntu2404 agent pools for organization ``b957a78843eb1``. `[SAA-13654] <https://jira.office01.internalcorp.net:8443/browse/SAA-13654>`__
- Moved DRCP pipelines to ubuntu2404 agent pools for organization ``connectdrcpdevapg1`` and ``connectdrcpaccapg1`` . `[SAA-13660] <https://jira.office01.internalcorp.net:8443/browse/SAA-13660>`__
- Removed unused Business Continuity objects. `[SAA-18065] <https://jira.office01.internalcorp.net:8443/browse/SAA-18065>`__
- Improved DRCP policy automation, enabling editing and removing of parameters on deployed policy sets. `[SAA-18193] <https://jira.office01.internalcorp.net:8443/browse/SAA-18193>`__
- Performed LCM for Bicep API versions. `[SAA-11655] <https://jira.office01.internalcorp.net:8443/browse/SAA-11655>`__.
