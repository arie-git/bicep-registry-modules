Use cases Key Vault
===================

.. include:: ../../_static/include/component-usecasepage-header.txt

Azure Key Vault
---------------
An Azure Key Vault should be a common component of any APG Application system in Landing zone 3. It serves as a central source for securely storing sensitive information and retrieving it as needed. You can encrypt and store cryptographic keys, secrets, and certificates used by your application and simplify the management of these critical assets.

By centralizing the management of sensitive information within the APG Application system, it can help reduce the risk of accidental exposure and ensure compliance with regulatory needs.

Why DRCP recommends its use:
 -	Centralizes storage of application secrets and reduces the chances of accidental leaks.
 -	Eliminates the need to store security information in application code.
 -	Provides authentication and authorization to control access to sensitive information.

Use cases and follow-up
-----------------------
Rotating keys
^^^^^^^^^^^^^
Rotating keys is a best practice and an industry standard for cryptographic management. Within Azure Key Vault, you can use an automated rotation policy to configure individual key rotations with specified frequencies.

Key rotation generates a new key version of an existing key with new key material. Target services should use version-less key URI to automatically refresh to latest version of the key.

`Read here how to configure key rotation <https://learn.microsoft.com/en-us/azure/key-vault/keys/how-to-configure-key-rotation>`__.

**Follow-up:**
DRCP follows the best practices from Microsoft and requires DevOps teams to rotate keys for a specified period. See the key vault security baseline for this period.

Keep in mind that the key rotation feature requires key management permissions. Assign the Key Vault Crypto Officer RBAC role to manage rotation policy and on-demand rotation.


RSA key size
^^^^^^^^^^^^
Azure Key Vault `provides <https://learn.microsoft.com/en-us/azure/key-vault/keys/about-keys>`__ two types of resources to store and manage cryptographic keys:

- Vaults is suitable for most common cloud application scenarios.
- Managed HSMs is suitable for applications and usage scenarios that handle high value keys and also helps to meet most stringent security, compliance, and regulatory needs.

**Follow up:**
DRCP recommends the Standard pricing tier, where keys comparable to Premium HSM keys offer a key size of 2048, which adherent to APGs security standards. Premium offers no larger key size and is a more expensive option.
DevOps teams are still free to create a HSM managed vault if needed.

Click `here <https://azure.microsoft.com/en-us/pricing/details/key-vault/>`__ to find out about the pricing tiers and `here <https://learn.microsoft.com/en-us/azure/key-vault/managed-hsm/overview>`__ to read more about Managed HSM.


Separate vaults per environment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
A `best practice <https://learn.microsoft.com/en-us/azure/key-vault/general/secure-key-vault#key-vault-architecture>`__ from Microsoft learn to use separate key vaults per application per environment. This helps you not share secrets across environments and regions and reduces the threat in case of a brach.

**Follow-up**:
DRCP requires DevOps teams not to use one key vault across more than one environments within the same Application system. A future case is to use key vaults to share secrets between Application systems.

To create security boundaries for stored secrets, DRCP requires a separate key vault. Grouping secrets into the same vault increases the blast radius of a security event because attacks might be able to access secrets across concerns.


Authentication
^^^^^^^^^^^^^^
When accessing Azure Key Vault, clients must authenticate themselves to the service.

**Follow up:**
DRCP requires `Microsoft Entra ID <https://learn.microsoft.com/en-us/azure/key-vault/general/authentication>`__ authentication to achieve one method for every DevOps team.


Authorization
^^^^^^^^^^^^^^
Azure Key Vault `offers <https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-access-policy>`__ two authorization systems:

- Azure role-based access control (Azure RBAC), which operates on the management plane.
- Access policies (legacy), which operates on both the management plane and the data plane.

**Follow-up:**
DRCP requires Azure RBAC and its the recommended authorization system for the data plane, it has advantages over access policies but the important ones are:

