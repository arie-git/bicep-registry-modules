Release 25-3 04
===============
Release date: August 12, 2025

.. warning:: | In this release, DRCP removes these 2 policies from all Environments, disabling automatic ServiceNow incident registration for Key Vault secrets and keys expiring in the nearby future. Ensure to setup alerting through the DRCP-delivered Azure Monitor Action Groups if desired. `[SAA-15041] <https://jira.office01.internalcorp.net:8443/browse/SAA-15041>`__:

  - ``Keys should have more than the specified number of days before expiration``
  - ``Secrets should have more than the specified number of days before expiration``

What's new for users
--------------------
- Added pages :doc:`Controls <../../Platform/Policies-controls-and-exemptions/Controls>` and :doc:`Control exemptions <../../Platform/Policies-controls-and-exemptions/DRCP-exceptions>`. `[SAA-12446] <https://jira.office01.internalcorp.net:8443/browse/SAA-12446>`__
- Removed 2 Key Vault policies, that were out of scope of the security baseline. `[SAA-15041] <https://jira.office01.internalcorp.net:8443/browse/SAA-15041>`__
- Added the possibility to add allowed WAF rule exclusions. To get rules added to the allowed WAF rules exclusions list see :doc:`WAF rule exclusion <../../Platform/Policies-controls-and-exemptions/WAF-rule-exclusion>`. `[SAA-13321] <https://jira.office01.internalcorp.net:8443/browse/SAA-13321>`__
- Added new KB pages for beta component Azure Cache for Redis. `[SAA-14201] <https://jira.office01.internalcorp.net:8443/browse/SAA-14201>`__
  - :doc:`Security baseline Redis <../../Azure-components/Redis/Security-Baseline>`
  - :doc:`Incident remediation Redis <../../Azure-components/Redis/Incident-remediation>`
  - :doc:`Use cases Redis <../../Azure-components/Redis/Use-cases>`

Fixed issues
------------
- Fixed bug in policy ``DRCP App Service Site Slot Allowed FTP mode``. `[SAA-15054] <https://jira.office01.internalcorp.net:8443/browse/SAA-15054>`__

Internal platform improvements
------------------------------
- Added authentication for ``ADOCommit API``. `[SAA-14760] <https://jira.office01.internalcorp.net:8443/browse/SAA-14760>`__
