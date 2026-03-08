Incident remediation Service Bus
================================

.. |AzureComponent| replace:: Service bus
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-sbns-01
     - Minimal TLS version.
     - Ensure to configure the minimum TLS version to ``1.2`` (configure property ``minimumTlsVersion`` to ``1.2``).

   * - drcp-sbns-02
     - Disallow local authentication.
     - Ensure to disable local authentication methods (configure boolean property ``disableLocalAuth`` to ``true``).

   * - drcp-sbns-03
     - Disable Public Network Access.
     - Ensure to disable public network access (configure property ``publicNetworkAccess`` on scope of network rule sets and namespaces).

   * - drcp-sbns-04
     - Use of private DNS zones for private endpoints.
     - When deploying a private endpoint that belongs to an Event Hub Namespace, clear the `Private DNS zone configuration <https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration>`__ since DRCP policies remediate this configuration.
