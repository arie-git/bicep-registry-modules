Release 23-3 06
===============
Release date: August 30, 2023


What's new for users
--------------------
- Added documentation for :doc:`Cosmos DB <../../Azure-components/Cosmos-DB/Use-cases>`.

Fixed issues
------------
- Fixed an issue where the minimum TLS version for SQL Database was never compliant.
- Fixed an issue in the Application Gateway policy that denied WAF_V2 as SKU.
- Fixed an issue where the RBAC Owner role policy contained the wrong app registration identifier.
- Fixed an issue where the master database of a SQL Server was never compliant.
- Fixed an issue where the removal of an environment didn't remove the VNet peering with the hub, while the reserved address space is already removed from Infoblox (in some specific cases).
