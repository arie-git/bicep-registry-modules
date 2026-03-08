Security baseline Container Registry
====================================

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
     - January 24, 2023
     - Onno Hettema
     - Initial version.
   * - 0.5
     - January 25, 2023
     - Onno Hettema, Bert Wolters, Bas van den Putten.
     - Initial version
   * - 1.0
     - June 19, 2024
     - Onno Hettema
     - Added identifiers to the baseline controls.
   * - 1.1
     - January 15, 2025
     - Pascal Dortants
     - Removed control ``drcp-cr-07``.
   * - 1.2
     - December 11, 2025
     - Pieter van der Sluis
     - Added control ``drcp-cr-09`` to deny connected registries from other tenants.

.. |AzureComponent| replace:: Container Registry
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
   * - drcp-cr-01
     - Anonymous authentication
     - Disable anonymous pull for your registry so that data isn't accessible by an unauthenticated user. Disabling local authentication methods like the administrator user, repository scoped access tokens and anonymous pull improves security by ensuring that container registries require Microsoft Entra ID identities for authentication.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable anonymous pull enabled.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-cr-02
     - ARM audience token authentication
     - Disable Microsoft Entra ID ARM audience tokens for authentication to your registry. Azure Container Registry (ACR) will use audience tokens for authentication. Disabling ARM audience tokens doesn't affect administrator user's or scoped access tokens' authentication.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable the ARM audience token authentication.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-cr-03
     - Local administrator account
     - Disable administrator account for your registry so that it isn't accessible by a local administrator. Disabling local authentication methods like the administrator user, repository scoped access tokens and anonymous pull improves security by ensuring that container registries require Microsoft Entra ID identities for authentication.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable the local administrator account.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-cr-04
     - Public network access
     - Disable public network access for your Container Registry resource so that it's not accessible over the public internet. This can reduce data leakage risks.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable public network access.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-cr-05
     - Repository scoped access token
     - Disable repository scoped access tokens for your registry so that repositories aren't accessible by tokens. Disabling local authentication methods like the administrator user, repository scoped access tokens and anonymous pull improves security by ensuring that container registries require Microsoft Entra ID identities for authentication.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable the repository scoped access token.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-cr-06
     - Disable exports
     - Disabling exports improves security by ensuring data in a registry is accessible solely via the data plane (``docker pull``). Data can't moved out of the registry via ``acr import`` or via ``acr transfer``. To disable exports, disable also public network access.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy: disable exports.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-cr-08
     - Private endpoints
     - Private endpoints connect your virtual network to Azure services without a public IP address at the source or destination. By mapping private endpoints to your premium container registry resources, you can reduce data leakage risks.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy: configure DNS zone for registry private endpoints.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-cr-09
     - Connected Registries
     - It grants the ability to connect registries from other tenants. Reduces third party risk, by not allowing direct integration with a third party and ensures compliance with the change process.
     - H
     - C = 2/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: For "Connected Registries."
     - Compliant policy.

.. include:: ../../_static/include/security-baseline-footer.txt
