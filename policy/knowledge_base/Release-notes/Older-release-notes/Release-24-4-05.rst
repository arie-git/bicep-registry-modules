Release 24-4 05
===============
Release date: December 3, 2024

.. warning:: Breaking change: DRCP enforces the Load Balancer Private IP in frontend configuration. `[SAA-10168] <https://jira.office01.internalcorp.net:8443/browse/SAA-10168>`__

.. warning:: Breaking change: DRCP enforces the minimum TLS 1.2 protocol version for Application Gateway production Environments. `[SAA-9969] <https://jira.office01.internalcorp.net:8443/browse/SAA-9969>`__

.. warning:: Breaking change: DRCP blocks deleting the LTR backup of SQL Database. `[SAA-9664] <https://jira.office01.internalcorp.net:8443/browse/SAA-9664>`__

.. warning:: Upcoming breaking change: During **Release 25-1 03** (January 14, 2025), the Azure DevOps agent pool ``CPP-Ubuntu2204-Latest`` is removed. Please make sure to either use ``CPP-Ubuntu2204-Latest-A`` or ``CPP-Ubuntu2204-Latest-B`` in case of using the ``Latest`` agent version. `[SAA-11044] <https://jira.office01.internalcorp.net:8443/browse/SAA-11044>`__

.. warning:: Upcoming breaking change: During **Release 25-1 01** (December 17, 2024), DRCP enforces all route tables to have the property 'disableBGPRoutePropagation' set to 'false'. `[SAA-7578] <https://jira.office01.internalcorp.net:8443/browse/SAA-7578>`__

Fixed issues
------------
- Fixed an issue where the automated controls for Databricks failed. `[SAA-11123] <https://jira.office01.internalcorp.net:8443/browse/SAA-11123>`__

What's new for users
--------------------
- Set Application Gateway policy to prevent using older TLS version then version 1.2 to Deny for Environments with usage Production. `[SAA-10443] <https://jira.office01.internalcorp.net:8443/browse/SAA-10443>`__
- Set policy ``APG DRCP Load Balancer Private IP only in frontend`` to Deny for Environments with usage Production. `[SAA-10168] <https://jira.office01.internalcorp.net:8443/browse/SAA-10168>`__
- Allow also deployments to Environments with usage Acceptance or Production from ADO tags based on the main branch. See :doc:`Build and release pipelines <../../Application-development/Azure-devops/Build-and-release-pipelines>`. `[SAA-8437] <https://jira.office01.internalcorp.net:8443/browse/SAA-8437>`__
- Added TLS 1.3 support for App Services Environments and updated all policies with minimum TLS 1.2 values, so no traces of TLS 1.0 and TLS 1.1 are present. `[SAA-9963] <https://jira.office01.internalcorp.net:8443/browse/SAA-9963>`__
- Adjusted policy ``APG DRCP Log Analytics Workspace Disable data exports`` to allow data exports to Storage Accounts in the same Subscription. `[SAA-10975] <https://jira.office01.internalcorp.net:8443/browse/SAA-10975>`__
- Released :doc:`Azure services <../../Azure-components/AI-Services>` Azure OpenAI and AI Language as beta components to the first Application Systems responsible for beta testing. `[SAA-9586] <https://jira.office01.internalcorp.net:8443/browse/SAA-9586>`__ and `[SAA-8515] <https://jira.office01.internalcorp.net:8443/browse/SAA-8515>`__.
- Released :doc:`Azure AI Search <../../Azure-components/AI-Search>` as beta component to the first Application Systems responsible for beta testing. `[SAA-8562] <https://jira.office01.internalcorp.net:8443/browse/SAA-8562>`__
- Added documentation about :doc:`Azure Policies and Exemptions <../../Platform/Policies-controls-and-exemptions>`. `[SAA-9424] <https://jira.office01.internalcorp.net:8443/browse/SAA-9424>`__
- Set policy ``APG DRCP Network Route Table Disable BGP route propagation`` to audit for all usages. `[SAA-7578] <https://jira.office01.internalcorp.net:8443/browse/SAA-7578>`__
- Adjusted role :doc:`APG Custom - DRCP - Contributor <../../Getting-started/Roles-and-authorizations>` to block LTR backup deletion for SQL Database. `[SAA-9664] <https://jira.office01.internalcorp.net:8443/browse/SAA-9664>`__
- Added roles :doc:`APG Custom - DRCP - Contributor - DEV/TST/ACC/PRD <../../Getting-started/Roles-and-authorizations>` to split the current `APG Custom - DRCP - Contributor` per usage. `[SAA-10857] <https://jira.office01.internalcorp.net:8443/browse/SAA-10857>`__

Preparing for the future
------------------------
- Set the 'disableBGPRoutePropagation' property on route tables to 'false' and change your Environments routing version to 'V2.1' in ServiceNow to prepare for the breaking network change in release 25-1 01.
- Added widget for policies in the DRDC portal for upcoming policy integration in ServiceNow.
