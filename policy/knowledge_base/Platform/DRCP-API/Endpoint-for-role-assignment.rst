Endpoint for role assignment
============================

Introduction
------------

| Use the API to assign or remove Microsoft Entra ID roles from user-assigned managed identities and app registrations. Automated Environment service connections in Azure DevOps can call this API.
| This API doesn't directly assign the role, but instead makes the identity a member of a Microsoft Entra ID group which already has the role assigned.

.. note:: Authenticate to the API via the app registration `DRCP API Authentication`. All automated DRCP Environment service connections in Azure DevOps are member of this app registration.

| When assigning a role to a managed identity, please use the Azure DevOps service connection in the same Subscription as the managed identity.
| Or, when assigning a role to an app registration, use the Azure DevOps service connection which is the owner of the app registration.

.. note:: Assigning a role to the service principal of the Azure DevOps service connection isn't supported, since DRCP manages the roles of this service principal.

Endpoints details
-----------------

Please use this `page <https://{{apiurl}}/openapi/roles_1_0.yml>`__ to learn about all API documentation details.

.. note:: | The address of the API is ``https://drcp-aad-prd.azurebase.net``.

Authentication
--------------

The article :doc:`API Authentication <API-authentication>` describes the details on how to authenticate. Please use the ``scope`` parameters needed to authenticate from the table below.

.. list-table::
   :widths: 30 40
   :header-rows: 1

   * - Application registration
     - <apiApplicationID>
   * - DRCP API Authentication
     - 6c0dbbe2-abc5-47ed-863b-a53226b5309c