- Centralizes access management for administrators.
- `Deny assignments <https://learn.microsoft.com/en-us/azure/role-based-access-control/deny-assignments>`__ - ability to exclude security principals at a particular scope.
- Integration with Privileged Identity Management for time-based access control.

By utilizing Azure RBAC for all other enabled components, DRCP achieve a standard way of granting privileges on building blocks.

DRCP provides DevOps teams the flexibility to manage and grant `built-in <https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli#azure-built-in-roles-for-key-vault-data-plane-operations>`__ RBAC roles to assign permissions which are key vault specific.

There could be one Key Vault Administrator in a DevOps team, which is able to perform all data plane operations on a key vault and all objects in it.

Furthermore there are specific keys, secrets, and certificate permissions to grant for team members if nessesary, like:

- Key Vault Secrets Officer, which is able to perform any action on the secrets.
- Key Vault Crypto Officer, which is able to perform any action on the keys.


Data protection
^^^^^^^^^^^^^^^
In certain conceivable scenarios, an user may have inadvertently deleted a key vault or a key vault object. If that key vault or object were to be recoverable for a predetermined period, the user may undo the deletion and recover their data.

In a different scenario, a rogue user may attempt to delete a key vault or a key vault object, to cause a business disruption.

To limit these risks, soft-delete and purge protection functionalities can help to recover:

- Soft-delete retains the marked for deletion resources for a specified period. The service further provides a mechanism for recovering the deleted object, essentially undoing the deletion.
- Purge protection prevents the purging of a vault or objects within the vault while they're in the deleted state, until the retention period has elapsed.

`More information about the functionalities <https://learn.microsoft.com/en-us/azure/key-vault/general/soft-delete-overview>`__.

**Follow-up:**
DRCP requires soft delete and purge protection for a specified period (see the security baseline) and can't switched off. This due limit risks and support DevOps teams with data recovery.
Purge protection prevents malicious and accidental deletion of vault objects.

.. note:: `In February 2025 <https://learn.microsoft.com/en-us/azure/key-vault/general/soft-delete-change>`__ Microsoft will enable soft-delete protection on all key vaults, and users will no longer be able to opt out of or turn off soft-delete.

.. note:: `Keep in mind <https://learn.microsoft.com/en-us/azure/key-vault/general/soft-delete-overview>`__ that key vault names and names of secrets are globally unique. You won't be able to reuse the name of a key vault or key vault object that exists in the soft-deleted state. Execute the following command to purge the key vault if you need to remove the environment: Remove-AzKeyVault -VaultName <<myVaultsname>> -InRemovedState -Force -Location 'Sweden Central'


Back-up
^^^^^^^^
A backup intents to provide with an offline copy of all the secrets in the unlikely event that you lose access to the key vault.

The limitations are:

- It `doesn't <https://learn.microsoft.com/en-us/azure/key-vault/general/backup?tabs=azure-cli>`__ provide a way to back up an entire key vault content in a single operation. Any attempt to use an automated backup may result in errors and won't supported by Microsoft or the Azure Key Vault team.
- It doesn't support the ability to backup more than 500 past versions of a key, secret, or certificate object. Attempting to backup a key, secret, or certificate object may result in an error. It's impossible to delete previous versions of a key, secret, or certificate.

**Follow-up:**
DRCP recommends to back up secrets if you have a critical business justification, because:

- Azure Key Vault automatically provides features that helps to maintain availability and prevent data loss.
- Backing up secrets may introduce operational challenges such as maintaining more than one sets of logs, permissions, and backups when secrets expire or rotate.

DevOps teams are free to decide if they want to back up objects. If they do keep in mind that keys, secrets, and certificates can downloaded as an `encrypted blob <https://learn.microsoft.com/en-us/azure/key-vault/general/backup?tabs=azure-cli#design-considerations>`__.

This blob can't decrypt outside of Azure. To get usable data from this blob, you must restore the blob into a key vault within the same Azure Subscription.

.. note:: Keep in mind that if you back-up objects to an blob storage and removes the storage account or blob, the back-up isn't recoverable.
