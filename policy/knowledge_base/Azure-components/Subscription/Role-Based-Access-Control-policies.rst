Role Based Access Control policies
==================================

.. contents::
   Contents:
   :local:
   :depth: 2

| Policies are active on DRCP delivered Azure Subscriptions that may affect certain deployments or certain functionality for DevOps teams.
| This page describes the technical Role Based Access Control policies that are active on every environment. These are part of the APG DRCP Policy assignment on scope of the Subscription and in line with the :doc:`Subscription security baseline <Subscription-Baseline>`.

Generic allowed administrator and data roles
--------------------------------------------

| These two policies control the allowed principals for administrative and data roles:

- ``APG DRCP RBAC Allowed admin roles``
- ``APG DRCP RBAC Allowed data roles``

| These policies mean DevOps teams aren't allowed to assign the privileged built-in roles of an MVP Azure component to any object or identity except the identities mentioned below.

- The DRCP environment engineer group in usage Development (for example ``F-DRCP-<AS>-<ENV>-Engineer-001-ASG``).
- The DRCP environment engineer privileged group in usages Test, Acceptance and Production (for example ``F-DRCP-<AS>-<ENV>-Engineer-Privileged-001-ASG``). This privileged group is for troubleshooting or hot fix purposes. A user becomes a member of this group, after Azure PIM activation and approval.
- The DRCP environment operator privileged group in usage Production (for example ``F-DRCP-<AS>-<ENV>-Operator-Privileged-001-ASG``). This privileged group is for troubleshooting or hot fix purposes. A user becomes a member of this group, after Azure PIM activation and approval.
- The environment deployment service principal (for example ``SP-App-<AS>-<ENV>-ADO-001``).
- A managed identity or app registration within the environment.

Assignments to individual users and groups aren't allowed and blocked by these policies.

.. note:: Not all DRCP enabled Azure components have reached the MVP status (yet). Check :doc:`this page <../../Azure-components>` for an actual overview.
.. note:: These policies don't block the ``Key Vault Reader`` role assignment since this role allows a user to check if a secret or key exists without seeing the content.

Component specific roles
------------------------

| Policies named as ``APG DRCP RBAC <Role name> role`` control which principals can use the role as specified in the policy name.
| For example, policy ``APG DRCP RBAC Monitoring Contributor role`` controls which identities can use the ``Monitoring Contributor`` role.

.. note:: The policy input parameters define the role definition Id and allowed principal Ids. For this reason, the exact role definitions and principals aren't documented here.
