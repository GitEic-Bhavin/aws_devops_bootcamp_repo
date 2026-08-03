## Q-1 What is the significance of cloudwatch alarm ?

- We can use CW Alarm to enable monitor metrics over a speicific time period and take action based on conditions you set.

- Action can include like Send SNS Notifications, Scale Up / Down ASG, Start, Stop, Terminate Instances.

## Q-2 What is the purpose of CW Events ?

- It help us to monitor any state changes in your aws resources like Start/Stop Instance, Create S3 Bucket .

- You can create event , Choose `Event from Cloud Trail` , filter for which svc like s3 you want to monitor , filter for what event in s3 you want to monitor.

- You can `Perform Actions` Where you can choose automated actions you want to perform based on that events.

## Q-3 How can you integrate CW with Lambda ?

- By `Choose CW Event` , You can make automated actions you want to perform.

- Like, If you monitor event happens like Uploaded object in S3, You can choose the actions on `Lambda` , Choose your lambda.

- So whenever someone will upload object in S3, This event will monitor by CW Event and it will trigger lambda.

## Q-4 What is CW Logs Insights, and Hoe does it help in logs analysis ?

- Its a tool for searching and analyzing logs data.

- It allows you to interactively search and analyze your log data.

- It support complex queries and provides visualizations to understand log patterns.

# SRE (Site Reliability Engineer) Interview Questions & Answers

This document tracks real-world SRE & DevOps interview questions along with practical answers and best practices.

## 1. How would you deploy an application to AWS?

### Answer:
The approach depends on whether the application is monolithic or containerized. A typical end-to-end deployment flow includes:

* **AWS Landing Zone:** Set up AWS Organizations, Landing Zone, and account structures for proper segregation of environments (e.g., Dev, QA, Prod).
* **VPC Setup:** Design custom VPCs across multiple Availability Zones (AZs) with public/private subnets, Internet Gateways, NAT Gateways, and Security Groups (avoiding default VPCs in production).
* **Compute Infrastructure:** 
  * Provision EC2 instances in private subnets for monolithic applications.
  * Define Security Groups to restrict inbound and outbound traffic.
* **Scalability & Load Balancing:**
  * Configure **Auto Scaling Groups (ASG)** to handle traffic spikes.
  * Attach an **Application Load Balancer (ALB)** to route incoming traffic.
* **DNS & Routing:** Route DNS queries using **Route 53** pointing to the Load Balancer DNS.
* **Database & Dependencies:** Provision Amazon **RDS** for relational database requirements and install requisite application runtime dependencies (e.g., Java runtime for JAR files).

## 2. What measures have you taken to secure your EKS clusters?

### Answer:
To ensure cluster security, several best practices should be implemented:

* **Managed Node Groups:** Utilize EKS Managed Node Groups so AWS handles worker node OS provisioning, kubelet updates, and AMI patching [00:07:19].
* **Disable SSH Direct Access:** Avoid opening port 22/SSH on worker nodes. Instead, use **AWS Systems Manager (SSM) Session Manager** for secure browser-based access [00:08:10].
* **IAM & RBAC Integration:** Avoid static credentials or standard service accounts for authentication; leverage Role-Based Access Control (**RBAC**) adhering to the principle of least privilege.
* **Private Cluster Endpoints:** Keep the EKS API server endpoint private to prevent public internet exposure [00:09:02].
* **Non-Root Application Execution:** Ensure containerized applications inside Kubernetes pods run as non-root users [00:09:18].
* **Audit Logging:** Enable AWS **CloudTrail** and EKS control plane audit logs for operational auditing [00:09:26].
* **Secrets Encryption:** Utilize **AWS KMS** (Key Management Service) for customer-managed key rotation and secrets encryption at rest [00:09:52].
* **Vulnerability Scanning:** Maintain active vulnerability scanning pipelines using security scanning platforms [00:10:12].

## 3. What is the toughest challenge that you have faced with EKS clusters?

### Answer:
* **EKS Cluster Upgrades:** While cluster upgrades sound straightforward on paper, they carry significant operational risk [00:11:04].
* **Key Steps to Mitigate Risk:**
  1. **Release Notes Analysis:** Carefully review AWS EKS release notes to identify breaking changes and deprecated API versions [00:11:16].
  2. **Developer Coordination:** Review application manifests with developer teams to update deprecated Kubernetes API versions before running the upgrade.
  3. **Staging Validation:** Perform full end-to-end upgrade testing in lower (Dev/QA) environments to validate application compatibility before initiating production upgrades [00:11:48].


## 4. What monitoring tools have you used? What components did you monitor?

### Answer:
* **Tooling:** **Prometheus** for metrics collection/scraping and **Grafana** for visualization and dashboarding [00:14:57].
* **Monitored Kubernetes Components:**
  * **Control Plane Components:** API Server, CoreDNS, and kube-scheduler metrics [00:15:22].
  * **Worker Node Metrics:** `kubelet` and `cAdvisor` for container-level usage statistics [00:15:29].
  * **Cluster State Metrics:** `kube-state-metrics` for tracking high-level deployment and pod health status [00:15:36].
  * **Host Infrastructure Metrics:** `Node Exporter` for monitoring OS-level CPU, Memory, Disk, and Network performance [00:15:44].
* **Grafana Visualizations:**
  * Application-level HTTP request rates (Requests Per Minute).
  * Error rate tracking dashboards (e.g., HTTP 500, 502, 504 status codes) [00:16:25].

## 5. WHat is use of NAT Gateway ?

- NAT allows instances in a pvt subetns to initial outbound traffic to the internet while preventing inbound traffic from reaching those instance.

## 6. What is diff between the VPC Peering and VPN connectoins ?

- VPC Peering allow to communicate between VPCs.

- VPN Connections , will establish secure communication between and On-Premises and Cloud.

## 7. How will you secure communication between the Instances ?

- `Security Group` - are `Stateful` at EC2 Level.
- `NACL` - are `StateLess` at Subnet Level and allow/block Traffic at Subnet Level.

## 8. How do you troubleshoot connectivity issues in a VPC ?

- I will Ensure that Proper Ports and Source is allowing in a Security Group. Traffic is allowed at a NACl or not. If SG is allowing but NACl is block then its issue.

- If Apps required Internet but I didn't routed IGW or NAT properly than i will ensure that is routed properly.

- Sometimes, Your apps calls to another vpc, so VPC Peering is done properly.

- If your apps deploy in a pub or pvt subnet. You are working from office network. That office network can blocking to reach out to your EC2. 

- So i will add those office network CIDRs into SG.

- I will use tool like `VPC Flow Logs` to capture and analyze network traffic.

