Monitoring
==========

.. contents::
   Contents:
   :local:
   :depth: 3

The DRCP Azure platform contains the following monitoring flows for DevOps teams.

Terminology
-----------

.. note:: Find general definitions and abbreviations :doc:`here <../Getting-started/Definitions-and-abbreviations>`.

.. vale Microsoft.SentenceLength = NO

.. list-table::
   :widths: 20 105
   :header-rows: 1

   * - Term
     - Definition

   * - Azure Activity Log
     - | The Azure `activity log <https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/activity-log>`__ is a platform log in Azure that provides insight into Subscription-level events. The activity log includes information like when a resource modifies or a virtual machine starts.
       | `Example categories <https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/activity-log-schema?WT.mc_id=Portal-Microsoft_Azure_Monitoring#categories>`__ of these are administrative, security, service health, recommendation, policy, auto scale, and resource health logs.
   * - Azure `resource logs <https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/resource-logs>`__
     - | Azure resource logs are platform logs that provide insight into operations that executes within an Azure resource. The content of resource logs varies by the Azure service and resource type.
       | Examples of these are SQL databases, Azure firewall flow logs etc.
   * - MiFID
     - | The Markets in Financial Instruments Directive (MiFID) is a European regulation that increases the transparency across the European Union's financial markets and standardizes the regulatory disclosures required for firms operating in the European Union. `Source <https://www.investopedia.com/terms/m/mifid.asp>`__.

Security Monitoring
~~~~~~~~~~~~~~~~~~~
| Within the DRCP platform, monitoring, and logging is centrally managed when it comes to visibility for the security monitoring.
| This flow includes vulnerability software, Security Operation Center and the flow of tickets towards the DevOps team in ServiceNow.
|
| These logs are inaccessible for the individual DevOps teams. Adding logs, and use-cases goes through SecOps.
| Azure Portal creates alerts and tracks alerts that the DevOps team follows up.

.. note:: A future case is that when DevOps teams needs to react to an alert, the system creates a ticket in ServiceNow that the DevOps team follows up within the SLA times.

.. note:: * DRCP configures Azure Activity log for every Subscription and enables logs to be send to a central log analytic workspace which connects to Sentinel.
          * Besides, `Microsoft Entra ID logs <https://learn.microsoft.com/en-us/azure/active-directory/reports-monitoring/overview-reports>`__ is active and contain the history of sign-in activity made in Microsoft Entra ID.

Compliance Monitoring
~~~~~~~~~~~~~~~~~~~~~
| Applications may have compliance demands, for example an trading application inside the DRCP platform will still be subject to MiFID.
| While the platform is up to the generic standards of APG, it won't cater to specific frameworks and as such effort for specific frameworks needs to be.
| DRCP *exposes* tools required to achieve appropriate compliance, the DevOps team must apply the right solution.
| The following tools are available for DevOps teams:

Azure Monitor
~~~~~~~~~~~~~
| Azure Monitor Logs is a feature of `Azure Monitor <https://learn.microsoft.com/en-us/azure/azure-monitor/overview>`__ that collects and organizes log and performance data from monitored resources.
| Azure Monitor stores some data in Logs and presents it to help you track the performance and availability of your cloud and hybrid applications and their supporting components.

- Azure `charge <https://learn.microsoft.com/en-us/azure/azure-monitor/best-practices-cost#configuration-recommendations>`__ for retaining data in a Log Analytics workspace beyond the default of 31 days (90 days for Sentinel on the workspace and 90 days for Application insights data).
- For the paid tier the data retention is 31 days and is extendable for up to 730 days.

.. note:: The retention protects against alterations. Some certifications require that data is immutable including protect from *deleting* within storage.
          Data immutability - using data export to a storage account that's configured as immutable storage.

General Data Protection Regulation
**********************************
| GDPR is the regulation around personal data and limits the storing and processing of these types of data.
| Log Analytics is a data store that often includes personal data. Application Insights stores its data in a Log Analytics partition.
| DevOps teams need to manage this kind of data and to stop collecting personal data, obfuscate, or anonymize personal data.

| `Microsoft provides guidance for Log Analytics <https://learn.microsoft.com/en-us/azure/azure-monitor/logs/personal-data-mgmt#where-to-look-for-personal-data-in-azure-monitor-logs>`__.

Application performance logging
--------------------------------

Application Insights
~~~~~~~~~~~~~~~~~~~~
| `Application Insights <https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview>`__ extends Azure Monitor, offering application performance monitoring (APM) features. APM tools help track applications by:

.. vale Microsoft.SentenceLength = YES

- Proactively understand how an application is performing.
- Review application execution data to determine the cause of an incident.

