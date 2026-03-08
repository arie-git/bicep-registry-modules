Endpoint for DNS automation
===========================

Introduction
------------

| Use the API to create, change, and remove private DNS records in Azure. Automated Environment service connections in Azure DevOps can call this API.

.. note:: Authenticate to the API via the app registration `LLDC-API-AUTH (PRD)`. All automated DRCP Environment service connections in Azure DevOps are member of this app registration.

The API is available for these zones:

* ``azurebase.net``
* ``azurebase.local``
* ``appserviceenvironment.net``
* ``private.postgres.database.azure.com``
* ``privatelink.services.ai.azure.com``
* ``privatelink.openai.azure.com``
* ``privatelink.cognitiveservices.azure.com``

Endpoints details
-----------------

Please see this `page <https://{{apiurl}}/openapi/dns_v1.yml>`__ to learn about all API documentation details.

Authentication
--------------

The article :doc:`API Authentication <API-authentication>` describes the details on how to authenticate. Please use the ``scope`` parameters needed to authenticate from the table below.

.. list-table::
   :widths: 30 40
   :header-rows: 1

   * - Application registration
     - <apiApplicationID>
   * - LLDC-API-AUTH (PRD)
     - 04c388c9-e263-42a4-8d46-468af269db2c
