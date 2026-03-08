SQL Database
============

.. toctree::
   :maxdepth: 1
   :glob:

   SQL-Database/*

Azure SQL Database is a fully managed platform as a service (PaaS) database engine. It automates database management tasks like upgrading, patching, backups, and monitoring, eliminating the need for user involvement.

Explicit disallowed sub-resourcetypes
-------------------------------------
| DRCP marks the following sub-resourcetypes as out-of-scope for this component and denies any deployment.
| Please raise a feature request in case a (business) use case applies to one of these sub-resourcetypes.

- ``servers/elasticpools``
- ``servers/databases/syncGroups``
- ``servers/jobAgents``
- ``servers/dnsAliases``

Open stories for SQL Database
---------------------------------

.. raw:: confluence_storage

   <ac:structured-macro ac:name="jira" ac:schema-version="1">
   <ac:parameter ac:name="server">APG-JIRA</ac:parameter>
   <ac:parameter ac:name="columnIds">issuekey,summary,issuetype,created,updated,status</ac:parameter>
   <ac:parameter ac:name="columns">key,summary,type,created,updated,status</ac:parameter>
   <ac:parameter ac:name="maximumIssues">20</ac:parameter>
   <ac:parameter ac:name="jqlQuery">component = &quot;Azure Microsoft Sql&quot; AND status != Done AND status != rejected AND project = &quot;Azure Ignite&quot; </ac:parameter>
   <ac:parameter ac:name="serverId">41b39ff5-f59c-395b-80a2-0fab0b5bd3e5</ac:parameter>
   </ac:structured-macro>

Useful documentation
--------------------

`Azure SQL | Microsoft Azure <https://azure.microsoft.com/en-us/products/azure-sql>`__

`Azure SQL Database documentation | Microsoft Learn <https://learn.microsoft.com/en-us/azure/azure-sql/database/?view=azuresql>`__