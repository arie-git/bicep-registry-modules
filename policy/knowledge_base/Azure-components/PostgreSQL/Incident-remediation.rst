Incident remediation PostgreSQL
===============================

.. |AzureComponent| replace:: PostgreSQL
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-psql-01
     - Disable public network access and enforce VNet integration.
     - Ensure to disable public network access (configure property ``publicNetworkAccess`` to ``Disabled``) and enable VNet integration (configure property ``delegatedSubnetResourceId`` with an empty subnet).

   * - drcp-psql-02
     - Microsoft Entra ID authentication.
     - Ensure to disable local authentication (configure boolean property ``activeDirectoryAuth`` to ``true``).

   * - drcp-psql-03
     - Restrict administrator.
     - Ensure to assign the Azure DevOps deployment service principal or Privileged Engineer group as Microsoft Entra ID administrator in usages `test`, `acceptance` or `production`. For `development` usage, either assign the Azure DevOps deployment service principal or Engineer group.

   * - drcp-psql-04
     - Enforce service managed encryption keys.
     - Ensure to configure service managed encryption keys (sub-property ``type`` in ``dataEncryption`` to ``SystemManaged``).

   * - drcp-psql-05
     - Disable PostgreSQL single server and CosmosDB PostgreSQL.
     - Ensure to configure PostgreSQL flexible server as sub-resource type (resource ID ``Microsoft.DBforPostgreSQL/flexibleServers``).

   * - drcp-psql-06
     - Enforce minimal version of PostgreSQL.
     - Ensure to deploy the minimal PostgreSQL version 16.

   * - drcp-psql-07
     - Enforce SSL connection.
     - Ensure to configure the server parameter ``require_secure_transport`` to ``ON``.

   * - drcp-psql-08
     - Enforce TLS 1.2 or newer.
     - Ensure to configure the server parameter ssl_min_protocol_version to ``TLSV1.2``.

   * - drcp-psql-09
     - Microsoft Defender for open source relational databases.
     - Ensure to enable Defender for open source relational databases.

   * - drcp-psql-10
     - Enforce Zone Redundancy.
     - Ensure to enable `Zone Redundancy <https://learn.microsoft.com/en-us/azure/reliability/reliability-postgresql-flexible-server>`__.

   * - drcp-psql-11
     - Disable installation of PostgreSQL Extensions.
     - Ensure not to install PostgreSQL extensions.
