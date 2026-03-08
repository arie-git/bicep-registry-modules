Release 24-2 07.1
=================
Release date: June 18, 2024

.. note:: Due to policy 'APG DRCP StorageAccount Defender' after refresh of an Environment it's possible that the policy is incompliant which results in an incident. To remediate this incident, put it in the resolve state because it requires no further action.

What's new for users
--------------------
- Promoted the Databricks component to MVP. `[SAA-6872] <https://jira.office01.internalcorp.net:8443/browse/SAA-6872>`__
- Enabled 'malware scanning' for storage account. `[SAA-8462] <https://jira.office01.internalcorp.net:8443/browse/SAA-8462>`__
- Updated the :doc:`App Service use case documentation <../../Azure-components/App-Service/Use-cases>` to clarify the region restrictions for Static Web Apps. `[SAA-8500] <https://jira.office01.internalcorp.net:8443/browse/SAA-8500>`__
- Updated the :doc:`Application Gateway use case documentation <../../Azure-components/Application-Gateway/Use-cases>` to clarify that the OWASP rule set used in the Microsoft examples isn't compliant to the Application Gateway security baseline. `[SAA-8500] <https://jira.office01.internalcorp.net:8443/browse/SAA-8500>`__
- AM-CCC handed over the Databricks collector code for compliance to DRCP and is now part of the DRCP platform. `[SAA-8134] <https://jira.office01.internalcorp.net:8443/browse/SAA-8134>`__
- :doc:`Databricks Use cases article <../../Azure-components/Databricks/Use-cases>` is now up to date with feedback from the beta phase. `[SAA-8462] <https://jira.office01.internalcorp.net:8443/browse/SAA-7153>`__
- Implemented restricted access policy ``APG DRCP CosmosDB Public Network Disabled Or Selected IPs`` to Azure Portal for CosmosDB via selected Azure data center IPs `[SAA-4884] <https://jira.office01.internalcorp.net:8443/browse/SAA-4884>`__
- The URL of the remediation solution and the security baseline is now stored together with security baseline control in ServiceNow. `[SAA-8149] <https://jira.office01.internalcorp.net:8443/browse/SAA-8149>`__

Fixed issues
------------
- Fixed an issue where revoke of ``Request temporary access`` failed on a removed Environment. `[SAA-8419] <https://jira.office01.internalcorp.net:8443/browse/SAA-8419>`__
- Fixed an issue where new ADO permission ``Edit queue build configuration`` wasn't set for users and engineers, see :doc:`Roles and authorizations <../../Getting-started/Roles-and-authorizations>`. `[SAA-8529] <https://jira.office01.internalcorp.net:8443/browse/SAA-8529>`__
- Fixed an issue where audit policy alerts didn't create an incident in ServiceNow. `[SAA-8457] <https://jira.office01.internalcorp.net:8443/browse/SAA-8457>`__
