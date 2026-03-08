Use cases Storage Account
=========================

.. vale Microsoft.SentenceLength = NO

.. include:: ../../_static/include/component-usecasepage-header.txt

Azure Storage Account
---------------------
| Azure Storage Account is a common component of any APG Application system in Landing zone 3, as it offers highly available, massively scalable, durable and secure storage for a variety of data objects.
| For analysis purposes, one can store data in a way that enables easy accessibility, whether it's images, audio, video, logs, configuration files, or sensor data from an IoT array.
| It provides DevOps teams the flexibility to use its features based on their Application system needs.

Use cases and follow-up
-----------------------
Data protection
^^^^^^^^^^^^^^^
A Storage Account `offers <https://learn.microsoft.com/en-us/azure/storage/blobs/soft-delete-container-overview>`__ data protection options that help safeguard data against deletion.

-	Container soft delete, to restore a deleted container. `Learn <https://learn.microsoft.com/en-us/azure/storage/blobs/soft-delete-container-enable>`__ how to enable container soft delete.
-	Blob versioning, to automatically maintain previous versions of a blob. You can restore an earlier version of a blob to recover your data if it's erroneously modified or deleted. `Learn <https://learn.microsoft.com/en-us/azure/storage/blobs/versioning-enable>`__ how to enable blob versioning.
-	Blob soft delete, to restore a deleted blob, snapshot, or version. `Learn <https://learn.microsoft.com/en-us/azure/storage/blobs/soft-delete-blob-enable>`__ how to enable blob soft delete.

**Follow up:**
DRCP requires to enable all three options to limit risks of data loss and recover data if needed.


Lifecycle management
^^^^^^^^^^^^^^^^^^^^
The `lifecycle management <https://learn.microsoft.com/en-us/azure/storage/blobs/lifecycle-management-overview>`__ provides a rule-based policy to transition blob data to suitable access tiers or expire data at the end of its lifecycle.

**Follow up:**
DRCP recommends using the lifecycle management feature to optimize performance and costs.

This because Storage Account offers different `access tiers <https://learn.microsoft.com/en-us/azure/storage/blobs/access-tiers-overview?tabs=azure-portal>`__, so that you can store your blob data in the most cost-effective manner based on how it's used.

-	Blobs can moved from cool, or cold to hot when they're accessed to optimize performance.
-  Blobs can moved to a cool if objects haven't accessed or modified for a period of time, to optimize costs.
-  You can delete blobs at the end of a specified lifecycle, to save costs.

Encryption (at rest)
^^^^^^^^^^^^^^^^^^^^
| An Storage Account `uses <https://learn.microsoft.com/en-us/azure/storage/common/storage-service-encryption>`__ service-side encryption (SSE) to automatically encrypt data when it's persisted.
| The data in an Storage Account encrypts and decrypts transparently `using <https://learn.microsoft.com/en-us/azure/storage/common/storage-service-encryption#about-azure-storage-service-side-encryption>`__ 256-bit AES encryption, one of the strongest block ciphers available.
| Data in a new storage account encrypt with Microsoft-managed keys by default. You can rely on Microsoft-managed keys for the encryption, or you can manage encryption with your own keys (customer-managed keys).

**Follow up:**
| DRCP trusts Microsoft to manage the lifecycle of keys used for encryption. When a central vault solution comes available within APG to manage the Customer Managed keys it will revisit.
| Furthermore DRCP requires `infrastructure encryption <https://learn.microsoft.com/en-us/azure/storage/common/storage-service-encryption#doubly-encrypt-data-with-infrastructure-encryption>`__ to encrypt data twice to achieve a higher level of assurance that data is secure.

Data in transit
^^^^^^^^^^^^^^^
Microsoft Azure `offers <https://learn.microsoft.com/en-us/azure/security/fundamentals/encryption-overview>`__ mechanisms for keeping data private as it moves from one location to another:

-	HTTPS ensures authentication between the server and the service. It protects data in transit from network layer attacks such as man-in-the-middle, eavesdropping, and session-hijacking.
-	Transport Layer Security (TLS) encryption to protect data when traveling between services and customers.

**Follow up:**
DRCP requires TLS 1.2 and enables all transactions take place over HTTPS for all REST API requests.

All storage services are accessible via REST APIs, like Blob, Queue, Table and, File. CLick `here <https://learn.microsoft.com/en-us/rest/api/storageservices/>`__ for the REST API reference.

.. note:: Keep in mind that DRCP prevents insecure protocols like NFS when creating file shares. NFS doesn't `support <https://learn.microsoft.com/en-us/azure/storage/files/storage-files-networking-overview#secure-transfer>`__ an encryption mechanism and for that reason it poses security risks.


Authentication
^^^^^^^^^^^^^^^
Every request to an Storage Account must `authenticate <https://learn.microsoft.com/en-us/azure/storage/common/shared-key-authorization-prevent>`__. By default, requests can authenticate with either Microsoft Entra ID credentials or by using the account access key for Shared Key authorization (SAS).

**Follow up:**
DRCP requires `Microsoft Entra ID <https://learn.microsoft.com/en-us/azure/storage/blobs/authorize-access-azure-active-directory>`__ authentication to achieve compliance with APGs security standards (authentication through centralized IAM).


Authorization
^^^^^^^^^^^^^^^
| Role-based access control (RBAC) provides fine-grained access management to the content of the storage.
| It provides built-in roles for managing and assign permissions.
| Each storage type has their own specific roles: blob, queue, table and, file.
| Click `here <https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles>`__ to get an overview of all available roles to choose from.

**Follow up:**
| DRCP provides DevOps teams the flexibility to manage and grant built-in RBAC roles to assign permissions.
| There could be one data owner and more than one data contributors or readers in a DevOps team.

Networking
^^^^^^^^^^
| The APG security baseline requires the use of private endpoints for a Storage Account and blocks public access.
| DNS is a shared service over all Application systems. DRCP automates this to avoid intervention cross Application systems.

The APG security baseline also requires to disable ``Allow Azure services on the trusted services list to access the storage account``.
When the DevOps team disables public access in the GUI, the GUI doesn't show the setting ``Allow Azure services on the trusted services list to access the storage account``. This doesn't mean that this setting is automatically disabled.

.. vale Microsoft.SentenceLength = YES
