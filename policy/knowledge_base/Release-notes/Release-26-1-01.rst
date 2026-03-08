Release 26-1 01
===============
Release date: December 16, 2025

.. note:: DRCP combines upcoming releases 02 and 03 in a single release, **Release 26-1 03**, on January 13, 2026.

.. warning::
  | **Breaking changes**

  - In this release, DRCP configures policy ``APG DRCP PostgreSQL Restrict administrator principals`` effect from `audit` to `deny` for usages `development` and `test`. `[SAA-17199] <https://jira.office01.internalcorp.net:8443/browse/SAA-17199>`__

.. warning::
  | **Upcoming breaking changes**

  - In upcoming **Release 26-1 03**, DRCP configures policy ``APG DRCP PostgreSQL Restrict administrator principals`` effect from `audit` to `deny` for usages `acceptance` and `production`. `[SAA-17199] <https://jira.office01.internalcorp.net:8443/browse/SAA-17199>`__
  - In upcoming **Release 26-1 03**, DRCP configures policy ``APG DRCP TEMP App Service Site Slot Audit outbound non-RFC 1918 traffic into Azure Virtual Network`` effect from `audit` to `deny` for usages `development` and `test`. `[SAA-17425] <https://jira.office01.internalcorp.net:8443/browse/SAA-17425>`__
  - In upcoming **Release 26-1 03**, DRCP configures policy ``APG DRCP TEMP App Service Site Audit outbound non-RFC 1918 traffic into Azure Virtual Network`` effect from `audit` to `deny` for usages `development` and `test`. `[SAA-17425] <https://jira.office01.internalcorp.net:8443/browse/SAA-17425>`__
  - In upcoming **Release 26-1 04**, DRCP configures policy ``APG DRCP TEMP App Service Site Slot Audit outbound non-RFC 1918 traffic into Azure Virtual Network`` effect from `audit` to `deny` for usages `acceptance` and `production`. `[SAA-17431] <https://jira.office01.internalcorp.net:8443/browse/SAA-17431>`__
  - In upcoming **Release 26-1 04**, DRCP configures policy ``APG DRCP TEMP App Service Site Audit outbound non-RFC 1918 traffic into Azure Virtual Network`` effect from `audit` to `deny` for usages `acceptance` and `production`. `[SAA-17431] <https://jira.office01.internalcorp.net:8443/browse/SAA-17431>`__
  - In upcoming **Release 26-1 04**, DRCP configures policy ``APG DRCP ACR Connected Registries disabled`` effect from `audit` to `deny` for usages `development` and `test`. `[SAA-17578] <https://jira.office01.internalcorp.net:8443/browse/SAA-17578>`__
  - In upcoming **Release 26-1 05**, DRCP configures policy ``APG DRCP ACR Connected Registries disabled`` effect from `audit` to `deny` for usages `acceptance` and `production`. `[SAA-17595] <https://jira.office01.internalcorp.net:8443/browse/SAA-17595>`__
  - In upcoming **Release 26-1 05**, DRCP configures policy ``APG DRCP AI Search Allow approved API versions`` allowed and default values `2024-06-01-preview`, `2021-04-01-Preview`, `2024-03-01-Preview` and `2025-02-01-Preview` get removed. `[SAA-17374] <https://jira.office01.internalcorp.net:8443/browse/SAA-17374>`__

