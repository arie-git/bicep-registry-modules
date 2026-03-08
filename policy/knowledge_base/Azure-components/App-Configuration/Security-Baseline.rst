Security baseline App Configuration
===================================

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
     - March 18, 2024
     - Ivo Huizinga
     - Initial version.
   * - 1.0
     - June 19, 2024
     - Onno Hettema
     - Added identifiers to the baseline controls.

.. |AzureComponent| replace:: App Configuration
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
   * - drcp-appcs-01
     - Disallow public network access.
     - Disabling public network access improves security by ensuring that the resource isn't exposed on the public internet. You can limit exposure of your resources by creating private endpoints instead.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy to deny the use of public network access.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-appcs-02
     - Disallow local authentication.
     - Disabling local authentication methods improves security by ensuring that App Configuration stores require Microsoft Entra identities for authentication. `Learn more. <https://go.microsoft.com/fwlink/?linkid=2161954.>`__
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy to disable local authentication.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-appcs-03
     - Use of private DNS zones for private endpoints.
     - App Configuration instances should be accessible through private endpoints that have their DNS records centrally registered in a private DNS zone group.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a DeployIfNotExist policy to remediate.
     - Microsoft Defender for Cloud. Compliant policy.

.. include:: ../../_static/include/security-baseline-footer.txt