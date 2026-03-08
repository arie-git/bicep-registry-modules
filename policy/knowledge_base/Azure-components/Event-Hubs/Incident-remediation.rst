Incident remediation Event Hubs
===============================

.. |AzureComponent| replace:: Event Hubs
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-evh-01
     - Disable public network access.
     - Ensure to `disable public network access <https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-ip-filtering>`__.

   * - drcp-evh-02
     - Use of private DNS zones for private endpoints in Azure Event Hub Namespaces.
     - When deploying a private endpoint that belongs to an Azure Event Hub Namespace, clear the `Private DNS zone configuration <https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration>`__ since DRCP policies remediate this configuration.

   * - drcp-evh-03
     - VNet integration.
     - Ensure to configure `virtual network integration <https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-service-endpoints>`__.

   * - drcp-evh-04
     - Trusted services.
     - Ensure to disable the `trusted service firewall exclusion <https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-ip-filtering#trusted-microsoft-services>`__ on the component.

   * - drcp-evh-05
     - Local authentication methods.
     - Ensure to `disable local authentication methods <https://learn.microsoft.com/en-us/azure/event-hubs/authenticate-shared-access-signature>`__ on the Event Hub namespace (configure the property ``disableLocalAuth`` to ``true``).

   * - drcp-evh-06
     - Authorization for the Event Hub Namespace.
     - Ensure to remove all `authorization rules <https://learn.microsoft.com/en-us/azure/event-hubs/authorize-access-event-hubs>`__, except ``RootManageSharedAccessKey``, from the Event Hub Namespace. Ensure to assign authorization rules to a Root Managed Shared Access Key.

   * - drcp-evh-07
     - Encrypt sensitive data in transit.
     - Ensure to `configure the minimum TLS version <https://learn.microsoft.com/en-us/azure/event-hubs/transport-layer-security-configure-minimum-version>`__ to ``1.2`` (configure property ``minimumTlsVersion`` with value ``1.2``).

   * - drcp-evh-08
     - Encrypt data for REST using platform keys.
     - Ensure to enable the `require infrastructure encryption feature <https://learn.microsoft.com/en-us/azure/event-hubs/configure-customer-managed-key?tabs=Key-Vault#enable-infrastructure-or-double-encryption-of-data>`__ (configure property ``requireInfrastructureEncryption`` to ``true``).
