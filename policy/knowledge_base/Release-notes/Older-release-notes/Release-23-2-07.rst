Release 23-2 07
===============
Release date: June 20, 2023


What's new for users
--------------------
- Older versions than v3 for Azure App Service Environments can't provision anymore as decided in the App Service security baseline.
- Integration Service Environments can't provision anymore as decided in the App Service security baseline.
- Added a policy which completes the private DNS registration for queue private endpoints (on a Storage Account).
- Added a policy which completes the private DNS registration for table private endpoints (on a Storage Account).
- Added a policy which completes the private DNS registration for data lake private endpoints (on a Storage Account).
- Added a policy which completes the private DNS registration for Azure Key Vault HSM private endpoints.
- Added documentation for :doc:`Azure Key Vault <../../Azure-components/Key-Vault>`, :doc:`Azure Storage Account <../../Azure-components/Storage-Account>` and :doc:`Azure Event Hubs <../../Azure-components/Event-Hubs>`.

Fixed issues
------------
- Fixed an issue where recent altered policies blocked the creation of functions within Function Apps.
- Fixed an issue where recent altered policies blocked the creation of host keys and function keys within Function Apps.

Lifecycle management
--------------------
- The App Service component is now promoted from Alpha to Beta phase.
- The Key Vault component is now promoted from Beta to MVP phase.
- The Storage Account component is now promoted from Beta to MVP phase.
- The Event Hubs component is now promoted from Beta to MVP phase.
