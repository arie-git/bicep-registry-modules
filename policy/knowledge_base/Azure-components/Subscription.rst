Subscription
============================

.. toctree::
   :maxdepth: 1
   :glob:

   Subscription/*

An Azure Subscription is a logical container used to provision related business or technical resources in Azure.
It holds the details of all your Azure components. When you create a component, you identify the Subscription it belongs to. It allows you to delegate access through role-based access-control mechanisms.

The DRCP platform delivers Subscriptions in the form of Environments. The relation between these two is 1-to-1. See :doc:`this page <../Getting-started/Application-System-and-Environments>` for more information about how to request an Environment, and thus an Azure Subscription.

.. note:: Microsoft faces higher demand for the 'West Europe' data center region than it can build out, due to regulatory constraints and limited external infrastructure (power supply) availability. The reduction in available hardware, directly impacts APG's ability to create High-Available components. After consultation with Business Owners and Privacy Officers, this means that within DRCP, Environments deploy in data center region 'Sweden Central'. Older Environments remain supported in data center region 'West Europe'. Please note, DRCP plans further alignment of the infrastructure in the future. See :doc:`release 24-2 04 <../Release-notes/Older-release-notes/Release-24-2-04>`.

.. warning:: DRCP restricts the allowed region for resources to the region of the Environment. In other words, Environments located in region 'Sweden Central' can't host resources in other regions, such as 'West Europe'.