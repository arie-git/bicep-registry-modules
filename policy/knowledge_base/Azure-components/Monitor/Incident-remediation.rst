Incident remediation Azure Monitor
==================================

.. |AzureComponent| replace:: Azure Monitor
.. include:: ../../_static/include/incident-remediation-header.txt

It consists of 3 tables:

- First table consists of **generic Azure Monitor** resource settings.
- Second table consist of **Log Analytics Workspace** specific settings.
- Third table consist of **Application Insights** specific settings.

These instructions relates to **generic Azure Monitor** specific settings.

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-amo-01
     - Azure Monitor Action Groups: Only allow APG-owned emaildomains as receivers.
     - Ensure that the email receivers use a domain that's APG-owned, for example ``john.doe@apg.nl`` or ``james.whistler@apg-am.nl``.

   * - drcp-amo-02
     - Azure Monitor Action Groups: Prohibit external domains for webhooks.
     - Ensure to configure the webhook with a URL that contains an allowed domain. Current allowed domains are: ``apgdev2.service-now.com``, ``apgacc.service-now.com`` and ``apgprd.service-now.com``.

   * - drcp-amo-03
     - Azure Monitor Data Collection Rules: Restrict destination Log Analytics Workspace
     - Ensure to use a destination Log Analytics workspace residing in the same Subscription as the Data Collection Rule.

   * - drcp-amo-04
     - Azure Monitor Data Collection Rules: Restrict destination Storage Account
     - Ensure to use a destination Storage Account residing in the same Subscription as the Data Collection Rule.

   * - drcp-amo-05
     - Block Azure Monitor functionality that's explicitly set as out-scope
     - Please take note of the described scope on the :doc:`introduction page of Azure Monitor <../Monitor>` on the KB.

   * - drcp-amo-06
     - Azure Monitor Data Collection Rules: Restrict Azure Monitor Workspace.
     - Ensure that the Data Collection Rule target contains a Azure Monitor Workspace within the same Subscription.

   * - drcp-amo-07
     - Azure Monitor Data Collection Rules: Restrict Data Collection Endpoint.
     - Ensure that the Data Collection Rule links to a Data Collection Endpoint within the same Subscription.

These instructions relates to **Log Analytics Workspace** specific settings.

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-log-01
     - Agent keys.
     - Ensure to create a custom role which can't view or regenerate these Agent keys.

   * - drcp-log-02
     - Data export.
     - Ensure to remove any `data export rules <https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-data-export?tabs=portal>`__.

   * - drcp-log-03
     - Linked storage accounts.
     - Ensure to remove any `links to storage accounts <https://techcommunity.microsoft.com/t5/azure-observability-blog/linking-storage-accounts-to-your-workspace-made-easy-with-new/ba-p/2054016>`__.

   * - drcp-log-04
     - Legacy features.
     - Ensure to remove data sources from legacy features such as System Center, Legacy Agents, Legacy Storage Account Logs and Legacy Activity Logs Connectors.

   * - drcp-log-05
     - Workspace-context access mode.
     - Ensure to disable `'Workspace Context Access Mode' <https://learn.microsoft.com/en-us/azure/azure-monitor/logs/manage-access?tabs=portal>`__ (configure property ``features.enableLogAccessUsingOnlyResourcePermissions`` to ``true``).

These instructions relates to **Application Insights** specific settings.

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-appi-01
     - Authentication.
     - | Ensure to disable local authentication (configure the boolean property ``DisableLocalAuth`` to ``true``). Public sources can send to the Application Insights instance with tag ``usedBy`` and value ``PublicSource`` present.
       | ⚠️ **Warning:** Use this tag for its intended purpose. Using it otherwise isn't allowed.

   * - drcp-appi-02
     - Log storage.
     - Ensure to connect the Application Insights instance to a Log Analytics workspace.

   * - drcp-appi-03
     - Tests.
     - Remove any tests (``webtests``) within the Application Insights instance, these aren't allowed.

   * - drcp-appi-04
     - Diagnostic settings.
     - The following categories aren't allowed to export: ``AppEvents``, ``AppExceptions``, ``AppRequests`` and ``AppTraces``.

   * - drcp-appi-05
     - Javascript Source Map Blob Storage URL.
     - Remove any Javascript Source Map Blog Storage URL configurations on the Application Insights instance, these aren't allowed.

These instructions relates to **Managed Grafana** specific settings.

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-amg-01
     - Use of private DNS zones for private endpoints.
     - Ensure to create a private endpoint that connects with your Managed Grafana instance.

   * - drcp-amg-02
     - Disable public network access.
     - Ensure to disable public network access (property ``publicNetworkAccess`` should be ``Disabled``) on your Managed Grafana instance.

   * - drcp-amg-03
     - Disable Grafana Enterprise.
     - Ensure to use the non-Enterprise variant of Managed Grafana.

   * - drcp-amg-04
     - Disable service accounts.
     - Ensure to disable service accounts (property ``apiKey`` should be ``Disabled``) on your Managed Grafana instance.

   * - drcp-amg-05
     - Disable plugins.
     - Ensure to not install any plugins (property ``grafanaPlugins`` shouldn't exist or be empty) on your Managed Grafana instance.

   * - drcp-amg-06
     - Disable SMTP.
     - Ensure to disable SMTP (property ``enabled`` under ``grafanaConfigurations.smtp`` should be ``false``) on your Managed Grafana instance.

   * - drcp-amg-07
     - Disallow connections to Azure Monitor Workspaces outside of current Subscription.
     - Ensure that the Managed Grafana instance connects to an Azure Monitor Workspace within the same Subscription.

   * - drcp-amg-08
     - Grafana version.
     - Ensure that the Managed Grafana instance is running the latest version. The version is selectable within the **Configurations** section and registered within property ``grafanaMajorVersion``.
