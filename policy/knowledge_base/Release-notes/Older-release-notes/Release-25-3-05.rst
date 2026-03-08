Release 25-3 05
===============
Release date: August 26, 2025

.. warning:: | In upcoming **Release 25-3 06**, DRCP configures these 4 policies from Audit-effect to Deny-effect for usages Development and Test. `[SAA-14160] <https://jira.office01.internalcorp.net:8443/browse/SAA-14160>`__:

  - ``APG DRCP Azure Monitor Action Group Only allow APG email domains in alert receivers``
  - ``APG DRCP Azure Monitor Action Group Only allow approved domains in webhook receivers``
  - ``APG DRCP Azure Monitor Data Collection Rule Destination Log Analytics Workspace``
  - ``APG DRCP Azure Monitor Data Collection Rule Destination Storage Account``

What's new for users
--------------------
- In Azure DevOps, DevOps teams are now able to start pipelines within their project from other pipelines. `[SAA-15197] <https://jira.office01.internalcorp.net:8443/browse/SAA-15197>`__
- Moved Azure operator role ``Azure Kubernetes Service RBAC Reader`` and added role ``Key Vault Certificate User`` to Azure data roles. `[SAA-15151] <https://jira.office01.internalcorp.net:8443/browse/SAA-15151>`__
- Added Azure policies for beta component Azure Cache for Redis. `[SAA-14213] <https://jira.office01.internalcorp.net:8443/browse/SAA-14213>`__
- Updated :doc:`Use cases Redis <../../Azure-components/Redis/Use-cases>` with Authentication. `[SAA-14213] <https://jira.office01.internalcorp.net:8443/browse/SAA-14213>`__
- Added Quick action "Manage Databricks Workspace" in DRDC portal which allows DevOps teams to register their Databricks Workspace in Unity Catalog, set privileges and configure serverless compute. `[SAA-14582] <https://jira.office01.internalcorp.net:8443/browse/SAA-14582>`__

Fixed issues
------------
- Fixed policy ``APG DRCP PostgreSQL Minimum TLS version`` which had anomalies in retrieving the current value of the TLS version. `[SAA-12182] <https://jira.office01.internalcorp.net:8443/browse/SAA-12182>`__

Internal platform improvements
------------------------------
- Fixed automated control ``drcp-adb-w04``. It now verifies only users, principals and groups that are related to administrative access. Also it handles users that have admin access due to temporary access. `[SAA-10456] <https://jira.office01.internalcorp.net:8443/browse/SAA-10456>`__
- Added CosmosDB tests to the internal DRCP regression tests. `[SAA-6453] <https://jira.office01.internalcorp.net:8443/browse/SAA-6453>`__
- Added new service principals that are member of the API authentication service principals with the role 'DRCP.API.ADOCommit. `[SAA-15157] <https://jira.office01.internalcorp.net:8443/browse/SAA-15157>`__
- Added Azure Cache for Redis tests to the internal DRCP regression tests. `[SAA-14243] <https://jira.office01.internalcorp.net:8443/browse/SAA-14243>`__
- Removed pipelines (and associated files) for: ``Set-ConditionalAccessForDRCP`` and ``Remove-ConditionalAccessForDRCP``. `[SAA-14716] <https://jira.office01.internalcorp.net:8443/browse/SAA-14716>`__
