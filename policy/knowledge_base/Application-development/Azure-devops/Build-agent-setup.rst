Build agent setup
=================

.. contents::
   Contents:
   :local:
   :depth: 2

Introduction
^^^^^^^^^^^^

| Performing actions in Azure using a pipeline requires an ADO build agent pool. Since most Azure components in APG are solely accessible through private endpoints, build agents need to run within the APG network.
| To meet this need and to enable the use of up-to-date deployment agents, DRCP provides centralized agent pools for the DevOps teams:

.. list-table::
   :widths: 10 40 20 50
   :header-rows: 1

   * - Definition
     - Purpose
     - Name
     - Remark
   * - Preview
     - For testing the newest version of the APG build agent image.
     - CPP-Ubuntu2204-Preview
     - This allows teams to test changes in the most recent image version (built by APG) before that image version moves to the ``Latest`` pools.
   * - Latest
     - For running all pipelines and **should be the default** for all DevOps teams.
     - | CPP-Ubuntu2404-Latest-A
       | CPP-Ubuntu2404-Latest-B
     - Please spread your workloads across pools with suffix A and B to loadbalance agent occupation.
   * - Previous
     - This is a fallback for the ``Latest`` pools (``Latest`` minus 1 version)
     - CPP-Ubuntu2404-Preview
     - This pool should be solely used when problems occur with the ``Latest`` agent pools (A and B).

.. note:: Find detailed information about the agent pools on the `LLDC Self-Hosted agent versions confluence space <https://confluence.office01.internalcorp.net:8453/spaces/LLDCSHAS/overview>`__.

Remarks:

* The ``latest`` GitHub tag on the source images (not to confuse with ``Latest`` definition of the pool) published in the `runner-images GitHub repository <https://github.com/actions/runner-images?tab=readme-ov-file>`__ define the actual OS version used.
* When a DevOps team has a clear need for Windows-based agents, DRCP can provide them through an exception.
* Mac-OS based agents aren't available.


Lifecycle of the build agent pools
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| Since deployment tools and operating systems get regular updates, every week a new APG build agent image release becomes available. This means the Preview agent pool will be max 1 week old. The Latest agent pool will be max 2 weeks old and the Previous agent pool will be max 3 weeks old.
| Once a week, Azure LLDC updates the agent pools with the applicable build agent image version.

Contents of the build agent image
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| Azure LLDC uses the Microsoft provided `runner-images <https://github.com/actions/runner-images>`__ as a base for the build agent image. These images contain most of the required build- and deployment tools for Azure Application systems. Microsoft determines the lifecycle of the tools and OS.
| When a required piece of software is missing, DevOps teams have the possibility to install it in their pipeline run using Artifactory.

.. note:: Find detailed information about the automated Azure LLDC build agent image `here <https://confluence.office01.internalcorp.net:8453/spaces/LLDCSHAS/overview>`__.

.. note:: To file a bug report with Microsoft, or request tools to add/update in the image definition, file an issue with Microsoft using the appropriate `template <https://github.com/actions/runner-images/issues/new/choose>`__. Make sure to check the `issue list <https://github.com/actions/runner-images/issues>`__ first to avoid duplicate requests.

Build agent one-time-use
^^^^^^^^^^^^^^^^^^^^^^^^
As a security best practice the build agent gets teared down and re-imaged after every pipeline job. This means every job runs on a clean image and data or installed extra software isn't cached or contained between jobs. This, to avoid data leakage or the reuse of vulnerable code.

Microsoft hosted agents
^^^^^^^^^^^^^^^^^^^^^^^
To align with APGs Azure DevOps Global Design, DRCP removed the Microsoft provided agent pool ``Azure Pipelines``, to reduce security risks. These agents run outside the APG network and aren't in APG control.

Custom agent pools
^^^^^^^^^^^^^^^^^^
At this moment, DRCP prohibits DevOps teams from adding agent pools (such as Self-hosted, VMSS, or Managed DevOps Pool) themselves.