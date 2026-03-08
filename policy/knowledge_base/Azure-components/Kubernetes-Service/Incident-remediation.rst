Incident remediation Kubernetes Service
=======================================

.. |AzureComponent| replace:: Kubernetes Service
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-aks-01
     - Ensure TLS routing on the ingress controller.
     - The inbound connections need to be verifiable and trusted. To ensure this, the inbound connections need to use a secure protocol.

   * - drcp-aks-02
     - Ensure that network endpoints are private.
     - Ensure to `disable public access <https://learn.microsoft.com/en-us/azure/aks/private-clusters?tabs=azure-portal>`__ (properties ``enableNodePublicIP`` and ``enablePrivateCluster``) and let the DRCP policies remediate the `Private DNS zone configuration <https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration>`__ on AKS private endpoints.

   * - drcp-aks-03
     - Ensure that authorization and authentication use Microsoft Entra ID.
     - Ensure to `enable Microsoft Entra ID authentication <https://learn.microsoft.com/en-us/azure/aks/enable-authentication-microsoft-entra-id>`__.

   * - drcp-aks-04
     - Ensure that roles, which can manage the AKS Cluster, are containing users or groups within the TAP-usages.
     - Group membership follow the IAM process including for membership. Adding individual user assignments break this process and are therefor forbidden for TAP.

   * - drcp-aks-05
     - Don't permit containers to run with the hostPID flag set to true.
     - `Disable the 'hostPID' flag <https://techcommunity.microsoft.com/t5/fasttrack-for-azure/security-considerations-for-azure-kubernetes-service/ba-p/2883927>`__.

   * - drcp-aks-06
     - Deny privileged container admission to AKS.
     - `Disable the 'privileged' flag <https://techcommunity.microsoft.com/t5/fasttrack-for-azure/security-considerations-for-azure-kubernetes-service/ba-p/2883927>`__.

   * - drcp-aks-07
     - Don't permit containers to run with the hostNetwork flag set to true.
     - `Disable the 'hostNetwork' flag <https://techcommunity.microsoft.com/t5/fasttrack-for-azure/security-considerations-for-azure-kubernetes-service/ba-p/2883927>`__.

   * - drcp-aks-08
     - Don't allow SYS_ADMIN capabilities.
     - Ensure to remove the ``SYS_ADMIN`` `capability <https://man7.org/linux/man-pages/man7/capabilities.7.html>`__ from the containers.

   * - drcp-aks-09
     - Disable the admission of containers with the NET_RAW capability (Manual).
     - Ensure to remove the ``NEW_RAW`` `capability <https://man7.org/linux/man-pages/man7/capabilities.7.html>`__ from the containers.

   * - drcp-aks-10
     - Disable the admission of containers with allowPrivilegeEscalation.
     - Ensure to `remove any 'allowPrivilegeEscalation' definitions <https://learn.microsoft.com/en-us/azure/aks/developer-best-practices-pod-security#secure-pod-access-to-resources>`__ from the containers.

   * - drcp-aks-11
     - Enable Azure Policy Extension on the cluster.
     - Ensure to `enable the Azure Policy Extension <https://learn.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes>`__ on the AKS cluster (configure property ``addOnProfiles.azurePolicy.enabled`` to ``true``).

   * - drcp-aks-12
     - Ensure that clusters are running a supported version.
     - Ensure to stay up to date with `supported Kubernetes versions in Azure Kubernetes Service <https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli>`__.

   * - drcp-aks-13
     - Ensure that node-pools are appropriately updated.
     - AKS uses node-pools. These are running on images that Microsoft maintains and controls. `Ensure to update the images periodically <https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster>`__.

   * - drcp-aks-14
     - Ensure that all containers have a security context set.
     - A `security context <https://learn.microsoft.com/en-us/azure/aks/developer-best-practices-pod-security>`__ defines privilege and access control settings for a Pod or Container. By enforcing the settings, developers need to reduce the amount of privileges a container can escalate to.

   * - drcp-aks-15
     - Ensure that the default namespace is empty.
     - Kubernetes provides a default namespace. Place resources in a Kubernetes cluster in pre-planned namespaces, to allow for security controls to take effect and to make it easier to manage resources.

   * - drcp-aks-16
     - Disable Command Invoke on Azure Kubernetes Service clusters.
     - Ensure to `disable the 'Invoke' command <https://learn.microsoft.com/en-us/azure/aks/access-private-cluster?tabs=azure-cli>`__ (configure property ``apiServerAccessProfile.disableRunCommand`` to ``true``).

   * - drcp-aks-17
     - Ensure nodes are in a dedicated subnet.
     - Ensure to place the nodes in a dedicated subnet.

   * - drcp-aks-18
     - Use the Microsoft Defender for Cloud built-in threat detection capability and enable Microsoft Defender for your Azure Kubernetes Service.
     - Ensure to enable `Defender for Containers <https://docs.microsoft.com/azure/defender-for-cloud/defender-for-containers-introduction?tabs=defender-for-container-arch-aks>`__.

   * - drcp-aks-19
     - Enable Diagnostic Settings for AKS.
     - Ensure to store the following logs: ``kube-audit``, ``kube-audit-admin``, ``kube-apiserver``, ``kube-controller-manager`` and ``kube-scheduler``.

   * - drcp-aks-20
     - Ensure secrets are periodically updated in the cluster.
     - Ensure to `periodically update secrets <https://learn.microsoft.com/en-us/azure/aks/update-credentials>`__ in the cluster.

   * - drcp-aks-21
     - Install an overlay service to encrypt the data in-transit.
     - AKS containers can communicate inside the cluster and data between nodes will be send over http/80. Traffic encryption helps to keep the cluster secure. Containers need to communicate inside the cluster via pre-determined paths. Use the AKS mesh to control the network communication.
