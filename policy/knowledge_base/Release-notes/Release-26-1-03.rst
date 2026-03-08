Release 26-1 03
===============
Release date: January 13, 2026

.. note:: DRCP combines releases 02 and 03 in a single release, **Release 26-1 03**, on January 13, 2026.

.. warning::
  | **Breaking changes**

  - DRCP configures policy ``APG DRCP PostgreSQL Restrict administrator principals`` effect from `audit` to `deny` for usages `acceptance` and `production`. `[SAA-17386] <https://jira.office01.internalcorp.net:8443/browse/SAA-17386>`__
  - DRCP configures policy ``APG DRCP TEMP App Service Site Slot Audit outbound non-RFC 1918 traffic into Azure Virtual Network`` effect from `audit` to `deny` for usages `development` and `test`. `[SAA-17425] <https://jira.office01.internalcorp.net:8443/browse/SAA-17425>`__
  - DRCP configures policy ``APG DRCP TEMP App Service Site Audit outbound non-RFC 1918 traffic into Azure Virtual Network`` effect from `audit` to `deny` for usages `development` and `test`. `[SAA-17425] <https://jira.office01.internalcorp.net:8443/browse/SAA-17425>`__

.. warning::
  | **Upcoming breaking changes**

  - In upcoming **Release 26-1 04**, DRCP configures policy ``APG DRCP TEMP App Service Site Audit outbound non-RFC 1918 traffic into Azure Virtual Network`` effect from `audit` to `deny` for usages `acceptance` and `production`. `[SAA-17431] <https://jira.office01.internalcorp.net:8443/browse/SAA-17431>`__
  - In upcoming **Release 26-1 04**, DRCP configures policy ``APG DRCP TEMP App Service Site Slot Audit outbound non-RFC 1918 traffic into Azure Virtual Network`` effect from `audit` to `deny` for usages `acceptance` and `production`. `[SAA-17431] <https://jira.office01.internalcorp.net:8443/browse/SAA-17431>`__
  - In upcoming **Release 26-1 04**, DRCP configures policy ``APG DRCP ACR Connected Registries disabled`` effect from `audit` to `deny` for usages `development` and `test`. `[SAA-17578] <https://jira.office01.internalcorp.net:8443/browse/SAA-17578>`__
  - In upcoming **Release 26-1 05**, DRCP configures policy ``APG DRCP ACR Connected Registries disabled`` effect from `audit` to `deny` for usages `acceptance` and `production`. `[SAA-17595] <https://jira.office01.internalcorp.net:8443/browse/SAA-17595>`__
  - In upcoming **Release 26-1 05**, DRCP configures policy ``APG DRCP AI Search Allow approved API versions`` allowed and default values `2024-06-01-preview`, `2021-04-01-Preview`, `2024-03-01-Preview` and `2025-02-01-Preview` get removed. `[SAA-17374] <https://jira.office01.internalcorp.net:8443/browse/SAA-17374>`__


What's new for users
--------------------
- DRCP increased the pipeline retention period to 120 days. `[SAA-17603] <https://jira.office01.internalcorp.net:8443/browse/SAA-17603>`__
- Added OpenAI GPT models: ``gpt-4.1``, ``gpt-4.1-mini``, ``gpt-4.1-nano``, ``gpt-5``, ``gpt-5-mini``, ``gpt-5-nano``, ``gpt-5-chat``, ``gpt-5.1``, ``gpt-5.1-chat`` in DRCP policy ``APG DRCP OpenAI Allow approved models`` find more information :doc:`here <../../Azure-components/AI-Services>`. `[SAA-16736] <https://jira.office01.internalcorp.net:8443/browse/SAA-16736>`__
- Adjusted :doc:`Databricks Use cases <../../Azure-components/Databricks/Use-cases>`. `[SAA-8354] <https://jira.office01.internalcorp.net:8443/browse/SAA-8354>`__.

Internal platform improvements
------------------------------

- Performed LCM for :doc:`OpenAI <../../Azure-components/AI-Services>`. `[SAA-16704] <https://jira.office01.internalcorp.net:8443/browse/SAA-16704>`__.
- Performed LCM for :doc:`Databricks <../../Azure-components/Databricks>`. `[SAA-13863] <https://jira.office01.internalcorp.net:8443/browse/SAA-13863>`__.
- Performed LCM for :doc:`AI Language <../../Azure-components/AI-Services>`. `[SAA-16694] <https://jira.office01.internalcorp.net:8443/browse/SAA-16694>`__.
- Finalized :doc:`Use cases Redis <../Azure-components/Redis/Use-cases>` by removing under construction line. `[SAA-15861] <https://jira.office01.internalcorp.net:8443/browse/SAA-15861>`__.
- Performed LCM for ADO Commit API. `[SAA-16271] <https://jira.office01.internalcorp.net:8443/browse/SAA-16271>`__.
