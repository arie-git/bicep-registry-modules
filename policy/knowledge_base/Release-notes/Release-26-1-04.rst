Release 26-1 04
===============
Release date: January 27, 2026

.. warning::
  | **Breaking changes**

  - DRCP configures policy ``APG DRCP ACR Connected Registries disabled`` effect from `audit` to `deny` for usages `development` and `test`. `[SAA-17578] <https://jira.office01.internalcorp.net:8443/browse/SAA-17578>`__
  - DRCP configures policy ``APG DRCP App Service Site Slot Audit outbound non-RFC 1918 traffic into Azure Virtual Network`` effect from `disabled` to `deny` for usages `acceptance` and `production`. `[SAA-17431] <https://jira.office01.internalcorp.net:8443/browse/SAA-17431>`__
  - DRCP configures policy ``APG DRCP App Service Site Audit outbound non-RFC 1918 traffic into Azure Virtual Network`` effect from `disabled` to `deny` for usages `acceptance` and `production`. `[SAA-17431] <https://jira.office01.internalcorp.net:8443/browse/SAA-17431>`__

.. warning::
  | **Upcoming breaking changes**

  - In upcoming **Release 26-1 05**, DRCP configures policy ``APG DRCP ACR Connected Registries disabled`` effect from `audit` to `deny` for usages `acceptance` and `production`. `[SAA-17595] <https://jira.office01.internalcorp.net:8443/browse/SAA-17595>`__
  - In upcoming **Release 26-1 05**, DRCP configures policy ``APG DRCP AI Search Allow approved API versions`` allowed and default values `2024-06-01-preview`, `2021-04-01-Preview`, `2024-03-01-Preview` and `2025-02-01-Preview` get removed. `[SAA-17374] <https://jira.office01.internalcorp.net:8443/browse/SAA-17374>`__


What's new for users
--------------------
- Added controls in the :doc:`Security baseline Monitor <../Azure-components/Monitor/Security-Baseline>` and :doc:`Incident remediation Monitor <../Azure-components/Monitor/Incident-remediation>` documentation for Azure Managed Grafana. `[SAA-16507] <https://jira.office01.internalcorp.net:8443/browse/SAA-16507>`__
- Added policies that belong to the controls in the :doc:`Security baseline Monitor <../Azure-components/Monitor/Security-Baseline>` for Azure Managed Grafana. `[SAA-16507] <https://jira.office01.internalcorp.net:8443/browse/SAA-16525>`__
- Removed post actions from Required-pipeline-templates and :doc:`Required-pipeline-templates <../Application-development/Azure-devops/Required-pipeline-templates>` `[SAA-16241] <https://jira.office01.internalcorp.net:8443/browse/SAA-16241>`__
- Promoted :doc:`component Redis <../Azure-components/Redis>` to MVP status. `[SAA-15867] <https://jira.office01.internalcorp.net:8443/browse/SAA-15867>`__
- Removed control ``drcp-evh-09`` from the :doc:`Security baseline Event Hubs <../Azure-components/Event-Hubs/Security-Baseline>` and :doc:`Incident remediation Event Hubs <../Azure-components/Event-Hubs/Incident-remediation>` documentation. `[SAA-17958] <https://jira.office01.internalcorp.net:8443/browse/SAA-17958>`__


Internal platform improvements
------------------------------
- Performed LCM for :doc:`Data Factory <../../Azure-components/Data-factory>`. `[SAA-16342] <https://jira.office01.internalcorp.net:8443/browse/SAA-16342>`__.
- Performed quartely update of Business Continuity Design in the DRCP wiki. `[SAA-16489] <https://jira.office01.internalcorp.net:8443/browse/SAA-16489>`__.
- Fixed an issue in the Databricks collector where it would break when trying to retrieve older connnection versions. `[SAA-17916] <https://jira.office01.internalcorp.net:8443/browse/SAA-17916>`__.
- Removed policies:  ``AppServiceSiteVNetRouteAllTEMP`` and ``AppServiceSiteSlotVNetRouteAllTEMP``. `[SAA-17431] <https://jira.office01.internalcorp.net:8443/browse/SAA-17431>`__
- Performed LCM for :doc:`Azure DevOps <../../Application-development/Azure-devops>`. `[SAA-12507] <https://jira.office01.internalcorp.net:8443/browse/SAA-12507>`__.
- Performed LCM for PSScriptAnalyzer. `[SAA-14987] <https://jira.office01.internalcorp.net:8443/browse/SAA-14987>`__.
