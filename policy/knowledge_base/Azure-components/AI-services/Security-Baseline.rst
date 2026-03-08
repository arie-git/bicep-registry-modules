Security baseline AI services
=============================

Major change history
--------------------
.. list-table::
   :widths: 5 25 20 5
   :header-rows: 1

   * - Version.
     - Date
     - Name
     - Function/Reason
   * - 0.1
     - October 18, 2024
     - Maciej Chmielewski
     - Initial version.
   * - 1.0
     - October 25, 2024
     - Maciej Chmielewski
     - Added baseline control ``drcp-ai-o01``.

.. |AzureComponent| replace:: AI services
.. include:: ../../_static/include/security-baseline-header1.txt
.. include:: ../../_static/include/security-baseline-header2.txt

.. list-table::
   :widths: 05 20 25 05 05 05 05 05 15 10
   :header-rows: 1

   * - ID.
     - Description
     - Rationale
     - Risk (H/M/L)
     - Applicable CIA rating
     - Owner
     - Responsible for monitoring
     - Responsible for implementation
     - Control framework
     - Proof
   * - drcp-ai-01
     - Disable local authentication methods.
     - Disabling local authentication methods improves security by ensuring that AI services require Microsoft Entra ID identities for authentication.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable local authentication.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-ai-02
     - Use a managed identity
     - Managed service identity provides more security by not using secrets from other services, such as credentials in the connection strings. When registering with Microsoft Entra ID in AI services, the instance will connect to other Azure services securely without the need for usernames and passwords.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: use a managed identity.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-ai-03
     - Disable public network access.
     - Disabling public network access improves security by ensuring that your AI service isn't exposed on the public internet. Creating private endpoints limits exposure of your AI service.
     - H
     - C = 1/3
     - PO DevOps team
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable public network access.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-ai-04
     - Allow supported kinds.
     - Allowing supported kinds ensures that customers can deploy assessed and approved AI services from a security perspective.
     - H
     - C = 1/3
     - PO DevOps team
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable all AI services apart from supported ones.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-ai-o01
     - Disable global deployment models.
     - Disabling Global Standard, Global Batch and Global Provisioned deployment models ensures that OpenAI will process data in the region where it's deployed.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable Global Standard, Global Batch and Global Provisioned deployment models.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-ai-o02
     - Disable trusted services.
     - Disabling trusted services ensures that other services can't connect to the OpenAI service in other way than by using Private Endpoints.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable trusted services to connect to OpenAI.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-ai-o03
     - Allow approved models.
     - Allowing approved models ensures that customers can deploy assessed and approved models in OpenAI from a security perspective.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable all models apart from trusted ones.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-ai-o04
     - Disable custom content filters.
     - Disabling creation of custom content filters prevents customers from using other filters than the default ones.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable creation of custom filters.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-ai-l01
     - Language accounts should use customer owned storage.
     - Use customer owned storage to control the data stored at rest in Language.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Set an audit policy: advanced threat protection isn't disabled.
     - Microsoft Defender for Cloud: Compliant policy.

.. include:: ../../_static/include/security-baseline-footer.txt