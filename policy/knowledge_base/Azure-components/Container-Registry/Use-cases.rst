Use cases Container Registry
============================

.. include:: ../../_static/include/component-usecasepage-header.txt

Azure Container Registry
------------------------
| Azure Container Registry (ACR) `allows <https://learn.microsoft.com/en-us/azure/container-registry/anonymous-pull-access>`__ you to build, store, and manage container images and artifacts in a private registry for all types of container deployments.

- Use Azure container registries with your existing container development and deployment pipelines.
- Use ACR Tasks to build container images in Azure on-demand, or automate builds triggered by source code updates, updates to a container's base image, or timers.

Use cases and follow-up
-----------------------
Available tiers
~~~~~~~~~~~~~~~
ACR offers pricing tiers which have their own specification and limitations. See the differences `here <https://learn.microsoft.com/en-us/azure/container-registry/container-registry-skus>`__.

.. note:: Keep in mind that the premium tier supports the use of private link, at moment of writing, to avoid exposure from the public Internet and use the registry privately. Learn here `how <https://learn.microsoft.com/en-us/azure/container-registry/container-registry-private-link>`__.

Encryption
~~~~~~~~~~
`All <https://learn.microsoft.com/en-us/azure/container-registry/container-registry-storage#encryption-at-rest>`_ container images and other artifacts in your registry encrypts at rest. Azure automatically encrypts an image before storing it, and decrypts it on-the-fly when you or your applications and services pull the image.

**Follow up:**
DRCP trusts Microsoft to manage the lifecycle of keys used for encryption. DRCP will revisit when a central vault solution comes available within APG to manage customer-managed keys.

Authentication
~~~~~~~~~~~~~~
DRCP supports the following scenario and prevents other `authentication <https://learn.microsoft.com/en-us/azure/container-registry/container-registry-authentication?tabs=azure-cli>`_ methods that doesn't work with Microsoft Entra ID and Azure RBAC, like local accounts and tokens.

.. list-table::
   :widths: 5 20 20
   :header-rows: 1

   * - Type
     - Example scenario
     - Method

   * - Headless/service identity
     - | Build and deployment pipelines where the user isn't directly involved.
     - | `Service principal <https://learn.microsoft.com/en-us/azure/container-registry/container-registry-authentication#service-principal>`_

Authorization
~~~~~~~~~~~~~
ACR supports a set of built-in Azure RBAC roles that provide different levels of permissions. Use Azure RBAC to assign specific permissions to users, service principals, or other identities that need to interact with a registry, for example to pull or push container images.

**Follow-up:**
DRCP provides DevOps teams the flexibility to manage and grant these roles but requires to follow the principle of least privilege. View all available roles and permissions click `here <https://learn.microsoft.com/en-us/azure/container-registry/container-registry-roles>`_.

DRCP offers a way to interact with ACR and creates the connection with Artifactory and AKS:

- An organization-level installation of the Artifactory extension is active in Azure DevOps and requires a service connection and access token from Artifactory. After it's installed, the Azure DevOps tasks and service connection are available for the Azure DevOps project to use and configure. At that moment DevOps teams are able to create a pipeline and push images to ACR.
- To make sure AKS can pull images from ACR, `both can integrate <https://learn.microsoft.com/en-us/azure/aks/cluster-container-registry-integration?tabs=azure-cli>`_ and uses the RBAC role AcrPull to the managed identity.

Artifactory integration
~~~~~~~~~~~~~~~~~~~~~~~
DevOps teams develop application code and base images, and they assemble them into an image with all dependencies and artifacts using Docker. A prior development process precedes this.

Once the image is ready for deployment, it's pushed to the ACR with the help of an Azure DevOps pipeline job. With the Artifactory Azure DevOps extension, DevOps teams can perform pull/push actions from Artifactory to ACR. From there, Azure Kubernetes Service (the container orchestrator) can pull and run the images.

To use Artifactory within a YAML pipeline, consider the following snippet as an example.:

.. code-block:: powershell

   task: JFrogDocker@1
     inputs:
     command: 'Pull'
     artifactoryConnection: 'JFrogArtifactory-Festina'
     imageName: 'jfrog-platform.office01.internalcorp.net:8443/festina-docker/apg/casehandler:0.3.0'

.. note:: Please note the required FQDN of the imageName reference. The build agents can't resolve shortnames as part of the APG domain and don't have integrated DNS for the internal network.

Life cycle
~~~~~~~~~~

Registry size
*************
Throughout the life of the registry, DevOps teams `should <https://learn.microsoft.com/en-us/azure/container-registry/container-registry-best-practices#manage-registry-size>`_ manage its size by periodically deleting unused content. It includes for instance the image size, webhooks, geo-replications and private endpoint connections.

Use the Azure command-line interface `command <https://learn.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest#az-acr-show>`_ to display the current consumption of storage and other resources in your registry.

Delete image data
*****************
To maintain the size of the registry, DevOps teams `should <https://learn.microsoft.com/en-us/azure/container-registry/container-registry-best-practices#manage-registry-size>`_ periodically delete stale image data. While some container images deployed into production may require longer-term storage, you can typically delete others quicker. You can delete images:

- By `tag <https://learn.microsoft.com/en-us/azure/container-registry/container-registry-delete#delete-by-tag>`_: Deletes an image, the tag, all unique layers referenced by the image, and all other tags associated with the image.
- By `manifest digest <https://learn.microsoft.com/en-us/azure/container-registry/container-registry-delete#delete-by-manifest-digest>`_: Deletes an image, all unique layers referenced by the image, and all tags associated with the image.
- By a `repository <https://learn.microsoft.com/en-us/azure/container-registry/container-registry-delete#delete-repository>`_: Deletes all images and all unique layers within the repository.

.. note:: ACR stops billing for storage that's removed, which saves costs. Please delete image data periodically.

Retention policy
****************
| DevOps teams are also able to configure a `retention policy <https://learn.microsoft.com/en-us/azure/container-registry/container-registry-retention-policy>`_ for untagged manifests (stored image manifests that don't have any associated tags). When you enable a retention policy, the registry automatically deletes untagged manifests after a certain (preconfigured) number of days. 
| This prevents the registry from filling up with artifacts that aren't needed and helps you save on storage costs.

Learn `how <https://learn.microsoft.com/en-us/azure/container-registry/container-registry-retention-policy?tabs=azure-cli>`_ to enable retention policy, you can specify days between 0 and 356.

.. note:: The retention policy for untagged manifests is a preview feature of premium container registries and may contain bugs.

.. note:: Be careful when you set a retention policy, since deleted image data is unrecoverable.

Soft delete
***********
DevOps teams are able to configure `soft delete policy <https://learn.microsoft.com/en-us/azure/container-registry/container-registry-soft-delete-policy>`_, which treats the deleted artifacts as soft deleted artifacts, configured with a retention period. Thereby you have the ability to list, filter, and restore the soft deleted artifacts. Upon completion of the retention period, soft deleted artifacts are auto purged.

The auto purge runs every 24 hours. The auto purge always considers the current value of retention days before permanently deleting the soft deleted artifacts.

Learn how to `enable <https://learn.microsoft.com/en-us/azure/container-registry/container-registry-soft-delete-policy>`_ and restore soft delete policy with command-line interface. On the same page you will find the corresponding Azure Portal actions.

.. note:: ACR doesn't support manually purging soft deleted artifacts.

.. note:: ACR doesn't allow enabling both the retention policy and the soft delete policy. See `retention policy for untagged manifests. <https://learn.microsoft.com/en-us/azure/container-registry/container-registry-retention-policy>`_.
