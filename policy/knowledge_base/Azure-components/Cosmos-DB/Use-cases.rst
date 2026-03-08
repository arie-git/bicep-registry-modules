Use cases Cosmos DB
===================

.. include:: ../../_static/include/component-usecasepage-header.txt

.. warning:: Limited :doc:`Azure Availability Zones support <../../Platform/Azure-availability-zones-support>` applies.

Cosmos DB
---------
A Cosmos DB is a fully managed NoSQL and relational database. Azure Cosmos DB offers single-digit millisecond response times, automatic and instant scalability, along with guaranteed speed at any scale. Business continuity together with SLA-backed availability and enterprise-grade security.

As a fully managed service, Azure Cosmos DB takes database administration off your hands with automatic management, updates, and patching. It also handles capacity management with cost-effective serverless and automatic scaling options that respond to application needs to match capacity with demand.

Azure Cosmos DB supports flexible schemas and hierarchical data, and thus well suited for storing product catalog data. Azure Cosmos DB is often used for event sourcing to power event driven architectures using its change feed functionality.

Use cases and follow-up
-----------------------

********
Security
********

Always Encrypted
^^^^^^^^^^^^^^^^
Always Encrypted is a feature designed to protect sensitive data stored in Azure Cosmos DB.

Always Encrypted allows clients to encrypt sensitive data inside client applications and never reveal the encryption keys to the database.

When using Always Encrypted, data encryption will use data encryption keys (DEK) that should you should create up ahead. You must store these DEKs in the Azure Cosmos DB service and define them at the database level, so a DEK is shareable across containers. Create the DEKs at the client-side by using the Azure Cosmos DB SDK.

Before DEKs get stored in Azure Cosmos DB, they're wrapped by a customer-managed key (CMK). By controlling the wrapping and unwrapping of DEKs, CMKs control the access to the data that's encrypted with their corresponding DEKs. CMK storage is an extensible, the default implementation is to store them in an Azure Key Vault.

`Read here on the how to use Always Encrypted <https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-always-encrypted?tabs=dotnet>`__.

Encryption
^^^^^^^^^^
Encryption at rest is now available for documents and backups stored in Azure Cosmos DB in all Azure regions. Encryption at rest automatically applies for both new and existing customers in these regions. There's no need to configure anything. You get the same great latency, throughput, availability, and functionality as before with the benefit of knowing your data is safe and secure with encryption at rest. Data stored in your Azure Cosmos DB account is automatically and seamlessly encrypted with keys managed by Microsoft using service-managed keys. Optionally, you can choose to add a second layer of encryption with keys you manage using customer-managed keys or CMK.

Compliance
^^^^^^^^^^
Azure Cosmos DB must be compliant to APG compliance rules. A security baseline and policies on the component and platform level are in place to comply to these rules.

:doc:`Read this security baseline here <Security-Baseline>`.

************
Availability
************

DRCP recommends to use `Provisioned Throughput <https://learn.microsoft.com/en-us/azure/cosmos-db/set-throughput>`__. By using provisioned throughput, the use of availability zones is possible. DRCP audits for Environments with usage Development, Test and Acceptance and enforces this for Environments with the usage Production.

Backup Restore
^^^^^^^^^^^^^^

Cosmos DB has to have a backup strategy, either the continues or periodic backup, to ensure no faults during release. At the time of writing this has to be in a different container then the original container. Be aware that restoring a periodic backup is available via a support request in the Azure portal. Also be aware that continues backup has a limit of ``30 days`` and continues restores require ``UTC`` - using local time won't produce the right results.

`Read here on the how to restore a continuous backup <https://learn.microsoft.com/en-us/azure/cosmos-db/restore-account-continuous-backup>`__.

`Read here on the how to restore a periodic backup <https://learn.microsoft.com/en-us/azure/cosmos-db/periodic-backup-request-data-restore?tabs=azure-portal>`__.

********************************
Authentication and Authorization
********************************

Authentication
^^^^^^^^^^^^^^
Every secure request to an Azure Cosmos DB must authenticate with Microsoft Entra ID. Local accounts aren't allowed and the use of Microsoft Entra ID is mandatory.

Authorization
^^^^^^^^^^^^^
Role-based access control (RBAC) provides fine-grained access management to the content of the database

It provides `built-in <https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles>`__ roles for managing and assign permissions.

The permission model consists of a set of actions. Each of these actions maps to one or more database operations. Some examples of actions include reading an item, writing an item, or executing a query.

Azure Cosmos DB users create role definitions containing a list of allowed actions.

Role definitions get assigned to specific Microsoft Entra ID identities through role assignments. A role assignment also defines the scope that the role definition applies to. At this moment you can choose from three scopes:

- An Azure Cosmos DB account,
- An Azure Cosmos DB database,
- An Azure Cosmos DB container.

********************************
Azure Portal
********************************

If DevOps teams enables and uses Azure Portal access, it's restricted to selected Azure data center IPs.
DRCP allows IPs from all regions except United States Government and Azure China:

- 104.42.195.92
- 40.76.54.131
- 52.176.6.30
- 52.169.50.45
- 52.187.184.26
- 13.91.105.215
- 4.210.172.107
- 13.88.56.148
- 40.91.218.243

`Read here how Azure Cosmos DB works with IP firewall <https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-configure-firewall#allow-requests-from-the-azure-portal>`__.