| Along with collecting `metrics <https://learn.microsoft.com/en-us/azure/azure-monitor/app/standard-metrics>`__ and application `telemetry <https://learn.microsoft.com/en-us/azure/azure-monitor/app/data-model-complete>`__ data, which describe application activities and health, you can use Application Insights to collect and store application `trace logging data <https://learn.microsoft.com/en-us/azure/azure-monitor/app/asp-net-trace-logs>`__.

.. note:: Before you start check `here <https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview>`__ if Application Insights supports the programming language.

Network insights
~~~~~~~~~~~~~~~~
| `Network Insights <https://learn.microsoft.com/en-us/azure/network-watcher/network-insights-overview>`__ provides a comprehensive and visual representation through `topologies <https://learn.microsoft.com/en-us/azure/network-watcher/network-insights-topology>`__, of `health <https://learn.microsoft.com/en-us/azure/service-health/resource-health-checks-resource-types>`__ and `metrics <https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/metrics-supported>`__ for all deployed network resources, without requiring any configuration.
| It also provides access to network monitoring capabilities like Connection Monitor, flow logging for network security groups (NSGs), and Traffic Analytics.

.. note:: Azure uses Network Watcher to enable network insights and it's automatically enabled for every virtual network in a environment specific region.

Container insights
~~~~~~~~~~~~~~~~~~
| `Container insights <https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview>`__ is an Microsoft offering to stream logs from containers to Azure Monitor.
| It provides performance visibility by collecting memory and processor metrics from controllers, nodes, and containers that are available in Kubernetes through the Metrics API.

.. note:: * While it's functional it does require setting up and tweaking as costs can be high due to the amount of traffic.
          * They're trying to improve the cost-effectiveness of the tool but that's in preview. `For more information please review <https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-cost-config?tabs=create-CLI>`__.

Bring-your-own
--------------

| When using an external monitoring tool - this will create a new log-scope.
| This can be valid and examples have already implemented, the choice does impacts the DevOps teams ability to keep an holistic overview.

Prometheus
~~~~~~~~~~

| Natively Azure Container Insights is the tool of Microsoft, this can be costly and a lot of developer are familiar with Prometheus.
| With Prometheus you can integrate with an Azure Log Analytics workspace and thereby making the logs available outside the AKS cluster.
| Setting this up can be costly. Use Grafana to analyze logs within a cluster, avoiding the ingress cost of Azure Log Analytics.
| `For more information please review <https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/prometheus-metrics-overview>`__

Elastic Cloud
~~~~~~~~~~~~~

| Elastic Cloud was initially introduced as a dependency from an off-the-shelve application.
| While this doesn't change the scope of responsibility with regards to availability and compliance.
| Duplicating all Azure logs into Elastic is a costly endevaour.

Use cases
---------

Azure Monitor
~~~~~~~~~~~~~

Datasets
********
| When an application needs specific monitoring or wants to see their own monitoring. They can use Azure Monitor.
| This tool has a basic dataset, which is limit available but free of use.
| `Click here for more information on datasets and how to add them <https://learn.microsoft.com/en-us/azure/azure-monitor/data-sources>`__

| Adding data to the Azure Monitor incurs costs for storage.
| `Click here for more information on costs <https://azure.microsoft.com/en-us/pricing/details/monitor/>`__

Alerts
******
| Azure Monitor allows for the creation of alert-rules which can help you detect and address issues before users notice them by proactively
| notifying you when Azure Monitor data indicates there might be a problem with your infrastructure or application.
| These alerts allow for notification via email, SMS, push notifications, and others.

| `Click here for more information on alerts <https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview>`__

.. note:: * It's not supported to create ServiceNow events based on alert-rules made by the individual DevOps teams.
          * Keep in mind that you're able to create alerts and receive notifications (for instance if your application isn't responding or if it responds too slow) but it's handled by Azure.
          * In case your Application system has a need for it, please raise the concern with the appropriate BU-CCC so they can ensure it's appropriately prioritized.

Access mode
***********
| Azure Monitor uses `access mode <https://learn.microsoft.com/en-us/azure/azure-monitor/logs/manage-access?tabs=portal#access-mode>`__ which refers to how the Log Analytics workspace is access and defines the data you can access during the current session.
| Use resource-context to view the workspace for a particular environment/Azure Subscription (that belong to you) to have a defined scope which you can work with.

.. note:: `Built-in <https://learn.microsoft.com/en-us/azure/azure-monitor/logs/manage-access?tabs=portal#built-in-roles>`__ (RBAC) roles are available to arrange permissions to read and write to workspaces.

Query cross Subscriptions
*************************
| When querying cross Subscription, this is with the resource-context a default setting. Be sure to use the query context appropriate.
| A notable exception is the Application Insights workspace which needs to included explicitly.

`Click here for more information on querying cross Subscriptions <https://learn.microsoft.com/en-us/azure/azure-monitor/logs/cross-workspace-query#query-using-a-function>`__
