Environments
============

`Azure DevOps environments <https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops>`__ is a collection of resources that you can target with deployments from a pipeline. Environments provide the ability to track deployments that are occurring, provide a level of security, and assist in tracking the state of work items.
When you author a YAML pipeline and refer to an environment that doesn't exist, Azure Pipelines automatically creates the environment and assigns permissions.

Permissions
-----------
The principal ``{ADO Project Name} Build Service (connectdrcpapg1)`` under which the pipeline runs, has the ``Creator`` `user permission <https://learn.microsoft.com/en-us/azure/devops/pipelines/process/environments?view=azure-devops#user-permissions>`__ on the environments hub security.
For user permissions assigned to DRCP roles, see ``Azure DevOps project roles`` under :doc:`Roles and authorizations <../../Getting-started/Roles-and-authorizations>`.


Example
-------
An example of a YAML pipeline for creating, reading, and deleting an environment with matching environment.json:

**Managing ADO environment in CI/CD pipeline example**

.. code-block:: yaml

   trigger: none

   pool: '$(agentPool)'

   steps:
   - bash: |
       // Set default when calling 'az devops'
       az devops configure --defaults organization=$(System.TeamFoundationCollectionUri) project=$(System.TeamProject) --use-git-aliases true

       // Create an ADO environment.
       az devops invoke --area distributedTask --resource environments --route-parameters project=$(System.TeamProject) --in-file "environment.json" --http-method POST -o json

       // Get the ADO environment id.
       id=$(az devops invoke --area distributedTask --resource environments --route-parameters project=$(System.TeamProject) --query "value[?name=='DEV'].id" -o tsv)

       // Delete an ADO environment.
       az devops invoke --area distributedTask --resource environments --route-parameters project=$(System.TeamProject) environmentId=$id --http-method DELETE
     displayName: Managing an ADO environment
     env:
       AZURE_DEVOPS_EXT_PAT: $(System.AccessToken)

**Managing ADO environment.json example**

.. code-block:: javascript

   {
     "name": "DEV",
     "description": "My development environment"
   }
