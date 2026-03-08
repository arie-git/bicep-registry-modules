Security baseline Notification Hubs
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
   * - 1.0
     - December 12, 2024
     - Raymond Smits
     - Initial version.

.. |AzureComponent| replace:: Notification Hubs
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
   * - drcp-ntf-01
     - Disallow default access policies.
     - Access Policies in Azure Notification Hubs define permissions for operations such as Listen, Send, and Manage. DRCP disallows the 'DefaultFullSharedAccessSignature' and 'DefaultListenSharedAccessSignature' default policies to prevent unauthorized or excessive access, recommending their removal and replacement with custom policies.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce an audit policy: disallow default access policies.
     - Microsoft Defender for Cloud. Compliant policy.

.. include:: ../../_static/include/security-baseline-footer.txt
