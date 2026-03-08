Release 24-3 05
===============
Release date: August 27, 2024

.. warning:: Upcoming breaking change: DRCP will harden Azure Disk by denying unattached disks to align with corporate policy and DRCP environment design in upcoming releases this PI. See the linked feature to learn when DRCP releases the related Azure policies for which usage. `[ISF-6574] <https://jira.office01.internalcorp.net:8443/browse/SAA-6574>`__
.. warning:: Upcoming breaking change: During upcoming releases, DRCP enforces the enablement of zone redundancy for Cosmos DB production Environments. `[SAA-9149] <https://jira.office01.internalcorp.net:8443/browse/SAA-9149>`__

Fixed issues
------------
- Resolved an issue in the (PowerShell ``Az`` module based) automation of DRCP Environment creation/refresh to make it compatible with version ``2024.0812.0402`` of the `Azure DevOps build agent image <https://confluence.office01.internalcorp.net:8453/spaces/LLDCSHAS/pages/287351838/ubuntu2204+-+preview>`__. `[SAA-9174] <https://jira.office01.internalcorp.net:8443/browse/SAA-9174>`__
- Resolved an issue in baseline control ``drcp-ado-12`` that was preventing disabled DRCP service connections from reporting compliance. `[SAA-8580] <https://jira.office01.internalcorp.net:8443/browse/SAA-8580>`__
- Removed old Action Groups not following the naming convention. `[SAA-7478] <https://jira.office01.internalcorp.net:8443/browse/SAA-7478>`__

What's new for users
--------------------
- Updated the ``APG DRCP Application Gateway WAF Disable Custom Rules`` policy to allow rate limiting. `[SAA-8913] <https://jira.office01.internalcorp.net:8443/browse/SAA-8913>`__
- Added policy ``APG DRCP CosmosDB Zone redundancy enabled`` to enable zone redundancy for Cosmos DB. For now the policy will audit the enablement of zone redundancy. `[SAA-7848] <https://jira.office01.internalcorp.net:8443/browse/SAA-7848>`__
- Added drcp-cosmos-10 to :doc:`security baselines <../../Azure-components/Cosmos-DB/Security-Baseline>` and :doc:`incident remediation <../../Azure-components/Cosmos-DB/Incident-remediation>`.
- Added reference to :doc:`Internal root certificate chain <../../Application-development/Certificates/Internal-root-certificate-chain>` in :doc:`Endpoint for role assignment <../../Platform/DRCP-API/Endpoint-for-role-assignment>`. `[SAA-9309] <https://jira.office01.internalcorp.net:8443/browse/SAA-9309>`__
- Added policy ``APG DRCP Defender for Storage Malware Scanning`` for enabling malware scanning feature for Defender for Storage `[SAA-9029] <https://jira.office01.internalcorp.net:8443/browse/SAA-9029>`__