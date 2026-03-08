Incident remediation Notification Hubs
======================================

.. |AzureComponent| replace:: Notification Hubs
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-ntf-01
     - Disallow default Access policies.
     - Ensure to `configure the access policies with another name then the default <https://learn.microsoft.com/en-us/azure/notification-hubs/notification-hubs-push-notification-security>`__ to enforce more granular and secure access control.
