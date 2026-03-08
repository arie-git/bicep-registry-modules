Release 25-4 01
===============
Release date: October 7, 2025

.. warning::
  | **Breaking changes**

  - DRCP configures these 4 policies from audit effect to deny effect for usages `acceptance` and `production` (effective all usages). `[SAA-14897] <https://jira.office01.internalcorp.net:8443/browse/SAA-14879>`__:

    - ``APG DRCP Azure Monitor Action Group Only allow APG email domains in alert receivers``
    - ``APG DRCP Azure Monitor Action Group Only allow approved domains in webhook receivers``
    - ``APG DRCP Azure Monitor Data Collection Rule Destination Log Analytics Workspace``
    - ``APG DRCP Azure Monitor Data Collection Rule Destination Storage Account``

  - DRCP restores (re-enables) :doc:`Azure Monitor <../../Azure-components/Monitor>` policy ``APG DRCP Application Insights disable local authentication`` and control ``drcp-appi-01`` with a condition on tag key ``usedBy`` and tag value ``PublicSource`` to allow local authentication methods. Application Insights instances without this tag become incompliant when configured with local authentication enabled. `[SAA-14160] <https://jira.office01.internalcorp.net:8443/browse/SAA-14160>`__
  - DRCP removes the allowed IP addresses of ``MTEL`` from policy ``APG DRCP Network Deny routes with next hop type Internet bypassing central firewalls`` for usages `development`, `test`, and `acceptance`. `[SAA-13679] <https://jira.office01.internalcorp.net:8443/browse/SAA-13679>`__
  - DRCP configures policy ``APG DRCP StorageAccount Encryption all services enabled`` from audit effect to deny effect for usages `development` and `test`. `[SAA-15887] <https://jira.office01.internalcorp.net:8443/browse/SAA-15887>`__
  - In upcoming **Release 25-4 03**, DRCP sets the policy ``"APG DRCP Contributor role targets"`` audit effect to deny effect for all usages. `[SAA-16085] <https://jira.office01.internalcorp.net:8443/browse/SAA-16085>`__

What's new for users
--------------------
- The Environment request dialog in the DRDC portal now sets the maintenance day default to the current day of the week. `[SAA-15987] <https://jira.office01.internalcorp.net:8443/browse/SAA-15987>`__
- Renamed the request ``Request an Azure policy exemption`` to ``Request a DRCP exception``. You can now request an exception for a security baseline run. `[SAA-11697] <https://jira.office01.internalcorp.net:8443/browse/SAA-11697>`__
- Updated :doc:`Use cases Redis <../../Azure-components/Redis/Use-cases>` with Data Persistence. `[SAA-15803] <https://jira.office01.internalcorp.net:8443/browse/SAA-15803>`__
- Added DRCP policy ``APG DRCP Contributor role targets`` with effect audit. `[SAA-11635] <https://jira.office01.internalcorp.net:8443/browse/SAA-11635>`__

Fixed issues
------------
- Fixed an issue where an approval email is send to all users in the support group when the approval group is empty. `[SAA-6200] <https://jira.office01.internalcorp.net:8443/browse/SAA-6200>`__

Internal platform improvements
------------------------------
- It's now technical possible to start an Azure pipeline in a different internal Azure DevOps organizations from ServiceNow. `[SAA-15809] <https://jira.office01.internalcorp.net:8443/browse/SAA-15809>`__
- Completed :doc:`Incident remediation for Databricks <../../Azure-components/Databricks/Incident-remediation>`. `[SAA-15928] <https://jira.office01.internalcorp.net:8443/browse/SAA-15928>`__

Internal platform improvements
------------------------------
- Authorized build service accounts in `development` and `acceptance` stack for extended template. `[SAA-13408] <https://jira.office01.internalcorp.net:8443/browse/SAA-13408>`__
