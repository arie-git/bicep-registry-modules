Use cases Service Bus
=====================

.. include:: ../../_static/include/component-usecasepage-header.txt

Service Bus
-----------
| Azure Service Bus `is <https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-messaging-overview>`__ a powerful cloud messaging service designed to optimize communication between applications and services.
| DevOps teams can seamlessly exchange messages, ensuring reliable and asynchronous communication across system components.

Scope
^^^^^
See article :doc:`Security baseline Service Bus <Security-Baseline>` for an actual overview of the scope of this component.

Use cases and follow-up
-----------------------

The usage
^^^^^^^^^
| DevOps teams can use client libraries to interact with the Service Bus, making it easy to get started.
| Click `here <https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-messaging-overview#client-libraries>`__ to access quick starts and examples tailored to your chosen language and framework.

Supported SKUs
^^^^^^^^^^^^^^
| Three `tiers <https://azure.microsoft.com/nl-nl/pricing/details/service-bus/>`__ exist, each with its own sizing and quotes. DevOps teams must use the **Premium** due to limitations.
| The Premium tier includes Private Link and Availability Zone support, which are essential for using the component privately and enhancing its availability.

Authentication and authorization
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| Service Bus supports Microsoft Entra ID to authenticate and allows requests. It allows you to use Azure RBAC to grant permissions to a security principal, which can be a user, a group, an application service principal, or a managed identity.
| Azure `provides <https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-managed-service-identity#azure-built-in-roles-for-azure-service-bus>`__ built-in roles that encompass common sets of permissions.
| The following built-in roles are specific to Service Bus:

.. list-table::
   :widths: 5 20
   :header-rows: 1

   *  - Role
      - Permission

   *  - Service Bus Data Owner
      - Allows full access a namespace and its entities (queues, topics, Subscriptions and filters).
   *  - Service Bus Data Sender
      - Allows sending messages to queues and topics.
   *  - Service Bus Data Receiver
      - Allows receiving messages from queues and Subscriptions.

DevOps teams have the flexibility to grant these roles and permissions themselves, ensuring precise control over access and security.

.. warning:: Most examples provided by Microsoft and other parties still use SAS keys for authentication. Keep in mind that DRCP doesn't allow local authentication methods like SAS keys, so familiarize yourself with using Microsoft Entra ID. See :doc:`Disallow local authentication <Security-Baseline>`.

Networking
^^^^^^^^^^
| The security baseline includes control ID ``drcp-sbns-03`` that denies :doc:`public access <Security-Baseline>`, requiring a private endpoint for connectivity.
| These private endpoints require a DNS record in a corresponding DNS zone. Since DNS integration is a central and shared service within APG, DRCP automates the creation of DNS zone records for private endpoints.
| It specifically handles DNS zones like "servicebus.windows.net" for Service Bus.

.. warning:: If a Service Bus namespace doesn't contain a private endpoint, actions on the Service Bus will return a HTTP-401 error because the security baseline prevents public access.

.. warning:: During the creating of a private endpoint make sure to disable the setting ``Integrate with private DNS zone`` to trigger DRCP's DNS zone remediation policy.

Encryption
^^^^^^^^^^
| Service Bus supports TLS versions 1.0, 1.1 and 1.2. DRCP enforces to use version 1.2. See the :doc:`Security baseline <Security-Baseline>` with control ID ``drcp-sbns-01``.

Manageability
^^^^^^^^^^^^^
| Service Bus has a `diagnostics setting <https://learn.microsoft.com/en-us/azure/service-bus-messaging/monitor-service-bus?tabs=AzureDiagnostics>`__ that DevOps teams can enable to collect component-specific logs.
| DevOps teams can decide whether to enable and use the logs as they wish, such as application monitoring, audit, or compliance purposes. Keep in mind that enabling the diagnostics logs can be costly because of storage.

.. warning:: Keep in mind that costs of diagnostics logs can increase quick if the scope of the logs isn't well-defined.

Availability
^^^^^^^^^^^^
| Beside the `SLA <https://www.azure.cn/en-us/support/sla/service-bus/>`__ that Microsoft offers, Service Bus supports `Availability Zones <https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview?tabs=azure-cli>`__ in the chosen region for Premium tier.
| This allows applications to be resilient to data center outages. DevOps teams derive from this and in that sense already have improved availability by default.
| Keep in mind that Service Bus also provides geo-replication and geo-recovery features. While these options can enhance component availability, they're not available to DevOps teams due to region limitations.

Lifecycle
^^^^^^^^^^^^
| Azure Service Bus follows the LCM process of Microsoft. They take care of updates and do so within the agreed SLA.
| DevOps teams can handle messages passing through Service Bus, aligning with lifecycle management by capturing failed messages or removing them when no longer needed.
| Three notable features include the `dead-letter queue <https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-dead-letter-queues>`__, `message deferral <https://learn.microsoft.com/en-us/azure/service-bus-messaging/message-deferral>`__, and `auto deletion <https://learn.microsoft.com/en-us/azure/service-bus-messaging/advanced-features-overview#autodelete-on-idle>`__ on idle.

Known limitations
-----------------
Remove namespace
^^^^^^^^^^^^^^^^
.. warning:: When using an Azure DevOps pipeline for removing a Service Bus namespace be aware of the following. The command returns the success status after a short while, but the namespace is later removed. If the task and job end while the namespace still exists in Azure, the removal of the namespace will fail. Mitigate this behaviour by implementing a loop, checking for the non-existance of the namespace.
