Service Bus
===========

.. toctree::
   :maxdepth: 1
   :glob:

   Service-Bus/*

Azure Service Bus is a fully managed message broker with message queues and publish-subscribe topics. It's used to decouple applications and services from each other, providing benefits like:

- Load-balancing work across competing workers.
- Routing and transferring data and control across service and application boundaries.
- Coordinating transactional work that requires a high-degree of reliability.

Open stories for Service Bus
----------------------------

.. raw:: confluence_storage

   <ac:structured-macro ac:name="jira" ac:schema-version="1">
   <ac:parameter ac:name="server">APG-JIRA</ac:parameter>
   <ac:parameter ac:name="columnIds">issuekey,summary,issuetype,created,updated,status</ac:parameter>
   <ac:parameter ac:name="columns">key,summary,type,created,updated,status</ac:parameter>
   <ac:parameter ac:name="maximumIssues">20</ac:parameter>
   <ac:parameter ac:name="jqlQuery">component = &quot;Azure Microsoft Service Bus&quot; AND status != Done AND status != rejected AND project = &quot;Azure Ignite&quot; </ac:parameter>
   <ac:parameter ac:name="serverId">41b39ff5-f59c-395b-80a2-0fab0b5bd3e5</ac:parameter>
   </ac:structured-macro>

Useful documentation
--------------------

`What's Azure Service Bus? | Microsoft Azure <https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-messaging-overview>`__
