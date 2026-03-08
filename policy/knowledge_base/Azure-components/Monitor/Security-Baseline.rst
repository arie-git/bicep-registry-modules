Security baseline Azure Monitor
===============================

Major change history
--------------------
.. list-table::
   :widths: 5 25 20 5
   :header-rows: 1

   * - Version.
     - Date
     - Name
     - Function/Reason
   * - 1.0
     - July 7, 2025
     - Michiel Janssen
     - Initial version.
   * - 1.1
     - July 16, 2025
     - Michiel Janssen
     - Added baseline control ``drcp-amo-04`` to restrict Data Collection Rule destinations.
   * - 1.2
     - September 5, 2025
     - Michiel Janssen, Bas van den Putten
     - Removed control ``drcp-appi-01``.
   * - 1.3
     - September 11, 2025
     - Cyprian Zurek
     - Added baseline control ``drcp-amo-06`` to restrict Data Collection Rule destinations, and ``drcp-amo-07`` to restrict the Rules' Data Collection Endpoint.
   * - 1.4
     - September 24, 2025
     - Michiel Janssen, Bas van den Putten
     - Added adjusted control ``drcp-appi-01``.
   * - 1.5
     - December 11, 2025
     - Michiel Janssen
     - Added control ``drcp-amg-01`` as first control for Managed Grafana. This baseline section is in draft.
   * - 1.6
     - January 12, 2026
     - Michiel Janssen
     - Added controls for Managed Grafana, ending the draft state of this baseline section.

.. |AzureComponent| replace:: Azure Monitor
.. include:: ../../_static/include/security-baseline-header1.txt
.. include:: ../../_static/include/security-baseline-header2.txt

It consists of 3 tables:

- First table consists of **generic Azure Monitor** resource settings.
- Second table consist of **Log Analytics Workspace** specific settings.
- Third table consist of **Application Insights** specific settings.

These controls relate to **generic Azure Monitor** capabilities:

.. list-table::
   :widths: 05 20 25 05 05 05 05 05 15 10
   :header-rows: 1

   * - ID
     - Description
     - Rationale
     - Risk (H/M/L)
     - Applicable CIA rating
     - Owner
     - Responsible for monitoring
     - Responsible for implementation
     - Control framework
     - Proof
   * - drcp-amo-01
     - Azure Monitor Action Groups: Only allow APG-owned emaildomains as receivers.
     - Prevent sending potential sensitive (alert) information to external email domains that aren't owned by APG.
     - L
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a 'Deny' policy that limits email receivers to specified domains.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-amo-02
     - Azure Monitor Action Groups: Prohibit external domains for webhooks.
     - Prevent sending potential sensitive (alert) information to external webhook domains that aren't allowed.
     - L
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a 'Deny' policy that limits the allowed webhook domains to specified domains.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-amo-03
     - Azure Monitor Data Collection Rules: Restrict destination Log Analytics Workspace
     - Enforce that the target Log Analytics Workspace of the Data Collection Rule is in the same Subscription to prevent cross Usage or cross Application system flows.
     - L
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a 'Deny' policy that prevents Data Collection Rules deployments with a target Log Analytics Workspace outside of the current Subscription.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-amo-04
     - Azure Monitor Data Collection Rules: Restrict destination Storage Account
     - Enforce that the target Storage Account of the Data Collection Rule is in the same Subscription to prevent cross Usage or cross Application system flows.
     - L
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a 'Deny' policy that prevents Data Collection Rules deployments with a target Storage Account outside of the current Subscription.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-amo-05
     - Block Azure Monitor functionality that's explicitly set as out-scope
     - Restrict Azure Monitor deployments to in-scope functionalities.
     - L
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a 'Deny' policy that prevents deployments of out-scope Azure resource types.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-amo-06
     - Azure Monitor Data Collection Rules: Restrict destination Azure Monitor Workspace
     - Enforce that the target Azure Monitor Workspace of the Data Collection Rule is in the same Subscription to prevent cross Usage or cross Application system flows.
     - H
     - C = 1/3
     - PO DevOps team
     - Team Azure Ignite
     - DevOps team
     - Enforce that the target Azure Monitor Workspace of the Data Collection Rule is in the same Subscription as the rule to prevent cross Usage or cross Application system flows.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-amo-07
     - Azure Monitor Data Collection Rules: Restrict Data Collection Endpoint.
     - Enforce that the Data Collection Endpoint of the Data Collection Rule is in the same Subscription to prevent cross Usage or cross Application system flows.
     - H
     - C = 1/3
     - PO DevOps team
     - Team Azure Ignite
     - DevOps team
     - Enforce that the Data Collection Endpoint of the Data Collection Rule is in the same Subscription as the rule to prevent cross Usage or cross Application system flows.
     - Microsoft Defender for Cloud. Compliant policy.

These controls relate to **Log Analytics Workspace** capabilities:

