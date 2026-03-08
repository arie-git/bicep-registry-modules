Incident remediation Cosmos DB
==============================

.. |AzureComponent| replace:: Cosmos DB
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-cosmos-01
     - Disable public network access.
     - Ensure to disable public network access (configure property ``publicNetworkAccess`` to ``Disabled``). Development usage environments allows direct access through the Azure Portal (See: `SAA-4884 <https://jira.office01.internalcorp.net:8443/browse/SAA-4884>`__).

   * - drcp-cosmos-02
     - Microsoft Entra ID authentication.
     - Ensure to disable local authentication (configure boolean property ``disableLocalAuth`` to ``true``).

   * - drcp-cosmos-03
     - Key based write access.
     - Ensure to disable key based metadata write access (configure boolean property ``disableKeyBasedMetadataWriteAccess`` to ``true``).

   * - drcp-cosmos-04
     - Deploy Advanced Threat Protection for Cosmos DB accounts.
     - Ensure to enable `Advanced Threat Protection for Cosmos DB <https://learn.microsoft.com/en-us/cli/azure/security/atp/cosmosdb?view=azure-cli-latest>`__.

   * - drcp-cosmos-05
     - Enforce TLS 1.2 or newer.
     - Ensure to configure the minimal TLS version (property ``minimalTlsVersion``) to 1.2 (value ``Tls12``).

   * - drcp-cosmos-06
     - Only NoSQL databases.
     - DRCP restricts the use of Cosmos DB to these capabilities: ``EnableMongo``, ``EnableCassandra``, ``EnableTable`` and ``EnableGremlin``.

   * - drcp-cosmos-07
     - Automated private link DNS integration.
     - When deploying a private endpoint that belongs to a Cosmos DB instance, clear the `Private DNS zone configuration <https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration>`__ since DRCP policies remediate this configuration.

   * - drcp-cosmos-08
     - Ensure data backups are available.
     - Ensure to configure `backups <https://learn.microsoft.com/en-us/azure/cosmos-db/online-backup-and-restore>`__.

   * - drcp-cosmos-09
     - Microsoft Defender for Cloud.
     - Ensure to enable `Defender for Azure Cosmos DB <https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/defender-for-cosmos-db>`__.

   * - drcp-cosmos-10
     - Zone redundancy.
     - Ensure to enable `zone redundancy <https://learn.microsoft.com/en-us/azure/reliability/reliability-cosmos-db-nosql>`__.
