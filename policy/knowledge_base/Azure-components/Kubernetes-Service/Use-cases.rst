Use cases Kubernetes Service
============================

.. include:: ../../_static/include/component-usecasepage-header.txt

.. warning:: Limited :doc:`Azure Availability Zones support <../../Platform/Azure-availability-zones-support>` applies.

Use cases and follow-up
-----------------------

********
Versions
********

Kubernetes version
^^^^^^^^^^^^^^^^^^^
| DRCP LCM supports the last two GA versions (N & N-1). For example: 1.30 & 1.29 (N & N-1). See also DRCP control drcp-aks-12: :doc:`Security baseline Kubernetes Service <Security-Baseline>`.

| Recommended use for the last two GA versions:

- Latest (N): DEV
- Stable (N-1): TST, ACC, PRD

*************
Security
*************

Capacities
^^^^^^^^^^^
| By default, Docker containers per default use "allowPrivilegeEscalation" to gain capabilities via cap-add.
| Within APG this needs to be "false" in the Security Context of a container.
| To run a container the added capabilities need to be explicitly granted via the security context.

- runAsUser - the User IDs (UID) can have `special meanings <http://www.linfo.org/uid.html>`__ on a system. 1000 is the first non-privileged userID within the Ubuntu installment.
- runAsGroup - field specifies the primary group ID of 3000 for all processes within any containers of the Pod. If the field isn't configured, the primary group ID of the containers will be root(0).
- runAsFs - The fsGroup setting defines a group. Kubernetes  will use this group to change the permissions of all files in volumes during mounting by a pod.

| A example securityContext for containers:

.. code-block:: powershell

  apiVersion: v1
  kind: Pod
  metadata:
    name: security-context-demo
  spec:
    securityContext:
      runAsUser: 1000
      runAsGroup: 3000
      fsGroup: 2000
    containers:
      - name: security-context-demo
        image: mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            add: ["NET_ADMIN", "SYS_TIME"]

| `Read here what security capabilities are <https://unofficial-kubernetes.readthedocs.io/en/latest/concepts/policy/container-capabilities/>`__.
| `Read here on how to add security capabilities to a container <https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-capabilities-for-a-container>`__.
| `Read here on the security best practices for containers <https://learn.microsoft.com/en-gb/azure/aks/developer-best-practices-pod-security>`__.


Azure Keyvault integration
^^^^^^^^^^^^^^^^^^^^^^^^^^^

| AKS requires an extension to work with secrets maintained in the keyvault.
| This allows the AKS Cluster to manage (roll secrets) and mount the Keyvault as a local storage and use these during runtime.

| The current version of Azure Key Vault Provider for Secret Store CSI Driver has a downside that it uses the workload-identity (the AKS Cluster) to connect and retrieve secrets.
| This means that appropriate marking of Secrets and using the AKS native binding to certain pods has a preference. This to avoid that one pod can retrieve all cluster secrets via the CSI Driver.

| This will change in the future with the preview of Microsoft Entra ID pod identity.

| `Read here on how to handle secrets <https://kubernetes.io/docs/concepts/configuration/secret/>`__.
| `Read here on how to use the Azure Key Vault Provider for Secrets Store CSI Driver <https://learn.microsoft.com/en-gb/azure/aks/csi-secrets-store-driver>`__.

*******************
DNS
*******************

Kubernetes API
^^^^^^^^^^^^^^^
| DNS name prefix to use with the hosted Kubernetes API server FQDN.
| You will use needs to be to connect to the Kubernetes API when managing containers after creating the cluster.

| During the creation of the cluster, the following Azure Resource IDs are available:

| Location West Europe
| ``/subscriptions/44fc7c46-cf47-4a29-aaa4-3e30f9e4e14b/resourceGroups/H01-P1-Infrastructure-AzureDNS/providers/Microsoft.Network/privateDnsZones/privatelink.westeurope.azmk8s.io``

| Location Sweden Central
| ``/subscriptions/44fc7c46-cf47-4a29-aaa4-3e30f9e4e14b/resourceGroups/h01-p1-infrastructure-azuredns/providers/Microsoft.Network/privateDnsZones/privatelink.swedencentral.azmk8s.io``

Ingress Controllers (such as Nginx)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| The Ingress is a Kubernetes resource that lets you configure an load balancer for applications running on Kubernetes, represented by one or more Services in Azure Kubernetes Service.
| Such a load balancer is necessary to deliver those applications to clients outside of the Kubernetes cluster.

| During the creation of the ingress controller, the following Azure Resource ID is available:

| ``/subscriptions/44fc7c46-cf47-4a29-aaa4-3e30f9e4e14b/resourceGroups/H01-P1-Infrastructure-AzureDNS/providers/Microsoft.Network/privateDnsZones/azurebase.local``

*************
Cryptographic
*************

