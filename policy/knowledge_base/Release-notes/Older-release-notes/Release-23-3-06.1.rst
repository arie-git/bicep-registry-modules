Release 23-3 06.1
=================
Release date: September 12, 2023


What's new for users
--------------------
- Added documentation for :doc:`Container Registry <../../Azure-components/Container-Registry/Use-cases>`.
- Added a policy with ``modify`` effect that automates the inheritance of the DRCP Subscription tags to underlying (created or updated) resources, such as 'ApplicationSystem' and 'BusinessUnit'. Please execute policy remediation manually to update existing resources.
- Added a policy that allows the assignment of the SQL DB Contributor and SQL Server Contributor roles to the administrator group of an environment. See :doc:`Use cases SQL Database <../../Azure-components/SQL-Database/Use-cases>`.
- Updated the effect of the Storage Account policy that requires infrastructure encryption from Audit to Deny.
- Enabled contributor access for BU-CCC to the `Policy-DEV repository <https://dev.azure.com/b957a78843eb1/DRCP-DEV/_git/Policy-DEV>`__.
