Release 25-3 02
===============
Release date: July 15, 2025

.. warning::
  | **Breaking changes**

  - DRCP enforces local authentication restrictions on Application Insights instances in usages development, test and acceptance through setting policy: ``APG DRCP Application Insights disable local authentication`` to deny effect. `[SAA-10470] <https://jira.office01.internalcorp.net:8443/browse/SAA-10470>`__

What's new for users
--------------------
- DRCP removed the not supported use case of `Data Engineering: stream processing of data, including event-based micro-batching (Delta Live Tables and Auto Loader)` from Databricks. `[SAA-14337] <https://jira.office01.internalcorp.net:8443/browse/SAA-14337>`__
- DRCP added Databricks baseline `drcp-adb-w28`, see :doc:`Security baseline Databricks <../../Azure-components/Databricks/Security-Baseline>`. `[SAA-14361] <https://jira.office01.internalcorp.net:8443/browse/SAA-14361>`__
- Added LCM review for :doc:`Event Hubs <../../Azure-components/Event-Hubs>`. `[SAA-8352] <https://jira.office01.internalcorp.net:8443/browse/SAA-8352>`__
- Added LCM review for :doc:`Service Bus <../../Azure-components/Service-Bus>`. `[SAA-8020] <https://jira.office01.internalcorp.net:8443/browse/SAA-8020>`__
- Updated draft pages of beta component :doc:`Azure Monitor <../../Azure-components/Monitor>` and added its :doc:`security baseline <../../Azure-components/Monitor/Security-Baseline>`. `[SAA-14124] <https://jira.office01.internalcorp.net:8443/browse/SAA-14124>`__
- Added the BU-CCC as `Production Engineer` privilged access :doc:`approver <../../Getting-started/Roles-and-authorizations>` next to the product owner and ICT Operating & Control. `[SAA-14904] <https://jira.office01.internalcorp.net:8443/browse/SAA-14904>`__

Fixed issues
------------
- DRCP fixed an issue where the ``Support access`` was reset during an Environment refresh. `[SAA-14842] <https://jira.office01.internalcorp.net:8443/browse/SAA-14842>`__

Internal platform improvements
------------------------------
- Added preparations for policy checking Azure roles related to the Platform or DRCP Azure Components. `[SAA-12050] <https://jira.office01.internalcorp.net:8443/browse/SAA-12050>`__
- DRCP took the next step in adding conditional access to App registrations, by applying conditional access to App registrations in the internal DRCP ACC-stack. Customer App registrations aren't affected. `[SAA-7266] <https://jira.office01.internalcorp.net:8443/browse/SAA-7266>`__
