Security baseline Key Vault
===========================

Major change history
--------------------
.. list-table::
   :widths: 5 25 20 5
   :header-rows: 1

   * - Version.
     - Date
     - Name
     - Function/Reason
   * - 0.1
     - January 31, 2023
     - Ivo Huizinga
     - Initial version.
   * - 0.2
     - April 4, 2023
     - Ivo Huizinga
     - Sanitize baseline.
   * - 0.3
     - May 12, 2023
     - Martijn van der Linden
     - Sanitize baseline.
   * - 0.4
     - July 13, 2023
     - Ivo Huizinga
     - Added baseline controls.
   * - 1.0
     - June 19, 2024
     - Onno Hettema
     - Added identifiers to the baseline controls.

.. |AzureComponent| replace:: Key Vault
.. include:: ../../_static/include/security-baseline-header1.txt
.. include:: ../../_static/include/security-baseline-header2.txt

.. list-table::
   :widths: 05 20 25 05 05 05 05 05 15 10
   :header-rows: 1

   * - ID.
     - Description
     - Rationale
     - Risk (H/M/L)
     - Applicable CIA rating
     - Owner
     - Responsible for monitoring
     - Responsible for implementation
     - Control framework
     - Proof
   * - drcp-kv-01
     - Disable Public Network Access.
     - To enhance network security, you can configure your Key Vault to disable public access. This will deny all public configurations and allow connections through private endpoints.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: Azure Key Vault should disable public network access.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-kv-02
     - Microsoft Entra ID authentication and Azure RBAC for Data Plane.
     - DevOps teams must manage permissions with RBAC/IAM and not access policies. Azure Active Directory is the source for RBAC. All authorizations are therefor logged for audit purposes.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy to use RBAC permissions: Azure Key Vault should use RBAC permission model.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-kv-03
     - Restrict the exposure of credentials and secrets.
     - It's a best practice to enforce this, but this is also a matter of using the Key Vault in a correct way (for example: not storing secrets or other credentials in the code or configuration files.) It's a task of the BU CCCs to guide the DevOps teams in this.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy to use RBAC permissions: Azure Key Vault should use RBAC permission model.
     - DRCP will check every quarter.
   * - drcp-kv-04
     - Purge protection for Key Management in Azure Key Vault.
     - To prevent data loss or in case of an accidental deletion, enabling purge protection is mandatory. Otherwise a key (or a whole Key Vault) could be forever lost and a (production) application may no longer work. Most Azure services such as Storage Accounts that integrate with the Key Vault require this setting enabled.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: Key Vaults should have purge protection enabled.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-kv-05
     - Soft delete in Key Management in Azure Key Vault.
     - This feature allows you to recover or permanently delete a Key Vault or secrets during the retention period. Enabled by default, but is it impossible to disable this in the portal because of deprecation. It's still possible to change it via Azure command-line tool. In the long term this will deprecate as well and the policy will be not needed. Because soft delete becomes the default and can't switched off in the future, DevOps teams need to find a way to deal with removal of objects in soft delete state.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: Key Vaults should have soft delete enabled.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-kv-06
     - Microsoft Defender for Cloud monitoring on Keys inside a Key Vault.
     - A validity period for keys is mandatory. This audits the value for the validity period is 12 months. In other words, keys need a renewal every year.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: Key Vault keys should have an specified validity date.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-kv-07
     - Microsoft Defender for Cloud monitoring on secrets inside a Key Vault.
     - A validity period for secrets is mandatory. This audits the value for the validity period is 12 months. In other words, secrets need a renewal every year.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: Key Vault secrets should have an specified validity date.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-kv-08
     - Microsoft Defender for Cloud monitoring on certificates inside a Key Vault.
     - A validity period for certificates is mandatory. This audits the value for the validity period is 12 months. This ensures that you have to replace the certificate once every 12 months if you want it to remain valid. In other words, secrets need a renewal every year.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: the specified validity period should be present in certificates.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-kv-09
     - Microsoft Defender for Cloud monitoring on HSM keys inside a Key Vault.
     - A validity period for HSM keys is mandatory. This audits the value for the validity period is 12 months. In other words, HSM Keys need a renewal every year.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: the specified validity period should be present in HSM keys.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-kv-10
     - Enable treat detection capabilities with Microsoft Defender for Key Vaults.
     - Microsoft Defender has an offering / specific solution to track and alert on security issues for Azure Key Vaults.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Check whether Microsoft Defender for Cloud has enabled for Key Vault.
     - DRCP will check every quarter.
   * - drcp-kv-11
     - Use of private DNS zones for private endpoints.
     - Key Vault should be accessible through private endpoints that have their DNS records centrally registered in a private DNS zone group.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a DeployIfNotExist policy to remediate.
     - Microsoft Defender for Cloud. Compliant policy.

.. include:: ../../_static/include/security-baseline-footer.txt