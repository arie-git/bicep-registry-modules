Request external certificate
============================

.. contents::
   Contents:
   :local:
   :depth: 2

Introduction
------------
This page describes the process to follow in case a DevOps team wants to request an externally signed (by Digicert) SSL certificate to use with an Azure component.

.. note:: For requesting an **internal** signed SSL certificate, please follow the :doc:`Custom domain guide <../../Azure-components/App-Service/Custom-domain>`.

For more generic information about the differences between internal and external signed SSL certificates and the corporate APG policies, see the `APG Cyber Security Knowledge Hub <https://cloudapg.sharepoint.com/sites/TeamAPG-SecurityFirst/SitePages/Inf.aspx>`__.


Prerequisites
-------------
Regardless of the Azure component type involved, the following mandatory prerequisites apply:

- Allowed external domain: ``azurebase.net``.
- Private key must be exportable.
- Generate a ``.csr`` file that contains the actual certificate request.

Actions
-------

1. Generate a ``.csr`` certificate request file. If you don't know how to do this, follow  Step 1 of the documentation on the :doc:`Custom domain <../../Azure-components/App-Service/Custom-domain>` page.
2. Go to the `Infrastructure Catalog <https://apgprd.service-now.com/now/nav/ui/classic/params/target/catalog_home.do%3Fsysparm_catalog%3D0a334d003734ee003486f01643990e3b%26sysparm_catalog_view%3Dcatalog_infrastructure_catalog>`__ > `Security Services <https://apgprd.service-now.com/now/nav/ui/classic/params/target/com.glideapp.servicecatalog_category_view.do%3Fv%3D1%26sysparm_parent%3D8b450b7d4fd9a200eec9cda28110c758%26sysparm_catalog%3D0a334d003734ee003486f01643990e3b%26sysparm_catalog_view%3Dcatalog_infrastructure_catalog>`__ > **APG PKI External Certificate** request form in ServiceNow. If you don't see this form, request access via IAM and follow `this instruction <https://cloudapg.sharepoint.com/sites/TeamAPG-SecurityFirst/SitePages/How-to-request-an-internal,-external-or-government-certificates.aspx?web=1>`__.
3. Use the following information for the request:

.. list-table::
   :widths: 10 25
   :header-rows: 1

   * - Request field
     - Value
   * - Requested for
     - When the certificate is ready, this person gets a mail from ServiceNow with the resulting .cer-file
   * - Description
     - Enter a description for the certificate.
   * - Name
     - ``APG``
   * - Central phone number
     - Enter the central phone number of APG.
   * - Subject alternate names
     - The certificate DNS name, for instance ``example.azurebase.net``
   * - Common name
     - The CN of the certificate, for instance ``example.azurebase.net``
   * - Organizational unit
     - ``ICT``
   * - Organization
     - ``APG Groep N.V.``
   * - State/province
     - ``Limburg``
   * - City/locality
     - ``Heerlen``
   * - Country
     - ``NL``

After the request completes (this is a manual action executed by SIS), you receive a certificate ``.cer`` file. You can use this file to complete the certificate request and attach to your application.