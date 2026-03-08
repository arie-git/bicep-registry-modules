Incident remediation Key Vault
==============================

.. |AzureComponent| replace:: Key Vault
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-kv-01
     - Disable public network access.
     - Ensure to `disable public network access <https://learn.microsoft.com/en-us/azure/key-vault/general/network-security>`__ (configure property ``publicNetworkAccess`` to ``Disabled``).

   * - drcp-kv-02
     - Microsoft Entra ID authentication and Azure RBAC for Data Plane.
     - Ensure to enforce Microsoft Entra ID authentication (`RBAC authorization <https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli>`__) (configure property ``enableRbacAuthorization`` to ``true``).

   * - drcp-kv-03
     - Restrict the exposure of credentials and secrets.
     - Same remediation instruction applies as stated in control ``drcp-kv-03``.

   * - drcp-kv-04
     - Purge protection for key management in Azure Key Vault.
     - Ensure to enable `purge protection <https://learn.microsoft.com/en-us/azure/key-vault/general/key-vault-recovery?tabs=azure-portal>`__ (configure property ``enablePurgeProtection`` to ``true``).

   * - drcp-kv-05
     - Soft delete in key management in Azure Key Vault.
     - Ensure to enable `soft delete <https://learn.microsoft.com/en-us/azure/key-vault/general/key-vault-recovery?tabs=azure-portal>`__ (configure property ``enableSoftDelete`` to ``true``).

   * - drcp-kv-06
     - Microsoft Defender for Cloud monitoring on Keys inside a Key Vault.
     - Ensure to configure a specific validity date for the Key Vault keys.

   * - drcp-kv-07
     - Microsoft Defender for Cloud monitoring on secrets inside a Key Vault.
     - Ensure to configure a specific validity date for the Key Vault secrets.

   * - drcp-kv-08
     - Microsoft Defender for Cloud monitoring on certificates inside a Key Vault.
     - Ensure to configure a specific validity date for the Key Vault certificates.

   * - drcp-kv-09
     - Microsoft Defender for Cloud monitoring on HSM keys inside a Key Vault.
     - Ensure to configure a specific validity date for the Key Vault HSM keys.

   * - drcp-kv-10
     - Enable treat detection capabilities with Microsoft Defender for Key Vaults.
     - Ensure to enable `Defender for Azure Key Vault <https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-key-vault-introduction>`__.

   * - drcp-kv-11
     - Use of private DNS zones for private endpoints.
     - When deploying a private endpoint that belongs to a Key Vault, clear the `Private DNS zone configuration <https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration>`__ since DRCP policies remediate this configuration.