Security baseline AI Search
===========================

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
     - October 3, 2024
     - Maciej Chmielewski
     - Initial version.
   * - 0.2
     - December 5, 2024
     - Maciej Chmielewski
     - Added baseline controls ``drcp-srch-03`` and ``drcp-srch-04``.
   * - 1.0
     - February 17, 2025
     - Ivo Huizinga
     - Updated controls ``drcp-srch-01`` and ``drcp-srch-02``.

.. |AzureComponent| replace:: AI Search
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
   * - drcp-srch-01
     - Disable local authentication methods.
     - Disabling local authentication methods improves security by ensuring that AI Search services require Microsoft Entra ID identities for authentication. Keys are temporary allowed if DevOps teams apply a certain tag, due to the custom question answering feature which has a limitation in the way the connection is setup between AI Language and AI Search.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable local authentication.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-srch-02
     - Disable Public network access.
     - Disabling public network access improves security by ensuring that your AI Search service isn't exposed on the public internet. Creating private endpoints can limit exposure of your Search service.
     - H
     - C = 1/3
     - PO DevOps team
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable public network access.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-srch-03
     - Disable data ex-filtration.
     - Disabling data ex-filtration increases the security by ensuring that no one can export data to not trusted targets by leveraging built-in AI Search mechanisms. This option disallows creating any kind of skill sets.
     - H
     - C = 1/3
     - PO DevOps team
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable data ex-filtration.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-srch-04
     - Allow approved API versions.
     - Allowing approved API versions ensures that AI Search respects disallowing data ex-filtration.
     - H
     - C = 1/3
     - PO DevOps team
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable all API versions apart from approved ones.
     - Microsoft Defender for Cloud: Compliant policy.

.. include:: ../../_static/include/security-baseline-footer.txt