Karpenter
---

**Without Cluster AutoScaler**

  - EKS cluster has 2 worker nodes

  - each node has limited CPU and RAM

  - application suddenly needs more pods

  - 3 New pods requires `2 vcpu and 1 GB Ram`.

  - But existing nodegroup and node size is reached and exhast its resources.

  - So, Pods will never scheduled to any of worker nodes and will stay in pending state.


**With Cluster AutoScaler**

- Cluster AutoScaler watches `Pending state` Pods.

- CA will check nodegroup and node size defined in the nodegroup.

- Increase Worker Node with same size in nodegroup.

- `This 3 pods will scheduled in this new worker node`.

**Problem**

  - This 3 pods requires **2 vcpu and 1 GB RAM**.
  - But Node Size is **4 vcpu and 2 GB RAM**.

  - So **2 vcpu and 1 GB RAM** is a west of resources which will cause to higher cost.

  - You are paying Higher cost for which you didn't used and didn't requires any more.

**With Karpenter**

- Karpenter watches **Unscheduled pods / Pending Pods directly**.

- Analyze exact CPU/RAM requirement for only those **Unscheduled Pods**.

- Launches best suitable EC2 instance dynamically

**Benifits**

  1. No Predefined NodeGroups requires
  2. Faster Provisioning
    Cluster AutoScaler - Go to ASG - Launch Node - Register with kubernetes API EKS.
    - This takes 3-5 minutes.

    - karpenter makes directly API call to AWS EC2 - Provision Nodes - Register with EKS Cluster directly.

    - karpenter takes only 30-60 seconds only.

  3. Better cost optimizations.

  4. Active consolidations and deprovisioning.

  - It will deprovisions nodes while no pods are working or no pods available on that nodes.

[karpenter docs]("https://karpenter.sh/docs/)

