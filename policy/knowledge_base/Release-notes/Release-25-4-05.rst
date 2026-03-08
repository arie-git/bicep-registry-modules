Release 25-4 05
===============
Release date: December 2, 2025

.. warning::
  | **Upcoming breaking changes**

  - In upcoming **Release 26-1 01**, DRCP configures policy ``APG DRCP PostgreSQL Restrict administrator principals`` effect from `audit` to `deny` for usages `development` and `test`. `[SAA-17199] <https://jira.office01.internalcorp.net:8443/browse/SAA-17199>`__
  - In upcoming **Release 26-1 02**, DRCP configures policy ``APG DRCP PostgreSQL Restrict administrator principals`` effect from `audit` to `deny` for usages `acceptance` and `production`. `[SAA-17199] <https://jira.office01.internalcorp.net:8443/browse/SAA-17199>`__
  - In upcoming **Release 26-1 03**, DRCP configures policy ``APG DRCP TEMP App Service Site Slot Audit outbound non-RFC 1918 traffic into Azure Virtual Network`` effect from `audit` to `deny` for usages `development` and `test`. `[SAA-17425] <https://jira.office01.internalcorp.net:8443/browse/SAA-17425>`__
  - In upcoming **Release 26-1 03**, DRCP configures policy ``APG DRCP TEMP App Service Site Audit outbound non-RFC 1918 traffic into Azure Virtual Network`` effect from `audit` to `deny` for usages `development` and `test`. `[SAA-17425] <https://jira.office01.internalcorp.net:8443/browse/SAA-17425>`__

What's new for users
--------------------
- Added policy ``APG DRCP PostgreSQL Restrict administrator principals`` with effect `audit` that limits the PostgreSQL flexible server administrators to the Engineer group (`development` usage), privileged Engineer group (all other usages), and Azure DevOps deployment principal (all usages). `[SAA-16336] <https://jira.office01.internalcorp.net:8443/browse/SAA-16336>`__
- Updated security baseline control ``drcp-psql-03`` to align with the new policy ``APG DRCP PostgreSQL Restrict administrator principals``. `[SAA-16336] <https://jira.office01.internalcorp.net:8443/browse/SAA-16336>`__
- Updated the :doc:`Frequently asked questions <../Frequently-asked-questions>` page with instructions on how to find the DRCP policy parameter values within the Azure portal. `[SAA-17199] <https://jira.office01.internalcorp.net:8443/browse/SAA-17199>`__
- Updated the :doc:`Exception process <../Processes/Exception>` page with references to the new APG exception process. `[SAA-4810] <https://jira.office01.internalcorp.net:8443/browse/SAA-4810>`__
- Disabled policy ``APG DRCP App Service Site Slot Audit outbound non-RFC 1918 traffic into Azure Virtual Network`` to fix the App Service API version issues with the current iteration of this policy. `[SAA-17392] <https://jira.office01.internalcorp.net:8443/browse/SAA-17392>`__
- Disabled policy ``APG DRCP App Service Site Audit outbound non-RFC 1918 traffic into Azure Virtual Network`` to fix the App Service API version issues with the current iteration of this policy. `[SAA-17392] <https://jira.office01.internalcorp.net:8443/browse/SAA-17392>`__
- Added temporary policy ``APG DRCP TEMP App Service Site Slot Audit outbound non-RFC 1918 traffic into Azure Virtual Network`` with effect `audit` which fixes the issues with the existing iteration of this policy. `[SAA-17392] <https://jira.office01.internalcorp.net:8443/browse/SAA-17392>`__
- Added temporary policy ``APG DRCP TEMP App Service Site Audit outbound non-RFC 1918 traffic into Azure Virtual Network`` with effect `audit` which fixes the issues with the existing iteration of this policy. `[SAA-17392] <https://jira.office01.internalcorp.net:8443/browse/SAA-17392>`__

Fixed issues
------------
- Fixed an issue by removing the deprecated resource provider ``Microsoft.ChangeAnalysis``. `[SAA-17205] <https://jira.office01.internalcorp.net:8443/browse/SAA-17205>`__
- Fixed an issue where the removal of an Environment failed when there was no Infoblox reservation. `[SAA-17411] <https://jira.office01.internalcorp.net:8443/browse/SAA-17411>`__.
- Fixed an issue where the Garbage collection failed on a single report item. `[SAA-17417] <https://jira.office01.internalcorp.net:8443/browse/SAA-17417>`__
- Fixed policy ``APG DRCP App Service Site routing to Azure Virtual Network`` to fix the App Service API version issues with the current iteration of this policy. `[SAA-17392] <https://jira.office01.internalcorp.net:8443/browse/SAA-17392>`__
- Fixed policy ``APG DRCP App Service Site Slot routing to Azure Virtual Network`` to fix the App Service API version issues with the current iteration of this policy. `[SAA-17392] <https://jira.office01.internalcorp.net:8443/browse/SAA-17392>`__
- Fixed an issue where the garbage collection process didn't filter correct on the ``Check EntraID`` step. `[SAA-17380] <https://jira.office01.internalcorp.net:8443/browse/SAA-17380>`__

Internal platform improvements
------------------------------
- Updated documentation for :doc:`Database for PostgreSQL flexible server <../Azure-components/PostgreSQL/Use-cases>`. `[SAA-11823] <https://jira.office01.internalcorp.net:8443/browse/SAA-11823>`__
- Updated the internal list of allowed built-in RBAC roles for future use. `[SAA-14690] <https://jira.office01.internalcorp.net:8443/browse/SAA-14690>`__
- Added the usage of  OAuth authentication in stead of PAT tokens for ADO authentication. `[SAA-16265] <https://jira.office01.internalcorp.net:8443/browse/SAA-16265>`__
