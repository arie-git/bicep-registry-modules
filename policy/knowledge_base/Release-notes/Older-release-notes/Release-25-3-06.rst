Release 25-3 06
===============
Release date: September 9, 2025

.. warning:: | In this release, DRCP configures these 4 policies from Audit-effect to Deny-effect for usages Development and Test. `[SAA-14142] <https://jira.office01.internalcorp.net:8443/browse/SAA-14142>`__:

  - ``APG DRCP Azure Monitor Action Group Only allow APG email domains in alert receivers``
  - ``APG DRCP Azure Monitor Action Group Only allow approved domains in webhook receivers``
  - ``APG DRCP Azure Monitor Data Collection Rule Destination Log Analytics Workspace``
  - ``APG DRCP Azure Monitor Data Collection Rule Destination Storage Account``

What's new for users
--------------------
- Updated Azure policy ``APG DRCP Kubernetes Services should be upgraded to a non-vulnerable Kubernetes version`` with only version 1.32 or higher as supported. `[SAA-15267] <https://jira.office01.internalcorp.net:8443/browse/SAA-15267>`__
- Incidents reported by "Event Manager" will now close on removal of the associated environment. These include incidents created due to policy and control violations. `[SAA-14672] <https://jira.office01.internalcorp.net:8443/browse/SAA-14672>`__
- Added check on tag based releases in ADO, see :doc:`Branch protection <../../Application-development/Azure-devops/Branch-protection>`. `[SAA-15163] <https://jira.office01.internalcorp.net:8443/browse/SAA-15163>`__
- Removed baseline control ``drcp-appi-01`` and related Azure policy ``APG DRCP Application Insights disable local authentication`` to align with the scope of the new Azure Monitor component (beta). `[SAA-14160] <https://jira.office01.internalcorp.net:8443/browse/SAA-14160>`__
- Released beta component :doc:`Redis <../../Azure-components/Redis>` for FB-DWS CCC and SWP. `[SAA-14261] <https://jira.office01.internalcorp.net:8443/browse/SAA-14261>`__

Fixed issues
------------
- Fixed defect in the Cinc auditor test. `[SAA-15096] <https://jira.office01.internalcorp.net:8443/browse/SAA-15096>`__
- Fixed policy ``APG DRCP Redis Minimum TLS version`` where a fictive TLSv1.3 test wasn't removed. `[SAA-14213] <https://jira.office01.internalcorp.net:8443/browse/SAA-14213>`__
- Fixed product owner variable in Application system maintenance workflow. `[SAA-15681] <https://jira.office01.internalcorp.net:8443/browse/SAA-15681>`__

Internal platform improvements
------------------------------
- Added :doc:`Azure Monitor <../../Azure-components/Monitor>` tests to the internal DRCP regression tests. `[SAA-14142] <https://jira.office01.internalcorp.net:8443/browse/SAA-14142>`__
- Updated non-compliant test for AKS version in the internal DRCP regression tests. `[SAA-15267] <https://jira.office01.internalcorp.net:8443/browse/SAA-15267>`__

