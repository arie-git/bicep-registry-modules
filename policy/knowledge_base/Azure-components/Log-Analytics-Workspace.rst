Log Analytics Workspace
=======================

.. toctree::
   :maxdepth: 1
   :glob:

   Log-Analytics-Workspace/*

A Log Analytics Workspace is a unique environment for log data from Azure Monitor and other Azure services, such as Microsoft Sentinel and Microsoft Defender for Cloud. Each workspace has its own data repository and configuration but might combine data from more services.

Open stories for Log Analytics Workspace
----------------------------------------------

.. raw:: confluence_storage

   <ac:structured-macro ac:name="jira" ac:schema-version="1">
   <ac:parameter ac:name="server">APG-JIRA</ac:parameter>
   <ac:parameter ac:name="columnIds">issuekey,summary,issuetype,created,updated,status</ac:parameter>
   <ac:parameter ac:name="columns">key,summary,type,created,updated,status</ac:parameter>
   <ac:parameter ac:name="maximumIssues">20</ac:parameter>
   <ac:parameter ac:name="jqlQuery">text ~ &quot;log analytics workspace&quot; AND project = &quot;Azure Ignite&quot; AND status != Rejected AND status != Done</ac:parameter>
   <ac:parameter ac:name="serverId">41b39ff5-f59c-395b-80a2-0fab0b5bd3e5</ac:parameter>
   </ac:structured-macro>

Useful documentation
--------------------

`Log Analytics workspace overview | Microsoft Learn <https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview>`__