.. list-table::
   :widths: 05 20 25 05 05 05 05 05 15 10
   :header-rows: 1

   * - ID
     - Description
     - Rationale
     - Risk (H/M/L)
     - Applicable CIA rating
     - Owner
     - Responsible for monitoring
     - Responsible for implementation
     - Control framework
     - Proof
   * - drcp-log-01
     - Agent keys.
     - In the agents functionality there are certain keys included in the workspace. These keys offer local authentication which DRCP actively disallows.
     - H
     - C = *
     - PO DevOps team
     - Team Azure Ignite
     - DevOps team
     - Create a custom role which can't view or regenerate these Agent keys.
     - Microsoft Defender for Cloud. Compliant policy for disabled roles and Azure RBAC.
   * - drcp-log-02
     - Data Export.
     - Data export rules offer exporting workspace data to storage accounts. DRCP limited this feature due to security concerns about the confidentiality of exported data. DRCP allows exporting data from a Log Analytics Workspace to an Azure Storage Account within the same Subscription. Exporting data to a Storage Account in a different Subscription or to an Event Hub isn't permitted.
     - H
     - C = *
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy which disables the Data Export feature.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-log-03
     - Linked Storage Accounts.
     - It's possible to store queries into a Storage Account, which can also contain sensitive data. Disabled Linked Storage Accounts.
     - M
     - C = *
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy which disables the Linked Storage Accounts feature.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-log-04
     - Legacy features.
     - Legacy features are on a deprecation path, and also pose security risks due to necessary shared key access. DRCP actively avoids deprecated features which pose as a security risk
     - M
     - C = *
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy which limits the functionality of Log Analytics Workspace Legacy features.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-log-05
     - Workspace-context access mode.
     - Log access is possible on resource-context level or on workspace-context level. Resource-context offers the possibility of including log access through IAM roles, therefor DRCP avoids giving implicit access at workspace context level at the same time.
     - M
     - C = *
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy which limits the functionality of Log Analytics Workspace access modes.
     - Microsoft Defender for Cloud. Compliant policy.

These controls relate to **Application Insights** capabilities:

.. list-table::
   :widths: 05 20 25 05 05 05 05 05 15 10
   :header-rows: 1

   * - ID
     - Description
     - Rationale
     - Risk (H/M/L)
     - Applicable CIA rating
     - Owner
     - Responsible for monitoring
     - Responsible for implementation
     - Control framework
     - Proof
   * - drcp-appi-01
     - Authentication.
     - | Users can either choose to use local authentication (API Keys) or Microsoft Entra ID authentication for Application Insights. Use Microsoft Entra ID authentication instead of local authentication to prevent unauthorized access. Ingestion from public sources can except from this control by applying tag ``usedBy`` with value ``PublicSource``.
       | ⚠️ **Warning:** Use this tag for its intended purpose. Using it otherwise isn't allowed.
     - H
     - C = 1/3
     - PO DevOps team
     - Team Azure Ignite
     - DevOps team
     - Enforce an audit policy which limits the authentication method to Microsoft Entra ID. Instances with tag ``usedBy`` and value ``PublicSource`` aren't audited.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-appi-02
     - Log storage.
     - Log Analytics Workspaces offer encryption for stored logs, when these logs are sensitive it's highly recommended for Application Insights Logs to stream to a Log Analytics Workspace. Use Workspace based ingestion instead of classic Workspace.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy which denies creating Application Insights without linking it to a Log Analytics Workspace.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-appi-03
     - Tests.
     - Disabled automated tests within Application Insights due to team test automation offering this.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy which denies the creation of tests within a Application Insight.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-appi-04
     - Diagnostic settings.
     - Diagnostic settings log categories such as events, exceptions, traces and requests can contain sensitive data which aren't allowed for export.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy which disables the export of these Diagnostic Settings categories
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-appi-05
     - Javascript Source Map Blob Storage URL.
     - This settings allows for a connection to a Storage Account. Disallowed unless presented a clear use case.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy which disables Javascript Source Map Blog Storage URL configuration on Application Insights.
     - Microsoft Defender for Cloud. Compliant policy.

These controls relate to **Managed Grafana** capabilities:

.. list-table::
   :widths: 05 20 25 05 05 05 05 05 15 10
   :header-rows: 1

   * - ID
     - Description
     - Rationale
     - Risk (H/M/L)
     - Applicable CIA rating
     - Owner
     - Responsible for monitoring
     - Responsible for implementation
     - Control framework
     - Proof
   * - drcp-amg-01
     - Use of private DNS zones for private endpoints.
     - Managed Grafana should be accessible through private endpoints that have their DNS records centrally registered in a private DNS zone group.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a DeployIfNotExist policy to remediate.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-amg-02
     - Disable public network access.
     - Disabling public network access improves security by ensuring that the Azure Managed Grafana workspace isn't exposed on the public internet. DevOps-teams should use private endpoints for access.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a Deny policy on all usages.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-amg-03
     - Disable Grafana Enterprise
     - Block Managed Grafana Enterprise to enforce cost control, maintain a consistent Azure-managed security model, and prevent unauthorized adoption of unsupported enterprise features.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a Deny policy on all usages.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-amg-04
     - Disable service accounts.
     - Block service accounts in Managed Grafana to enforce identity governance by ensuring all access flows through Microsoft Entra-ID managed identities and preventing unmanaged, non-auditable credentials.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a Deny policy on all usages.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-amg-05
     - Disable plugins.
     - Block plugins in Managed Grafana to maintain a secure and standardized environment by preventing unvetted extensions, reducing attack surface, and enforcing platform integrity.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce an Audit policy on all usages.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-amg-06
     - Disable SMTP.
     - Disable SMTP in Managed Grafana to prevent unauthorized outbound email channels, reduce exfiltration risk, and enforce secure, centrally managed communication pathways.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a Deny policy on all usages.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-amg-07
     - Disallow connections to Azure Monitor Workspaces outside of current Subscription.
     - Enforce that the linked Azure Monitor Workspace is in the same Subscription to prevent cross Usage or cross Application system flows.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a Deny policy on all usages.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-amg-08
     - Grafana version.
     - Audit for latest version of (Managed) Grafana.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce an Audit policy on all usages.
     - Microsoft Defender for Cloud. Compliant policy.

.. include:: ../../_static/include/security-baseline-footer.txt
