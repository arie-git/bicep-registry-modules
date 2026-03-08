Settings and policies
=====================

.. contents::
   Contents:
   :local:
   :depth: 2

Introduction
------------
This article contains a description of settings and policies for Azure DevOps.

Organization settings and policies
----------------------------------

DRCP has created the `Azure DevOps organization connectdrcpapg1 <https://dev.azure.com/connectdrcpapg1>`__ in compliancy with the IT Development policy.

Organization, Security Policies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :widths: 15 10 25
   :header-rows: 1

   * - Setting
     - Value
     - Rationale
   * - ``Third-party application access via OAuth``
     - On
     - OAuth is the preferred method of integration over personal access tokens (PATs). DRCP requires third-party applications to use OAuth for authentication.
   * - ``SSH authentication``
     - On
     - DRCP allows the authentication with SSH as an alternative to the use of HTTPS.
   * - ``Log Audit Events``
     - On
     - To meet APG compliance- and governance goals, DRCP tracks and logs the changes in the Azure DevOps organizations. Audit changes occur whenever a user or service identity within the organization edits the state of an artifact. This can be changing permissions, changing agent pools, changing policy or security settings, etc.
   * - ``Restrict personal access token (PAT) creation``
     - Off
     - DRCP allows the use of PAT's, which are sometimes used by extensions. DRCP recommends the use of OAuth authentication for customers.
   * - ``Additional protections when using public package registries``
     - On
     - This provides security for private feeds in Azure Artifacts by limiting access to externally sourced packages when internally sources packages are already present. This provides a new layer of security, which prevents malicious packages from a public registry being inadvertently consumed.
   * - ``Enable IP Conditional Access policy validation``
     - On
     - APG requires Azure DevOps users to comply to all Conditional Access Policies defined in Microsoft Entra ID.
   * - ``External guest access``
     - Off
     - APG can't guarantee the integrity and security of external guest accounts. Only APG Microsoft Entra ID accounts are able to get access to an ADO project, based on group membership, managed by IAM.
   * - ``Allow team and project administrators to invite new users``
     - Off
     - DRCP requires Microsoft Entra ID identities for authentication. The central IAM system (RSA) manages the Microsoft Entra ID groups and group memberships and links these to business roles and technical roles. DRCP doesn't allow single users direct access to Azure DevOps.
   * - ``Request access``
     - Off
     - DRCP requires Microsoft Entra ID identities for authentication. The central IAM system (RSA) manages the Microsoft Entra ID groups and group memberships and links these to business roles and technical roles. DRCP doesn't allow single users direct access to Azure DevOps.
   * - ``Allow Microsoft to collect feedback from users``
     - On
     - This is a new setting in Azure DevOps. DRCP plans to enforce the value of this setting to ``Off``, see `[SAA-14784] <https://jira.office01.internalcorp.net:8443/browse/SAA-14784>`__.

Organization, Pipeline Settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

General
^^^^^^^

.. list-table::
   :widths: 15 10 25
   :header-rows: 1

   * - Setting
     - Value
     - Rationale
   * - ``Disable anonymous access to badges``
     - On
     - DRCP requires Microsoft Entra ID identities for authentication. The central IAM system (RSA) manages the Microsoft Entra ID groups and group memberships and links these to business roles and technical roles. DRCP doesn't allow single users direct access to Azure DevOps.
   * - ``Limit settings of variables at queue time``
     - On
     - DRCP doesn't allow overwriting of system variables and defining new variables at queue time of a pipeline. This ensures that pipelines are running with the functionality as defined by their author.
   * - ``Limit job authorization scope to current project for non-release pipelines``
     - On
     - DRCP reduces the scope of access for all pipelines to the current project and disallows the pipelines to cross the boundary of the Application system.
   * - ``Limit job authorization scope to current project for release pipelines``
     - On
     - DRCP reduces the scope of access for all pipelines to the current project and disallows the pipelines to cross the boundary of the Application system.
   * - ``Protect access to repositories in YAML pipelines``
     - On
     - Apply checks and approvals when accessing repositories from YAML pipelines.
   * - ``Disable stage chooser``
     - Off
     - DevOps teams are responsible for their way of working.
   * - ``Disable creation of classic build pipelines``
     - On
     - DRCP requires the use of yml pipelines. For these pipelines version control and peer review apply.
   * - ``Disable creation of classic release pipelines``
     - On
     - DRCP requires the use of yml pipelines. For these pipelines version control and peer review apply.

