Policy exemptions
=================

.. contents::
   Contents:
   :local:
   :depth: 2

DRCP enforces policies on Azure Subscriptions that may affect deployments or functionality for DevOps teams and their solutions.

This page describes all deviations on policy effects (such as Deny or Audit) which differs between usage development and other usages such as test, acceptance, and production.

.. note:: The term 'exemption' on this page **isn't** related to the technical Azure `policy exemption capability <https://learn.microsoft.com/en-us/azure/governance/policy/concepts/exemption-structure>`__ in the Azure portal.

.. warning:: A valid use case to deviate from the default DRCP policy is mandatory. If you think the DevOps team might run into this, report it to the CCC.

.. note:: This overview contains active policies on Azure Subscriptions. Some may not have the MVP status. Check :doc:`this page <../../Azure-components>` for an overview.

|

.. list-table::
   :widths: 05 05 10 05
   :header-rows: 1

   * - Policy
     - Policy effect
     - Explanation
     - Details
   * - APG DRCP KeyVault Enable purge protection
     - Audit on usage development and deny on usages test, acceptance and production.
     - The enabled purge protection doesn't allow complete removal of a key vault or object (such as a key or secret) until the retention period has passed. The vault and objects have unique names so with this option on it's cumbersome for DevOps teams if you do a lot of testing.
     - `More info about the setting <https://learn.microsoft.com/en-us/azure/key-vault/general/soft-delete-overview>`__
   * - APG DRCP App Service HTTP 2.0
     - Audit on usage development and deny on usages test, acceptance and production.
     - Because this setting isn't available in the Azure portal to create the component, and this is a permissible way to deploy on development usage, it's set to audit. By default, the Azure portal configures it to be HTTP 1.1, while the policy requires HTTP 2.0. This setting doesn't entail any (major) security improvements, so the risk is low.
     - `More info about the setting <https://azure.microsoft.com/en-us/blog/announcing-http-2-support-in-azure-app-service/>`__
