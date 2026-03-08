Release 23-2 05
===============
Release date: May 23, 2023


What's new for users
--------------------
- It's now possible to use the Quick action Request temporary access to get elevated permissions in Azure and Azure DevOps.
- Component baselines is available for Azure API Management.
- Processed Audit effect Bypass Firewall for Azure Services for Key Vault.


Fixed issues
------------
- Fixed an issue with automatic DNS registration of private endpoints.
- Fixed an issue where policy exemptions were always altered or removed after an environment refresh. Policies are now updated in-place to overcome this issue.
- Fixed an issue where policies blocked the creation of private endpoints and AppServiceLinks.
- Fixed an issue where the Subscriptions of removed environments weren't always cancelled.
- Fixed an issue where the use of the mandatory extends template required manual permissions from DRCP.
