Use cases Event Hubs
====================

.. include:: ../../_static/include/component-usecasepage-header.txt

Azure Event Hubs
-----------------
| `Azure Event Hubs <https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-about>`__ streams big data and ingests events. It integrates seamlessly with other Azure and Microsoft services like Stream Analytics, Power BI, and Event Grid.
| The service can process millions of events per second with low latency. Any real-time analytics providers or batching or storage adapters can process and store data that's sent to an event hub.
| The Azure Event Hubs service represents the "front door" for an event pipeline, that sits between event publishers and event consumers.
| The DevOps teams determine how to use the service and incorporate it into their application landscape, including deciding which events to send or receive.

Use cases and follow-up
-----------------------

Pricing tier
^^^^^^^^^^^^
The Azure Event Hubs offer more `pricing tiers <https://azure.microsoft.com/en-us/pricing/details/event-hubs/>`__. Each has its own specification and limitation.

**Follow up:**

| DRCP recommends the standard or premium pricing tier because that fits the most common scenarios and prevents high costs.
| DevOps teams need to reflect the (Application system) needs against the available tiers, features, performance and budget to make this decision.

.. note:: To keep costs under control please take in consideration to not use the premium tier in development environments.


Encryption
^^^^^^^^^^^
| Azure Event Hubs `provides <https://learn.microsoft.com/en-us/azure/event-hubs/configure-customer-managed-key>`__ encryption of data at rest with Azure Storage Service Encryption (Azure SSE).
| The Event Hubs service uses Azure Storage to store and encrypt data using Microsoft-managed keys.
| When using customer-managed keys, data is still encrypted using the Microsoft-managed key and on top of that the customer-managed key will encrypt the Microsoft-managed key.
| This feature empowers you to create, rotate, disable, and revoke access to customer-managed keys utilized for encrypting Microsoft-managed keys.

**Follow up:**
DRCP trusts Microsoft to manage the lifecycle of keys used for encryption. When a central vault solution comes available within APG to manage customer-managed keys, DRCP will revisit.


Authentication
^^^^^^^^^^^^^^^
| Every published or consumed event from an event hub which is trying to access Event Hubs resources, needs to authenticated and authorized.
| Azure Event Hubs offers two options: Microsoft Entra ID and Shared Access Signature (SAS).

**Follow up:**

| DRCP requires `Microsoft Entra ID <https://learn.microsoft.com/en-us/azure/event-hubs/authenticate-application>`__ to achieve one authentication method for every DevOps team.
| Because of known limitations of certain Azure components, SAS authentication isn't blocked. Visit the security baseline for the latest status.

Authorization
^^^^^^^^^^^^^
The Azure role-based access control (RBAC) provides fine-grained access management to the content of Event Hubs data. Azure provides built-in roles for authorizing access to data.

**Follow-up:**

| DRCP provides DevOps teams the flexibility to manage and grant these built-in roles to assign permissions.
| There could be one data owner in a DevOps team and one data sender and data receiver for test purposes.
| Click `here <https://learn.microsoft.com/en-us/azure/event-hubs/authorize-access-azure-active-directory#azure-built-in-roles-for-azure-event-hubs>`__ to get an overview of the available roles to choose from.

Event lifecycle
^^^^^^^^^^^^^^^
| Azure Event Hubs `retains <https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-faq#what-is-the-maximum-retention-period-for-events->`__ events for the retention period and are automatically removed when the period (default 1 hour and this can extended to 7 days.) has reached.
| Azure Event Hubs acknowledge back to the client after persisting the message to a persistent store. (at least once.)
| The same applies when receiving data. If a receiver client crashes, it can recover with an application-specific offset. The Event Hubs service guarantees that the stream will replay from that exact point.

**Follow-up:**

| This means that DRCP recommends that clients needs to be smart enough to de-duplicate and keep track of the offset to resume processing in case of a failure.
| Monitoring the 'Lag' metric can prevent message loss by indicating which messages still need processing.
| Tracking the number of unprocessed messages helps identify potential issues before they lead to data loss during the removal period.


**Instructions:**
To update the retention period, use ARM/Bicep, otherwise use tools such as:

- `Azure command-line tool <https://learn.microsoft.com/en-us/cli/azure/eventhubs/eventhub?view=azure-cli-latest#az-eventhubs-eventhub-update>`__
- `REST API <https://learn.microsoft.com/en-us/rest/api/eventhub/update-event-hub>`__
- `PowerShell <https://learn.microsoft.com/en-us/powershell/module/az.eventhub/?view=azps-14.3.0>`__

Known limitations
-----------------

| For the Capture feature of Event Hubs you need to connect to a Storage Account within the same Environment/Subscription. By default, the Event Hubs Capture feature needs the bypass of AzureServices to establish this connection. The Storage Account security baseline enforces a policy that disallows the bypass: ``APG DRCP Storage Account Disallow network ACL and firewall bypassing``. This policy, combined with the connectivity condition, creates a conflict.
| To resolve the conflict for Event Hubs Capture feature, assign a tag to the Storage Account with the following settings: Name: UsedBy, Value: EventHub.
| Click `here <https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-capture-enable-through-portal>`__ to get an overview of Capture feature of Event Hubs.

.. warning:: Use this tag for its intended purpose. Using it otherwise isn't allowed.