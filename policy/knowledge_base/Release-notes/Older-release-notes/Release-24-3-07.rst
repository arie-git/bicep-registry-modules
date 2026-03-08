Release 24-3 07
===============
Release date: September 24, 2024

.. warning:: Upcoming breaking change: During upcoming releases, DRCP enforces the enablement of zone redundancy for Cosmos DB production Environments. `[SAA-9149] <https://jira.office01.internalcorp.net:8443/browse/SAA-9149>`__

.. warning:: During the scheduled maintenance weekend of October 5, 2024, the connection from APG migrates from an IPsec VPN over internet to an IPsec VPN over an Azure ExpressRoute Circuit. The new setup won't result in any functional changes, but expect interruptions with 1 to 2 hours duration that affect all environments on all Azure landing zones. The purpose of this migration is to make the connections to APG's Azure landing zones more robust. See `[CHG1863685] <https://apgprd.service-now.com/nav_to.do?uri=change_request.do?sys_id=a40080b1ebacde54d94cf14e1bd0cdb8>`__ for more information.

What's new for users
--------------------
- Removed permissions from the role ``APG Custom - DRCP - Contributor`` that allows to enable or disable Defender for Cloud plans, as DRCP manages these. For an actual overview of permissions assigned to DRCP roles, see :doc:`Roles and authorizations <../../Getting-started/Roles-and-authorizations>`. `[SAA-8680] <https://jira.office01.internalcorp.net:8443/browse/SAA-8680>`__
- Added policy ``APG DRCP Kubernetes Services should be upgraded to a non-vulnerable Kubernetes version`` to warn against vulnerable Kubernetes versions for baseline control drcp-aks-12. `[SAA-9374] <https://jira.office01.internalcorp.net:8443/browse/SAA-9374>`__
- Updated :doc:`Use cases Kubernetes Service <../../Azure-components/Kubernetes-Service/Use-cases>` with supported Kubernetes versions. `[SAA-9374] <https://jira.office01.internalcorp.net:8443/browse/SAA-9374>`__
- Updated :doc:`Use cases Kubernetes Service <../../Azure-components/Kubernetes-Service/Use-cases>` with deny of Azure Disk creation. `[SAA-9374] <https://jira.office01.internalcorp.net:8443/browse/SAA-9374>`__

Fixed issues
------------
- Fixed automated control ``drcp-adb-w22`` for Databricks to include a check on `compute custom containers <https://learn.microsoft.com/en-us/azure/databricks/compute/custom-containers>`__ , prohibited by the security baseline. `[SAA-8474] <https://jira.office01.internalcorp.net:8443/browse/SAA-8474>`__
