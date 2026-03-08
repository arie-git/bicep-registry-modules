Release management
==================

In this article, you'll learn what options to consider for release management in Azure DevOps.

Tagging
-------
The :doc:`DTAP flow article <Build-and-release-pipelines>` describes how you can design a release flow with a multi-staged pipeline.

Within the Azure DevOps Repository, using tags for release versioning is possible.
Create a tag for the specific release commit and put in a version. This can also be automatically done in a build stage.
Please follow `this link <https://learn.microsoft.com/en-us/azure/devops/repos/git/git-tags?view=azure-devops&tabs=browser>`__ for more information on tagging.

Release process
---------------
When using the multi-staged pipeline setup, a release process is available in Azure DevOps. Other tooling isn't required.
The pipeline with the :doc:`mandatory template <Required-pipeline-templates>` automatically creates a ServiceNow change and closes it with the pipeline status and information.
An exception for this process is when the release requires a CAB change. This requires a separate change in ServiceNow that's reviewed by the CAB.

Approval steps
--------------
Please see :doc:`this article <Build-and-release-pipelines>` on the approval steps that are part of the Azure DevOps configuration of DRCP.
