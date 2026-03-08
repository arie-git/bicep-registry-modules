Release 25-4 02
===============
Release date: October 21, 2025

.. warning::
  | **Breaking changes**

  - DRCP removes the allowed IP addresses of ``MTEL`` from policy ``APG DRCP Network Deny routes with next hop type Internet bypassing central firewalls`` for usage `production`. `[SAA-13703] <https://jira.office01.internalcorp.net:8443/browse/SAA-13703>`__
  - In upcoming **Release 25-4 03**, DRCP sets the policy ``APG DRCP Contributor role targets`` effect from 'audit' to 'deny' for all usages. `[SAA-16085] <https://jira.office01.internalcorp.net:8443/browse/SAA-16085>`__
  - In upcoming **Release 25-4 04**, DRCP resets the permissions on individual repositories and pipelines In Azure DevOps. `[SAA-16178] <https://jira.office01.internalcorp.net:8443/browse/SAA-16178>`__
  - DRCP configures policy ``APG DRCP StorageAccount Encryption all services enabled`` effect from `audit` to `deny` for usages `acceptance` and `production`. `[SAA-15888] <https://jira.office01.internalcorp.net:8443/browse/SAA-15888>`__

What's new for users
--------------------
- Extended the :doc:`Use cases Azure Monitor <../../Azure-components/Monitor/Use-cases>` documentation. `[SAA-14249] <https://jira.office01.internalcorp.net:8443/browse/SAA-14249>`__
- Added DRCP policy ``APG DRCP VNet protection`` with effect `deny`. `[SAA-15377] <https://jira.office01.internalcorp.net:8443/browse/SAA-15377>`__
- Added new KB pages for beta component Azure Managed Redis. DRCP will stop with Azure Cache for Redis as beta component, because of deprecation starting in October 2026. `[SAA-16092] <https://jira.office01.internalcorp.net:8443/browse/SAA-16092>`__
  - :doc:`Security baseline Redis <../../Azure-components/Redis/Security-Baseline>`
  - :doc:`Incident remediation Redis <../../Azure-components/Redis/Incident-remediation>`
  - :doc:`Use cases Redis <../../Azure-components/Redis/Use-cases>`

Fixed issues
------------
- Fixed the Azure DevOps task for not finding the build service account.  `[SAA-16001] <https://jira.office01.internalcorp.net:8443/browse/SAA-16001>`__
- Fixed the Azure DevOps task for reporting on differences between the authorization model and individual repositories and pipelines in Azure DevOps. `[SAA-13985] <https://jira.office01.internalcorp.net:8443/browse/SAA-13985>`__

Internal platform improvements
------------------------------
- Moved artifacts for Azure DevOps tasks to JFrog Artifactory. `[SAA-12611] <https://jira.office01.internalcorp.net:8443/browse/SAA-12611>`__
