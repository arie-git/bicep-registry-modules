Release 25-3 07
===============
Release date: September 23, 2025

.. warning:: | In upcoming **Release 25-4 01**, DRCP configures these 4 policies from Audit-effect to Deny-effect for usages Acceptance and Production (effective all usages). `[SAA-14142] <https://jira.office01.internalcorp.net:8443/browse/SAA-14142>`__:

  - ``APG DRCP Azure Monitor Action Group Only allow APG email domains in alert receivers``
  - ``APG DRCP Azure Monitor Action Group Only allow approved domains in webhook receivers``
  - ``APG DRCP Azure Monitor Data Collection Rule Destination Log Analytics Workspace``
  - ``APG DRCP Azure Monitor Data Collection Rule Destination Storage Account``

.. warning:: | In upcoming **Release 25-4 01**, DRCP restores (re-enables) :doc:`Azure Monitor <../../Azure-components/Monitor>` policy ``APG DRCP Application Insights disable local authentication`` and control ``drcp-appi-01`` with a condition on tag key ``usedBy`` and tag value ``PublicSource`` to allow local authentication methods. Application Insights instances without this tag become incompliant when configured with local authentication enabled. `[SAA-14160] <https://jira.office01.internalcorp.net:8443/browse/SAA-14160>`__

.. warning:: | In upcoming **Release 25-4 01**, DRCP configures policy ``APG DRCP StorageAccount Encryption all services enabled`` from Audit-effect to Deny-effect for usages Development and Test. `[SAA-12795] <https://jira.office01.internalcorp.net:8443/browse/SAA-12795>`__:

.. warning:: | In upcoming **Release 25-4 01**, DRCP removes the allowed IP addresses of ``MTEL`` from policy ``APG DRCP Network Deny routes with next hop type Internet bypassing central firewalls`` for usages Development, Test, and Acceptance. `[SAA-13679] <https://jira.office01.internalcorp.net:8443/browse/SAA-13679>`__

What's new for users
--------------------
- Released beta component :doc:`Azure Monitor <../../Azure-components/Monitor>`. `[SAA-14160] <https://jira.office01.internalcorp.net:8443/browse/SAA-14160>`__
- Added Azure policies ``APG DRCP Azure Monitor Data Collection Rules Restrict Data Collection Endpoint`` and ``APG DRCP Azure Monitor Data Collection Rules Restrict destination Azure Monitor Workspace`` `[SAA-13217] <https://jira.office01.internalcorp.net:8443/browse/SAA-13217>`__
- Reviewed and updated :doc:`Azure DevOps documentation <../../Application-development/Azure-devops>`. `[SAA-12409] <https://jira.office01.internalcorp.net:8443/browse/SAA-12409>`__
- Released capability :doc:`Managed Prometheus <../../Azure-components/Kubernetes-Service/Use-cases>` for AKS. `[SAA-13248] <https://jira.office01.internalcorp.net:8443/browse/SAA-13248>`__

Fixed issues
------------
- Fixed automatic authorization of 'Azure Pipelines' agent pool. `[SAA-15821] <https://jira.office01.internalcorp.net:8443/browse/SAA-15821>`__
- Fixed policy ``APG DRCP StorageAccount Encryption all services enabled`` with enforcement of option ``all service types``. `[SAA-12795] <https://jira.office01.internalcorp.net:8443/browse/SAA-12795>`__

Internal platform improvements
------------------------------
- Removed temporary Azure DevOps pipeline, script and test branches. `[SAA-15130] <https://jira.office01.internalcorp.net:8443/browse/SAA-15130>`__
- Moved the internal code quality checks to central CodeQuality repository. `[SAA-14511] <https://jira.office01.internalcorp.net:8443/browse/SAA-14511>`__
- Published DRCP PowerShell modules to JFrog/Artifactory for use in all Azure DevOps projects in the internal Azure DevOps organization. `[SAA-4923] <https://jira.office01.internalcorp.net:8443/browse/SAA-4923>`__
- Pinned all internal and external PowerShell modules for all Azure DevOps projects in the internal Azure DevOps organization. `[SAA-12916] <https://jira.office01.internalcorp.net:8443/browse/SAA-12916>`__
- Removed temporary token from published packages. `[SAA-15879] <https://jira.office01.internalcorp.net:8443/browse/SAA-15879>`__
- Fixed an issue in garbage collection related to Azure DevOps service connections. `[SAA-15946] <https://jira.office01.internalcorp.net:8443/browse/SAA-15946>`__