Triggers
^^^^^^^^

.. list-table::
   :widths: 15 10 25
   :header-rows: 1

   * - Setting
     - Value
     - Rationale
   * - ``Limit building pull request from forked GitHub repositories``
     - Securely build pull requests from forked repositories
     - Builds of pull requests from forked repositories don't have access to secrets or have the same permissions as regular builds. All pull requests require a team member's comment before building.
   * - ``Disable implied YAML CI Triggers``
     - Off
     - DevOps teams are responsible for their way of working and decide the set-up of their yml pipelines.

Task restrictions
^^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 15 10 25
   :header-rows: 1

   * - Setting
     - Value
     - Rationale
   * - ``Disable built-in tasks``
     - Off
     - DRCP allows the use of build-in tasks.
   * - ``Disable Marketplace tasks``
     - Off
     - DRCP allows the use of Marketplace tasks. When requesting a task from the Marketplace, DRCP will assess if this task is secure and that a reliable supplier supports the task.
   * - ``Disable Node 6 tasks``
     - Off
     - Node 6 tasks are obsolete and can't run at the build servers provided by the platform.
   * - ``Enable shell tasks arguments validation``
     - Off
     - DRCP has used the default setting. DevOps teams are themselves responsible for the correct working of their pipelines.

Organization, Repository settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Advanced Security
^^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 15 10 25
   :header-rows: 1

   * - Setting
     - Value
     - Rationale
   * - ``Secret Protection plan``
     - Off
     - Advanced Security for Azure DevOps is an expensive option which offers limited advantages to APG. Secrets scanning limits to less then 10 different kinds of secrets which are relevant within APG.
   * - ``Code security plan``
     - Off
     - Advanced Security for Azure DevOps is an expensive option which offers limited advantages to APG. Within APG, use JFrog Artifactory for dependency scanning. Sonar is within APG the tool for static code scanning.

All Repositories Settings
^^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 15 10 25
   :header-rows: 1

   * - Setting
     - Value
     - Rationale
   * - ``Gravatar images``
     - On
     - DRCP has used the default setting.
   * - ``Default branch name for new repositories``
     - main
     - Branch policies apply for the main branch. DRCP allows deployment to acceptance and production from the main branch.
   * - ``Disable creation of TFVC repositories``
     - On
     - Use git as version control system.

Project settings and policies
-----------------------------

Project, Azure DevOps Services
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :widths: 15 10 25
   :header-rows: 1

   * - Service
     - Value
     - Rationale
   * - ``Boards``
     - On
     - APG uses Jira for tracking and planning, use Azure Board items for tracing back to Jira items. In the future DRCP and Development Support will provide a limited synchronization between Jira and Azure DevOps ``workitems``.
   * - ``Repos``
     - On
     - DRCP requires the use of Azure Repos, since it fully integrates with Azure Pipelines and other Azure DevOps parts.
   * - ``Pipelines``
     - On
     - DRCP requires the use Azure Pipelines, since it fully integrates with Azure Repos and other Azure DevOps parts.
   * - ``Test Plans``
     - Off
     - APG provides testing tools from the Test Automation team and other tools. Azure Test Plans also require extra license costs.
   * - ``Artifacts``
     - On
     - APG requires the use of JFrog Artifactory for artifacts storage and vulnerability controls. Restrict the use of Azure DevOps Artifacts.

Project, Pipeline settings
~~~~~~~~~~~~~~~~~~~~~~~~~~

Retention policy
^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 15 10 25
   :header-rows: 1

   * - Retention
     - Value
     - Rationale
   * - ``Days to keep artifacts, symbols and attachments``
     - 60
     - DRCP has used the maximum allowed value.
   * - ``Days to keep runs``
     - 120
     - DRCP has used a custom value.
   * - ``Days to keep pull request runs``
     - 30
     - DRCP has used the maximum allowed value.
   * - ``Number of recent runs to retain per pipeline``
     - 50
     - DRCP has used the maximum allowed value.

General
^^^^^^^

The general pipeline settings for Azure DevOps projects are the same as the settings on organizational level.

Triggers
^^^^^^^^

The trigger settings for Azure DevOps projects are the same as the settings on organizational level.

