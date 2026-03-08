Release and maintenance
=======================

.. contents::
   Contents:
   :local:
   :depth: 2

| DRCP releases **every 2 weeks** at the end of the sprint of team Azure Ignite.
| Each release may contain product improvements, such as: bug repairs, improved functionalities, changes in guardrails, and actions taken for Life Cycle Management.
| These new and improved functionalities are available after the release, and apply to any new environment that's requested.

.. note:: It's important to set up the DTAP environments in such a way, the environments have their :doc:`maintenance <../Getting-started/Definitions-and-abbreviations>`. planned before production environments. If changes due to a DRCP release cause problems, the chance is smaller that the production environment breaks.

Release notes
-------------

| The section :doc:`release notes <../Release-notes>` of the DRCP knowledge base contains a summary of the content of each release.
| Each release has it's own subpage, categorized in the following headings:

- What's new for users
- Fixed issues
- Lifecycle management

If you have questions related to the product or release, please see :doc:`Need help <../Need-help>`.

Maintenance window
------------------
When users request an environment, they need to choose a maintenance window (maintenance day and maintenance time). In this maintenance window, the following happens automatically.

The maintenance process:

- Creates an automated change;
- Refreshes the environment and enforces the new release;
- Closes the automated change.

Environment refresh
^^^^^^^^^^^^^^^^^^^
The environment refresh step in the maintenance window sets the environment back into it's desired state as requested. This won't effect components created within the environment.

The refresh of the environment includes, but isn't limited to, (re)setting of the following configurations:

- Subscription diagnostic settings
- RBAC permissions for DRCP automation
- DRCP tags
- DRCP resource group with spoke VNet and peering
- Azure DevOps project automation
- Azure DevOps service connection secrets, approvals and checks
- Policies
- Resource providers

Hotfix release
--------------
| In case of an incident it's possible that DRCP releases a hotfix or interim release.
| In this case, the DevOps teams will get notified and the release will occur outside the 2 week window.

.. note:: In case of a hotfix or interim release, the sequence number of the release continues. The follow-up regular release is then numbered as 'X.1' where 'X' stands for the sprint number of the hotfix or interim release.

.. note:: Just like regular releases, a hotfix or interim release isn't direct applied to existing environments. To apply, refresh your environment.

Pre-release Knowledge base
--------------------------
You can find a pre-release of the Knowledge base `here <https://confluence.office01.internalcorp.net:8453/display/DRCPDEVKB/DRCP+knowledge+base>`_.

.. warning::
    This version of the Knowledge base is still in development and may contain errors, pre-released features and bug fixes that may not reach a production state. For latest information please :doc:`visit <../index>`.
