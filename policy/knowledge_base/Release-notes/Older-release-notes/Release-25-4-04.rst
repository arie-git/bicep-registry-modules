Release 25-4 04
===============
Release date: November 18, 2025

.. warning::
  | **Breaking changes**

  - DRCP resets the permissions on individual repositories and pipelines in Azure DevOps. `[SAA-16178] <https://jira.office01.internalcorp.net:8443/browse/SAA-16178>`__

What's new for users
--------------------
- DRCP will perform scheduled baseline runs every Wednesday for all Application systems. `[SAA-13927] <https://jira.office01.internalcorp.net:8443/browse/SAA-13927>`__
- Added ``@apg-am.com``, ``@apg-am.hk``, and ``@apg-am.sg`` as email domains to the ADO repository policy ``Commit author email validation``.  `[SAA-16253] <https://jira.office01.internalcorp.net:8443/browse/SAA-16253>`__
- Updated Redis with improved & simplified blocking of public network access, because Microsoft released a new property for the Azure Policy Engine. `[SAA-16295] <https://jira.office01.internalcorp.net:8443/browse/SAA-16295>`__
  - Updated :doc:`Security baseline Redis <../../Azure-components/Redis/Security-Baseline>` and :doc:`Incident remediation Redis <../../Azure-components/Redis/Incident-remediation>` by consolidating ``drcp-redis-02`` and ``drcp-redis-03`` to ``drcp-redis-02``, because of simplified blocking of public network access.
  - Added DRCP policy ``APG DRCP Redis Disable public network access`` instead of adding 2 policies to block public network access.
  - Updated :doc:`Use cases Redis <../../Azure-components/Redis/Use-cases>` on Inbound Access.
- Released beta component :doc:`Redis <../../../Azure-components/Redis>` for FB-DWS CCC. `[SAA-16163] <https://jira.office01.internalcorp.net:8443/browse/SAA-16163>`__

Fixed issues
------------
- Fixed an issue where the ``Invoke-BuildChangeCompletion`` pipeline couldn't update affected CI's on closed changes. `[SAA-16373] <https://jira.office01.internalcorp.net:8443/browse/SAA-16373>`__
- Fixed an issue where permission deviations on single repositories and pipelines in Azure DevOps weren't corrected. `[SAA-16178] <https://jira.office01.internalcorp.net:8443/browse/SAA-16178>`__

Internal platform improvements
------------------------------
- Added step to the ``Invoke-GarbageCollection`` pipeline to match the Azure hub peerings with Infoblox and vice versa. `[SAA-13978] <https://jira.office01.internalcorp.net:8443/browse/SAA-13978>`__
- Added filter to the ``Invoke-GarbageCollection`` pipeline tasks ``Check EntraID`` and ``Check Mule`` to filter the garbage based on the stack. `[SAA-16403] <https://jira.office01.internalcorp.net:8443/browse/SAA-16403>`__
- Added filter to the ``Invoke-GarbageCollection`` pipeline task ``Check Azure Subscription`` to filter the garbage based on the stack. `[SAA-16555] <https://jira.office01.internalcorp.net:8443/browse/SAA-16555>`__
- Added filter to the ``Invoke-GarbageCollection`` pipeline task ``Check Infoblox`` to filter the garbage based on the stack. `[SAA-16577] <https://jira.office01.internalcorp.net:8443/browse/SAA-16577>`__
- Added filter to the ``Invoke-GarbageCollection`` pipeline task ``Check ADO`` to filter the garbage based on the stack. `[SAA-16566] <https://jira.office01.internalcorp.net:8443/browse/SAA-16566>`__
- Performed LCM for internal BCD (Business Continuity Design) documents `[SAA-11889] <https://jira.office01.internalcorp.net:8443/browse/SAA-11889>`__
- Performed LCM for :doc:`Container Registry (ACR) <../../../Azure-components/Container-Registry>`. `[SAA-15460] <https://jira.office01.internalcorp.net:8443/browse/SAA-15460>`__
- Performed LCM for :doc:`SQL Database <../../Azure-components/SQL-Database>`. `[SAA-8345] <https://jira.office01.internalcorp.net:8443/browse/SAA-8345>`__
- Performed LCM for :doc:`Application Gateway  <../../../Azure-components/Application-Gateway>`. `[SAA-15477] <https://jira.office01.internalcorp.net:8443/browse/SAA-15477>`__
- Performed LCM for :doc:`Cosmos-DB  <../../../Azure-components/Cosmos-DB>`. `[SAA-9295] <https://jira.office01.internalcorp.net:8443/browse/SAA-9295>`__