Project, Repository Settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :widths: 15 10 25
   :header-rows: 1

   * - Setting
     - Value
     - Rationale
   * - ``Secret Protection plan``
     - Off
     - Advanced Security for Azure DevOps is an expensive option which offers limited advantages to APG. Secrets scanning limits to less then 10 different kinds of secrets which are relevant within APG.
   * - ``Code security plan``
     - Off
     - Advanced Security for Azure DevOps is an expensive option which offers limited advantages to APG. Within APG, use JFrog Artifactory for dependency scanning. Sonar is within APG the tool for static code scanning.
   * - ``Default branch name for new repositories``
     - main
     - Branch policies apply for the main branch. DRCP allows deployment to acceptance and production from the main branch.
   * - ``Disable creation of TFVC repositories``
     - On
     - Use git as version control system.
   * - ``Allow users to manage permissions for their created branches``
     - On
     - DevOps users are able to create feature branches and manage the permissions for these branches.
   * - ``Create PRs as draft by default``
     - Off
     - DevOps teams are responsible for their way of working.

Project, Repository Policies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :widths: 15 10 25
   :header-rows: 1

   * - Setting
     - Value
     - Rationale
   * - ``Commit author email validation``
     - ``*@apg.nl; *@apg-am.nl``
     - This setting checks that APG staff create the commits.
   * - ``File path validation``
     - Off
     - DevOps teams are responsible for the structure of their repositories.
   * - ``Case enforcement``
     - On
     - Avoid case-sensitivity conflicts by blocking pushes that change name casing on files, folders, branches, and tags.
   * - ``Reserved names``
     - On
     - Block pushes that introduce files, folders, or branch names that include platform reserved names or incompatible characters.
   * - ``Maximum path length``
     - 248
     - Longer path length can cause problems on Windows systems.
   * - ``Maximum file size``
     - Off
     - DevOps teams are responsible for the structure of their repositories. DRCP doesn't support Azure DevOps LFS.

Project, Branch Policies
~~~~~~~~~~~~~~~~~~~~~~~~

The following branch policies apply for ``main``, ``develop``, ``release``, and ``hotfix`` branches.

.. list-table::
   :widths: 15 10 25
   :header-rows: 1

   * - Setting
     - Value
     - Rationale
   * - ``Require a minimum number of reviewers``
     - On
     - According to the APG Development policy, an expert colleague reviews the developed or modified code.
   * - ``Minimum number of reviewers``
     - 1
     - According to the APG Development policy, an expert colleague reviews the developed or modified code.
   * - ``Allow requestors to approve their own changes``
     - Off
     - According to the APG Development policy, an expert colleague reviews the developed or modified code.
   * - ``Prohibit the most recent pusher from approving their own changes``
     - On
     - According to the APG Development policy, an expert colleague reviews the developed or modified code.
   * - ``Allow completion even if some reviewers vote to wait or reject``
     - Off
     - According to the APG Development policy, an expert colleague reviews the developed or modified code.
   * - ``When new changes are pushed:``
     - Reset all approval votes (doesn't reset votes to reject or wait)
     - According to the APG Development policy, an expert colleague reviews the developed or modified code.
   * - ``Check for linked work items``
     - Off
     - At the moment, no automatically synchronization between Jira and Azure DevOps is available. In the future DRCP and Development Support will provide a limited synchronization between Jira and Azure DevOps ``workitems``.
   * - ``Check for comment resolution``
     - Required
     - According to the APG Development policy, an expert colleague reviews the developed or modified code.
   * - ``Limit merge types``
     - Off
     - DevOps teams are responsible for their way of working.
   * - ``Build Validation``
     - DRCP Code Quality Check (required)
     - According to the APG Development policy, code should adhere to certain quality. DRCP defines a default pipeline that needs to succeed for a pull request to complete. DevOps teams must update this default pipeline to their needs. 
       See :doc:`Quick actions <../../Platform/DRDC-portal/Quick-actions>` on how to enable and :doc:`Build validation <Build-validation>` for more information.
   * - ``Status Checks``
     - No predefined status checks
     - DRCP doesn't support status checks.
   * - ``Automatically included reviewers``
     - The DevOps engineers group
     - According to the APG Development policy, an expert colleague reviews the developed or modified code. A member of the DevOps engineers group has to approve every pull request.