What's new for users
--------------------
- DRCP automated the (re)creation of JFrog Artifactory projects and their associated Azure DevOps service connections whenever an Application system gets created or refreshed. `[SAA-16364] <https://jira.office01.internalcorp.net:8443/browse/SAA-16364>`__
- Improved the alert severity instruction in the :doc:`Custom Alerts Rules documentation <../Platform/Alerts-and-incidents/Custom-Alerts>`. `[SAA-16688] <https://jira.office01.internalcorp.net:8443/browse/SAA-16688>`__.
- Improved the alert description in e-mails from ServiceNow. `[SAA-16247] <https://jira.office01.internalcorp.net:8443/browse/SAA-16247>`__.
- Updated the Web App language version ``APG DRCP App Service Site Linux [language] version`` policies for .Net, Java, Node.js, PHP, Python, and Tomcat. `[SAA-8660] <https://jira.office01.internalcorp.net:8443/browse/SAA-8660>`__
- Updated the Web App language version ``APG DRCP App Service Site Slot Linux [language] version`` policies for .Net, Java, Node.js, PHP, Python, and Tomcat. `[SAA-8660] <https://jira.office01.internalcorp.net:8443/browse/SAA-8660>`__
- Updated the Function App language version ``APG DRCP App Service Function App Linux [language] version`` policies for .Net, Java, Node.js, and Python. `[SAA-8660] <https://jira.office01.internalcorp.net:8443/browse/SAA-8660>`__
- Updated the Function App language version ``APG DRCP App Service Function App Slot [language] version`` policies for .Net, Java, Node.js, and Python. `[SAA-8660] <https://jira.office01.internalcorp.net:8443/browse/SAA-8660>`__
- Updated supported language versions for Web Apps and Function Apps from :doc:`Use cases App Service <../../Azure-components/App-Service/Use-cases>` of the KB. `[SAA-8660] <https://jira.office01.internalcorp.net:8443/browse/SAA-8660>`__
- Added policy to disallow the usage of `Connected Registries` with Azure Container Registries. `[SAA-15471] <https://jira.office01.internalcorp.net:8443/browse/SAA-15471>`__
- Enhanced documentation in the Knowledge Base on changing the Azure DevOps :doc:`User profile <../Application-development/Azure-devops/User-profile>` `[SAA-13814] <https://jira.office01.internalcorp.net:8443/browse/SAA-13814>`__
- Added DRCP policy ``APG DRCP ACR Connected Registries disabled`` to disallow the use of `Connected Registries` with Azure Container Registries. `[SAA-15471] <https://jira.office01.internalcorp.net:8443/browse/SAA-15471>`__
- Added DRCP policy ``APG DRCP Azure Monitor Managed Grafana register private endpoint in Private DNS Zone`` for :doc:`Azure Monitor Managed Grafana <../../Azure-components/Monitor>`. `[SAA-16513] <https://jira.office01.internalcorp.net:8443/browse/SAA-16513>`__.
- Added security baseline control ``drcp-amg-01`` to the :doc:`Azure Monitor security baseline <../../Azure-components/Monitor/Security-Baseline>`. `[SAA-16513] <https://jira.office01.internalcorp.net:8443/browse/SAA-16513>`__.
- Updated :doc:`Use cases App Configuration <../Azure-components/App-Configuration/Use-cases>` with tier, encryption and provisioning possibilities. `[SAA-8362] <https://jira.office01.internalcorp.net:8443/browse/SAA-8362>`__

Fixed issues
------------
- Fixed an issue where the Azure DevOps security baseline controls failed for projects without service connections. `[SAA-17455] <https://jira.office01.internalcorp.net:8443/browse/SAA-17455>`__.
- Changed ``disabledDataExfiltrationOptions`` to ``dataExfiltrationProtections`` in DRCP policy ``APG DRCP AI Search Disabled Data ex-filtration``. `[SAA-17368] <https://jira.office01.internalcorp.net:8443/browse/SAA-17368>`__.
- Fixed an issue where the ``Add VNet address space`` Quick action failed on Environments with usage `production`. `[SAA-17525] <https://jira.office01.internalcorp.net:8443/browse/SAA-17525>`__.

Internal platform improvements
------------------------------
- Added AI search approved API version ``2025-05-01`` to be able to use ``dataExfiltrationProtections`` in DRCP policy ``APG DRCP AI Search Disabled Data ex-filtration``. `[SAA-17368] <https://jira.office01.internalcorp.net:8443/browse/SAA-17368>`__.
- Improved the internal LCM instruction for the DRCP Azure components. `[SAA-16688] <https://jira.office01.internalcorp.net:8443/browse/SAA-16688>`__.
- Performed LCM for :doc:`Storage Account <../../Azure-components/Storage-Account>`. `[SAA-16427] <https://jira.office01.internalcorp.net:8443/browse/SAA-16427>`__.
- Performed LCM for :doc:`Notification Hubs <../../Azure-components/Notification-Hubs>`. `[SAA-16481] <https://jira.office01.internalcorp.net:8443/browse/SAA-16481>`__.
- Added :doc:`Redis <../../Azure-components/Redis>` to the internal DRCP regression tests. `[SAA-16124] <https://jira.office01.internalcorp.net:8443/browse/SAA-16124>`__.
- Migrated ServiceTag import into ServiceNow from Landing zone 3 accent to the DRCP Platform. `[SAA-14923] <https://jira.office01.internalcorp.net:8443/browse/SAA-14923>`__.
- Prepared internal DRCP regression tests for testing SSH enablement and end-to-end encryption on :doc:`App Service <../../Azure-components/App-Service>`. `[SAA-8358] <https://jira.office01.internalcorp.net:8443/browse/SAA-8358>`__.
- Performed LCM for :doc:`AI Search <../../Azure-components/AI-Search>`. `[SAA-16714] <https://jira.office01.internalcorp.net:8443/browse/SAA-16714>`__.
