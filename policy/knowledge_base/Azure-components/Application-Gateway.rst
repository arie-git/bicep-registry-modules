Application Gateway
===================

.. toctree::
   :maxdepth: 1
   :glob:

   Application-Gateway/*

Azure Application Gateway is a web traffic (OSI layer 7) load balancer that enables you to manage traffic to your web applications. Traditional load balancers operate at the transport layer (OSI layer 4 - TCP and UDP). They route traffic based on source IP address and port, to a destination IP address and port.

Application Gateway can make routing decisions based on attributes of an HTTP request, for example URI path or host headers. For example, you can route traffic based on the incoming URL. If /images is in the incoming URL, you can route traffic to a specific set of servers (known as a pool) configured for images. If /video is in the URL, that traffic it routes to another pool that's optimized for videos.

Open stories for Application Gateway
-----------------------------------------

.. raw:: confluence_storage

   <ac:structured-macro ac:name="jira" ac:schema-version="1">
   <ac:parameter ac:name="server">APG-JIRA</ac:parameter>
   <ac:parameter ac:name="columnIds">issuekey,summary,issuetype,created,updated,status</ac:parameter>
   <ac:parameter ac:name="columns">key,summary,type,created,updated,status</ac:parameter>
   <ac:parameter ac:name="maximumIssues">20</ac:parameter>
   <ac:parameter ac:name="jqlQuery">component = &quot;Azure Microsoft Application Gateway&quot; AND status != Done AND status != rejected AND project = &quot;Azure Ignite&quot; </ac:parameter>
   <ac:parameter ac:name="serverId">41b39ff5-f59c-395b-80a2-0fab0b5bd3e5</ac:parameter>
   </ac:structured-macro>

Useful documentation
--------------------

`Azure Application Gateway documentation | Microsoft Learn <https://learn.microsoft.com/en-us/azure/application-gateway/>`__