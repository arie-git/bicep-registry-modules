Security baseline Service Bus
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
     - January 24, 2024
     - Ivo Huizinga
     - Initial version.
   * - 1.0
     - June 19, 2024
     - Onno Hettema
     - Added identifiers to the baseline controls.

.. |AzureComponent| replace:: Service Bus
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
   * - drcp-sbns-01
     - Minimal TLS version.
     - The default TLS version for namespaces is TLS 1.2, but customers can still choose 1.1 and 1.0 for backward compatibility.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy other than TLS 1.2.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sbns-02
     - Disallow local authentication.
     - Improve security by ensuring that namespaces and its entities require Microsoft Entra ID identities for authentication. The advantage is that it also disables Shared Access Keys.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy to disable local authentication.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sbns-03
     - Disable Public Network Access.
     - To enhance network security, you can configure the Service Bus to disable public network access. This will deny all public configurations and allow connections through private endpoints.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: Service Bus should disable public network access.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sbns-04
     - Use of private DNS zones for private endpoints.
     - Service Bus should be accessible through private endpoints that have their DNS records centrally registered in a private DNS zone group.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a DeployIfNotExist policy to remediate.
     - Microsoft Defender for Cloud. Compliant policy.

.. include:: ../../_static/include/security-baseline-footer.txt