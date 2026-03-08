Monitor
=======

.. toctree::
   :maxdepth: 1
   :glob:

   Monitor/*

Azure Monitor is a collection of native Azure services that enables observability of Azure components and related Azure features through metrics, logs, alerts, and diagnostic data.

The scope of this DRCP component includes, but isn't limited to, the hardening of:

- Log Analytics workspaces
- Application Insights instances
- Azure Managed Grafana instances (DRCP beta at this moment)
- Diagnostic settings and alert rules.

Explicitly **out-of-scope**:

-	`Azure Monitor Private Link Scope <https://learn.microsoft.com/en-us/azure/azure-monitor/logs/private-link-security>`__, as this functionality requires a shared responsibility model;
-	`Azure Monitor pipeline <https://techcommunity.microsoft.com/blog/azureobservabilityblog/accelerate-your-observability-journey-with-azure-monitor-pipeline-preview/4124852>`__, as this functionality requires AKS on Azure Arc and is commonly used to ship on-premises logging towards functionalities of Azure Monitor;
-	`Azure Monitor SCOM Managed Instance <https://learn.microsoft.com/en-us/azure/azure-monitor/scom-manage-instance/overview>`__, as this functionality is out of scope of the DRCP platform.

.. note:: As soon as this component promotes to MVP, the existing components :doc:`Log Analytics Workspace <Log-Analytics-Workspace>` and :doc:`Application Insights <Application-Insights>` merge into this component.

Open stories for Azure Monitor
------------------------------

.. raw:: confluence_storage

   <ac:structured-macro ac:name="jira" ac:schema-version="1">
   <ac:parameter ac:name="server">APG-JIRA</ac:parameter>
   <ac:parameter ac:name="columnIds">issuekey,summary,issuetype,created,updated,status</ac:parameter>
   <ac:parameter ac:name="columns">key,summary,type,created,updated,status</ac:parameter>
   <ac:parameter ac:name="maximumIssues">20</ac:parameter>
   <ac:parameter ac:name="jqlQuery">component = &quot;Azure Microsoft Monitor&quot; AND status != Done AND status != rejected AND project = &quot;Azure Ignite&quot; </ac:parameter>
   <ac:parameter ac:name="serverId">41b39ff5-f59c-395b-80a2-0fab0b5bd3e5</ac:parameter>
   </ac:structured-macro>

Useful documentation
--------------------

`Azure Monitor | Microsoft Azure <https://learn.microsoft.com/en-us/azure/azure-monitor/fundamentals/overview>`__
