Security baseline Data Factory
==============================

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
     - December 11, 2023
     - Suman Kumar
     - Initial version.
   * - 1.0
     - June 19, 2024
     - Onno Hettema
     - Added identifiers to the baseline controls.

.. |AzureComponent| replace:: Data Factory
.. include:: ../../_static/include/security-baseline-header1.txt
.. include:: ../../_static/include/security-baseline-header2.txt

.. list-table::
   :widths: 5 25 20 5 05 05 05 20 10 20
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
   * - drcp-adf-01
     - Establish network segmentation boundaries
     - To ensure the security of the APG data processing in Data Factories, all such workloads should be in isolated networks that allow the restriction and monitoring of traffic. As of now managed Integration Runtimes (Azure IR and SSIS IR) of ADF don't support this.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a 'Deny' policy: Data Factory shouldn't use managed Integration Runtimes.
     - Azure Policy compliancy status = Compliant
   * - drcp-adf-02
     - Disable public network inbound access for Self-Hosted Integration Runtimes.
     - Communication between integration runtimes and ADF control plane in Azure shouldn't use public access.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a 'Deny' policy: Data Factory should disable public network access.
     - Azure Policy compliancy status = Compliant
   * - drcp-adf-03
     - Ensure access to Azure Data Factory portal from APG network is via a private network
     - ADF Portal experience is a cross-tenant shared service that manages the configuration of ADF and offers pipeline development experience. It uses public access by default, but allows to override the FQDN resolution into a single private access endpoint for the whole global private network.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Create a private endpoint to ADF 'portal' centrally in DRCP. Configure a registration of 'portal' endpoint with APG global DNS. Data Factory portal can still can access through the public IP from public networks, so the authentication into Azure tenant of APG should restrict to private network perimeter.
     - Azure Policy compliancy status = Compliant
   * - drcp-adf-04
     - Restrict the exposure of credential and secrets
     - When it's impossible to use Microsoft Entra ID authentication with data stores (for example, on-premise systems, external Azure and non-Azure endpoints), then ADF can use other mechanisms that involve the use of secrets. ADF internally stores secrets in encrypted form. When provisioning Azure services, the ADF instance may receive the secrets in an decrypted form. To avoid this, store the secrets in an Azure Key Vault rather than within the Azure Data Factory itself.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a 'Deny' policy: Data Factory Linked Services shouldn't store secrets
     - Azure Policy compliancy status = Compliant
   * - drcp-adf-05
     - Use approved data services.
     - Data Factory supports more data services, and some of them may considered as not safe for use in APG. Restrict which services users can use.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a 'Deny' policy: Data Factory can use Linked Services that are in approved list
     - Azure Policy compliancy status = Compliant
   * - drcp-adf-06
     - Ensure DevOps way-of-working suitable for ADF
     - To back up all code on Azure Data Factory, use source control functionality in Data Factory. Restrict which repository can used.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a 'Deny' policies: Data Factory can use  Azure DevOps repository in the 'DEV' sort of application environment, and the repository is in the list of allowed.
     - Azure Policy compliancy status = Compliant
   * - drcp-adf-07
     - Purview integration isn't allowed
     - Purview in APG isn't supported. To avoid data escape to an unsupported service, the Purview integration should disabled.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a 'Deny' policies: Data Factory shouldn't use Purview integration.
     - Azure Policy compliancy status = Compliant

.. include:: ../../_static/include/security-baseline-footer.txt