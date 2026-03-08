Incident remediation App Configuration
======================================

.. |AzureComponent| replace:: App Configuration
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-appcs-01
     - Disallow public network access.
     - `Disable public network access <https://learn.microsoft.com/en-us/azure/azure-app-configuration/howto-disable-public-access?tabs=azure-portal>`__ on the App Configuration store.

   * - drcp-appcs-02
     - Disallow local authentication.
     - `Disabling local authentication methods <https://learn.microsoft.com/en-us/azure/azure-app-configuration/howto-disable-access-key-authentication?tabs=portal>`__ improves security by ensuring that App Configuration stores require Microsoft Entra identities for authentication.

   * - drcp-appcs-03
     - Use of private DNS zones for private endpoints.
     - When deploying a private endpoint that belongs to an App Configuration store, clear the `Private DNS zone configuration <https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration>`__ since DRCP policies remediate this configuration.