Developer laptop lost
^^^^^^^^^^^^^^^^^^^^^
| Azure Kubernetes uses Microsoft Entra ID authentication and creates a temporal certificate to authenticate to the servers.
| It's needed with the loss of a laptop to retract all outstanding connections by manually rolling the authentication certificates.

| This means the cluster may be unresponsive for up to 30 minutes and afterward developers need to re-authenticate to avoid the following error:
| *Unable to connect to the server: x509: certificate signed by unknown authority (possibly because of "crypto/rsa: verification error" while trying to verify candidate authority certificate "ca"*

| `Read here how to configure key rotation <https://learn.microsoft.com/en-us/azure/aks/certificate-rotation>`__.

Rotating Secrets
^^^^^^^^^^^^^^^^
| Rotating keys is a best practice and an industry standard for cryptographic management.
| Azure Kubernetes generates and uses certificates, Certificate Authorities, and Service Accounts to maintain and executed the service.

| These fall into the category of secrets and are subject to the IRM Standards.
| While Microsoft updates the secrets during upgrades the system needs periodic verification.

| `Read here how to configure key rotation <https://learn.microsoft.com/en-us/azure/aks/certificate-rotation>`__.

Updating Azure Kubernetes Service
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| Azure Kubernetes Service isn't an always-green-services as you may expect from Azure and the end-of-life is one year from GA.
| This means you need to have an active process to upgrade the AKS Clusters (with notice of possible breaking changes).

| The recommendation is to use auto upgrade and retrieve the latest versions on Dev to ensure that upcoming changes won't break when applied to Prod.

| `Read here on how the versions works <https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli#kubernetes-versions>`__.
| `Read here on how the auto upgrade works <https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster>`__.

Updating Azure Kubernetes Nodes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| Azure Kubernetes Service runs on images curated by Microsoft and aren't automatically provisioned to the AKS of the customer.
| To ensure the latest base image an upgrade needs to be execute with the unfortunate side-effect that images aren't released on a predetermined rhythm.

| `Read here on how to upgrade node-pools <https://learn.microsoft.com/en-us/azure/aks/node-image-upgrade>`__.

| Microsoft is developing a preview feature to automated needs to be effort going forward.
| `Read here on the preview feature <https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-node-image>`__.

************
Availability
************

Availability zones
^^^^^^^^^^^^^^^^^^
| Azure Kubernetes Service uses node-pools with compute resources to execute the services.
| The individual compute resources are non HA/DR and for production loads they should use Availability Zones.

| Availability zones are a high-availability offering that protects your applications and data from data center failures.
| Zones are unique physical locations within an Azure region. Each zone includes one or more data centers equipped with independent power, cooling, and networking.

| `Read here on the how to use availability zones <https://learn.microsoft.com/en-us/azure/aks/availability-zones>`__.

Pod Disruption Budget
^^^^^^^^^^^^^^^^^^^^^^
| Within AKS disruptions to an application will happen, even during normal use by actions such as:

- Draining a node for repair or upgrade.
- Draining a node from a cluster to scale the cluster down.
- Removing a pod from a node to permit something else to fit on that node.

| DevOps teams need to set pod-disrubtion budgets (PDBs) to make a high-avaible application.

| `Read here on Pod Disruption Budget <https://kubernetes.io/docs/concepts/workloads/pods/disruptions/>`__.

Backup
^^^^^^
| Azure backup isn't on-boarded as part of Landing zone 3. When you need it please raise the need via the BU-CCC.
| Although needs to be means containers and AKS have no backup facilities - it follows the mantra of stateless AKS.
| To managed state outside the cluster, the best way is to mount Storage accounts onto containers. These high available and don't make the cluster stateful.

| `Read here on mounting storage accounts to containers <https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision?tabs=mount-nfs%2Csecret>`__.

*******
Storage
*******

Azure Disk
^^^^^^^^^^
| AKS is managing resources including compute and storage resources which are Virtual Machines and Azure Disks in essence.
| Creation of Azure Disk isn't allowed, because IAAS isn't supported. See also DRCP control drcp-sub-14: :doc:`Security baseline Subscription <../Subscription/Subscription-Baseline>`.
| This control has no impact on the AKS resource (disk creation by AKS resource) and has an exemption on Microsoft level (beyond the control of DRCP).

*****************************
Managed Prometheus Monitoring
*****************************

Managed Prometheus
^^^^^^^^^^^^^^^^^^
| Use Managed Prometheus to observe and analyze Kubernetes Service clusters using a wide range of builtin and custom metrics.
| Deploy a Managed Prometheus by deploying a Azure Monitor Workspace, Data Collection Rule, Data Collection Endpoint, Data Collection Rule association and Node Recording Rules. 

| `Read here on how to deploying Managed Prometheus on your cluster <https://learn.microsoft.com/en-us/azure/azure-monitor/metrics/prometheus-metrics-overview>`__.