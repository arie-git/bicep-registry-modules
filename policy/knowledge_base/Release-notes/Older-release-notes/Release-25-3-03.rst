Release 25-3 03
===============
Release date: July 29, 2025

.. warning:: | In upcoming **Release 25-3 04**, DRCP removes these 2 policies from all Environments, preventing automatic ServiceNow incident registration for Key Vault secrets and keys expiring in the nearby future. Ensure to setup alerting through the DRCP-delivered Azure Monitor Action Groups if desired. `[SAA-15041] <https://jira.office01.internalcorp.net:8443/browse/SAA-15041>`__:

  - ``Keys should have more than the specified number of days before expiration``
  - ``Secrets should have more than the specified number of days before expiration``

What's new for users
--------------------
- Added baseline control ``drcp-amo-04`` to the :doc:`Azure Monitor (beta) security baseline <../../Azure-components/Monitor/Security-Baseline>`. `[SAA-14136] <https://jira.office01.internalcorp.net:8443/browse/SAA-14136>`__
- Added page :doc:`Incident remediation Azure Monitor <../../Azure-components/Monitor/Incident-remediation>`. `[SAA-14136] <https://jira.office01.internalcorp.net:8443/browse/SAA-14136>`__
- Added Azure policies (in Audit mode for all usages) in alignment with the :doc:`Azure Monitor (beta) security baseline <../../Azure-components/Monitor/Security-Baseline>`. `[SAA-14136] <https://jira.office01.internalcorp.net:8443/browse/SAA-14136>`__
- Added a custom DRCP ADO task that make it possible to update a change from your pipeline. More information on the :doc:`DRCPAdoServiceNow task <../../Application-development/Azure-devops/Custom-drcp-ado-tasks>`.  `[SAA-14379] <https://jira.office01.internalcorp.net:8443/browse/SAA-14379>`__
- Adjusted :doc:`Databricks use cases <../../Azure-components/Databricks/Use-cases>` for ``DLT`` pipelines. `[SAA-14355] <https://jira.office01.internalcorp.net:8443/browse/SAA-14355>`__

Fixed issues
------------
- Updated the :doc:`Notification Hubs Incident Remediation page <../../Azure-components/Notification-Hubs/Incident-remediation>` to align with the security baseline of Notification Hubs. `[SAA-6772] <https://jira.office01.internalcorp.net:8443/browse/SAA-6772>`__
- Updated the metadata of DRCP Azure policies to align with the security baselines on the KB. `[SAA-14136] <https://jira.office01.internalcorp.net:8443/browse/SAA-14136>`__
- Added check on ``DRCP.API.Authentication`` role to the DRCP API. `[SAA-14766] <https://jira.office01.internalcorp.net:8443/browse/SAA-14766>`__

Internal platform improvements
------------------------------
- DRCP took the next step in adding conditional access to App registrations, by applying conditional access to App registrations in the internal DRCP PRD-stack. Customer App registrations aren't affected. `[SAA-7275] <https://jira.office01.internalcorp.net:8443/browse/SAA-7275>`__
