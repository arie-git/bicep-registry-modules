Release 24-4 04
===============
Release date: November 19, 2024

.. warning:: Upcoming breaking change: During upcoming releases, DRCP enforces the Load Balancer Private IP in frontend configuration. `[SAA-10168] <https://jira.office01.internalcorp.net:8443/browse/SAA-10168>`__

.. warning:: Upcoming breaking change: During upcoming releases, DRCP enforces the minimum TLS 1.2 protocol version for Application Gateway production Environments. `[SAA-9969] <https://jira.office01.internalcorp.net:8443/browse/SAA-9969>`__

.. warning:: Upcoming breaking change: During upcoming releases, DRCP blocks deleting the LTR backup of SQL Database. `[SAA-9664] <https://jira.office01.internalcorp.net:8443/browse/SAA-9664>`__

Fixed issues
------------

What's new for users
--------------------
- Added OpenAI to DRCP's regression tests. `[SAA-9581] <https://jira.office01.internalcorp.net:8443/browse/SAA-9581>`__
- Added AI Language to DRCP's regression tests. `[SAA-8510] <https://jira.office01.internalcorp.net:8443/browse/SAA-8510>`__
- Updated Databricks SDK client to v0.36.0 for latest Cinc compatibility and also added this to LCM. `[SAA-10698] <https://jira.office01.internalcorp.net:8443/browse/SAA-10698>`__
- Adjusted policy ``APG DRCP Storage Account Shared Key Access should be disabled`` to accept FunctionApp or LogicApp as valid values for the ``usedBy`` tag. `[SAA-10382] <https://jira.office01.internalcorp.net:8443/browse/SAA-10382>`__
- Added two new agent-pools, ``CPP-Ubuntu2204-Latest-A`` and ``CPP-Ubuntu2204-Latest-B`` in Azure DevOps. Both include the latest image. The request is to switch to one of the two new pools in Azure DevOps. `[SAA-10879] <https://jira.office01.internalcorp.net:8443/browse/SAA-10879>`__

Preparing for the future
------------------------