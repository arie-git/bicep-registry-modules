Incident remediation AI Search
==============================

.. |AzureComponent| replace:: AI Search
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-srch-01
     - Disallow local authentication.
     - `Disable local authentication methods <https://learn.microsoft.com/en-us/azure/search/search-security-enable-roles?tabs=config-svc-portal%2Cdisable-keys-portal#enable-role-based-access-for-data-plane-operations>`__ improves security by ensuring that AI Search services require Microsoft Entra ID identities for authentication. Keys are temporary allowed if DevOps teams apply a certain tag, due to the custom question answering feature which has a limitation in the way the connection is setup between AI Language and AI Search. More information see :doc:`Use cases <Use-cases>`.

   * - drcp-srch-02
     - Disallow public network access.
     - `Disable public network access <https://learn.microsoft.com/en-us/azure/search/service-configure-firewall>`__ on the AI Search.

   * - drcp-srch-03
     - Disable data ex-filtration.
     - `Disable data ex-filtration <https://learn.microsoft.com/en-us/azure/templates/microsoft.search/2024-03-01-preview/searchservices?pivots=deployment-language-bicep#searchserviceproperties>`__ on the AI Search.

   * - drcp-srch-04
     - Allow approved API versions.
     - `Allow approved API versions <https://learn.microsoft.com/en-us/azure/templates/microsoft.search/change-log/searchservices>`__ on the AI Search.