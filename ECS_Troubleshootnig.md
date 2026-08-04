# Amazon ECS API Error Troubleshooting Guide (L1 Support)


## 1. Common ECS API Exceptions & Resolution SOPs

### `AccessDeniedException`
* **Cause**: The IAM user or role executing the call lacks required permissions [00:00:27].
* **Resolution**:
  1. Identify the missing permission/action (e.g., `ecs:CreateCluster`).
  2. Open the **AWS IAM Console** > **Users** / **Roles**.
  3. Attach the required IAM policy or action permissions to the identity [00:00:44].



### `ClientException`
* **Cause**: The API call references a non-existent or invalid resource (e.g., invalid task definition name) [00:01:23].
* **Resolution**: Verify that resource names and syntax in the CLI command, API request, or application code are exact and exist in the target AWS account/region [00:01:31].



### `ClusterNotFoundException`
* **Cause**: The target ECS cluster specified in the call does not exist [00:01:40].
* **Resolution**:
  1. List active clusters in the target region:
     ```bash
     aws ecs list-clusters --region <region>
     ```
  2. Verify spelling and regional placement of the cluster name in the API call [00:01:55].



### `InvalidParameterException`
* **Cause**: One or more parameters in the API payload are invalid or misspelled (e.g., invalid task definition version) [00:01:55].
* **Resolution**: Check the API specification and ensure all parameter keys and values are valid and correctly formatted [00:02:13].



### `ServerException`
* **Cause**: Internal server/service error on the AWS side [00:02:13].
* **Resolution**:
  1. Wait a few moments and attempt an exponential backoff retry [00:02:20].
  2. If the issue persists, escalate to L2 support or open an AWS Support ticket with request IDs and timestamps [00:02:29].



### `ServiceNotActiveException`
* **Cause**: Attempting to update or manage an ECS service that is inactive or deleted [00:02:35].
* **Resolution**:
  1. List active services in the cluster:
     ```bash
     aws ecs list-services --cluster <cluster-name>
     ```
  2. Verify active status via AWS CLI:
     ```bash
     aws ecs describe-services --cluster <cluster-name> --services <service-name>
     ```



### `PlatformTaskDefinitionIncompatibilityException`
* **Cause**: The specified AWS Fargate platform version does not support required features (e.g., mounting EFS volumes on Fargate version `1.3.0`) [00:03:07].
* **Resolution**: Check Fargate platform version capabilities and update the platform version in the service or run-task parameters [00:03:25].



### `PlatformUnknownException`
* **Cause**: Incorrect or malformed Fargate platform version string [00:03:25].
* **Resolution**: Ensure proper semantic versioning format (e.g., use `1.3.0` or `LATEST` instead of `1.3`) [00:03:42].



### `ServiceNotFoundException`
* **Cause**: The service name provided in the call does not exist in the specified cluster [00:03:42].
* **Resolution**: Run `aws ecs list-services --cluster <cluster-name>` to verify exact spelling and cluster association [00:03:53].



### `UnsupportedFeatureException`
* **Cause**: Attempting to launch a Fargate task or feature in an AWS region where it is not yet supported [00:03:53].
* **Resolution**: Verify regional feature availability on AWS documentation and switch to a supported region or launch type [00:04:08].



## 2. Application-Level HTTP Errors (500 / 503)

If the ECS API calls succeed, but users encounter **HTTP 500 (Internal Server Error)** or **HTTP 503 (Service Unavailable)** from applications running inside ECS tasks :

1. Locate the Amazon CloudWatch log group configured for the ECS task definition.
2. Inspect application logs in **Amazon CloudWatch Logs** to pinpoint application crash triggers or dependency failures .



# 🚀 AWS ECS Troubleshooting & L1/L2 Interview Guide

> A practical reference guide covering real-world **Amazon ECS (Elastic Container Service)** troubleshooting scenarios, useful **AWS CLI commands**, deployment issues, and interview-focused explanations for **DevOps / Cloud Engineers**.



# 📑 Table of Contents

- [1. Core ECS Troubleshooting Scenarios](#-1-core-ecs-troubleshooting-scenarios)
  - [Scenario 1: Task Instantly Stops with ExitCode 137 (OOM)](#scenario-1-task-instantly-stops-with-exitcode-137-oom)
  - [Scenario 2: Task Fails to Pull Image (CannotPullContainerError)](#scenario-2-task-fails-to-pull-image-cannotpullcontainererror)
  - [Scenario 3: Container Fails ELB Health Checks](#scenario-3-container-fails-elb-health-checks)
  - [Scenario 4: Pending Tasks Stuck Due to Resource Constraints](#scenario-4-pending-tasks-stuck-due-to-resource-constraints)
  - [Scenario 5: Application Crashes on Startup (ExitCode 1 or 127)](#scenario-5-application-crashes-on-startup-exitcode-1-or-127)
- [2. Deployment & Traffic Routing Scenarios](#-2-deployment--traffic-routing-scenarios)
  - [Scenario 6: Users Can't Access V2 App After Deployment](#scenario-6-users-cant-access-v2-app-after-deployment)
- [3. DNS TTL & Traffic Overriding Solutions](#-3-dns-ttl--traffic-overriding-solutions)
- [4. Quick Reference Summary Table](#-4-quick-reference-summary-table)



# 🔹 1. Core ECS Troubleshooting Scenarios



## Scenario 1: Task Instantly Stops with `ExitCode: 137` (OOM)

### 🎯 Symptom

The ECS task launches successfully but stops after only a few seconds.

### 🔍 Root Cause

The container exceeded its configured **hard memory limit**, causing the Linux kernel **OOM Killer** to terminate the process with **SIGKILL (Exit Code 137)**.

### 🛠️ CLI Diagnostics

### 1. Inspect stopped task status and exit code

```bash
aws ecs describe-tasks \
    --cluster <CLUSTER_NAME> \
    --tasks <TASK_ARN> \
    --query "tasks[*].containers[*].{Name:name, Status:lastStatus, ExitCode:exitCode, Reason:reason}"
```

### 2. Inspect memory limits configured in the Task Definition

```bash
aws ecs describe-task-definition \
    --task-definition <TASK_FAMILY> \
    --query "taskDefinition.{TaskMemory:memory, Containers:containerDefinitions[*].{Name:name, Memory:memory, Reservation:memoryReservation}}"
```



## Scenario 2: Task Fails to Pull Image (`CannotPullContainerError`)

### 🎯 Symptom

The task remains in **PENDING** state before transitioning to **STOPPED**.

### 🔍 Root Cause

Possible causes include:

- Missing permissions on the **Task Execution Role**
- Incorrect ECR image URI
- Missing VPC Endpoints for Amazon ECR
- Image tag does not exist

### 🛠️ CLI Diagnostics

### 1. Get the exact stop reason

```bash
aws ecs describe-tasks \
    --cluster <CLUSTER_NAME> \
    --tasks <STOPPED_TASK_ARN> \
    --query "tasks[*].stoppedReason"
```

### 2. Verify the Execution Role attached to the Task Definition

```bash
aws ecs describe-task-definition \
    --task-definition <TASK_FAMILY> \
    --query "taskDefinition.executionRoleArn"
```

### 3. Verify IAM policies attached to the Execution Role

```bash
aws iam list-attached-role-policies \
    --role-name ecsTaskExecutionRole
```



## Scenario 3: Container Fails ELB Health Checks

### 🎯 Symptom

Tasks start successfully, register with the ALB Target Group, repeatedly fail health checks, and are continuously replaced.

### 🔍 Root Cause

Possible reasons include:

- Application doesn't return **HTTP 200** on the configured health endpoint.
- Security Groups block traffic from the ALB.
- Application startup time exceeds the configured health check timeout.

### 🛠️ CLI Diagnostics

### 1. Check Target Group Health

```bash
aws elbv2 describe-target-health \
    --target-group-arn <TARGET_GROUP_ARN>
```

### 2. Connect to the running container

```bash
aws ecs execute-command \
    --cluster <CLUSTER_NAME> \
    --task <RUNNING_TASK_ID> \
    --container <CONTAINER_NAME> \
    --interactive \
    --command "/bin/sh"
```

Inside the container:

```bash
curl -iv http://localhost:8080/health
```



## Scenario 4: Pending Tasks Stuck Due to Resource Constraints

### 🎯 Symptom

Tasks remain in **PENDING** or **PROVISIONING** state.

### 🔍 Root Cause

#### EC2 Launch Type

No EC2 instance has sufficient available CPU or Memory.

#### Fargate Launch Type

AWS account has reached its Fargate task quota.

### 🛠️ CLI Diagnostics

### 1. Check ECS Service Events

```bash
aws ecs describe-services \
    --cluster <CLUSTER_NAME> \
    --services <SERVICE_NAME> \
    --query "services[*].events[0:5].message"
```

### 2. Check Remaining CPU & Memory

```bash
aws ecs describe-container-instances \
    --cluster <CLUSTER_NAME> \
    --container-instances $(aws ecs list-container-instances --cluster <CLUSTER_NAME> --query "containerInstanceArns[]" --output text) \
    --query "containerInstances[*].{InstanceId:ec2InstanceId, RemainingCPU:remainingResources[?name=='CPU'].integerValue | [0], RemainingMem:remainingResources[?name=='MEMORY'].integerValue | [0]}"
```



## Scenario 5: Application Crashes on Startup (`ExitCode: 1` or `127`)

### 🎯 Symptom

The task immediately stops after container startup.

### 🔍 Root Cause

#### Exit Code 1

Unhandled runtime exception inside the application.

#### Exit Code 127

Docker `ENTRYPOINT` or `CMD` references a binary that doesn't exist.

### 🛠️ CLI Diagnostics

### Retrieve CloudWatch Logs

```bash
aws logs get-log-events \
    --log-group-name /ecs/<TASK_FAMILY> \
    --log-stream-name ecs/<CONTAINER_NAME>/<TASK_ID> \
    --limit 20 \
    --query "events[*].message"
```



# 🔹 2. Deployment & Traffic Routing Scenarios



## Scenario 6: Users Can't Access V2 App After Deployment

### 🎯 Symptom

Version 2 is deployed successfully.

- ECS Tasks are healthy.
- ALB Target Group reports healthy targets.
- End users still cannot access the new version.

### 🔍 Possible Causes

### Security Group Misconfiguration

Application port changed but Security Group rules were not updated.



### CORS / API Contract Changes

The new backend isn't compatible with cached V1 frontend assets.



### Browser Asset Caching

Browsers still use old JavaScript bundles pointing to deprecated APIs.



### DNS TTL Caching

Resolvers or clients cached old IP addresses.

This usually applies when using:

- AWS Cloud Map
- Direct IP access

rather than an ALB.



# 🔹 3. DNS TTL & Traffic Overriding Solutions

When stale DNS caches cause routing issues during deployments, use one of the following approaches.



## 1. AWS Global Accelerator vs Amazon CloudFront

| Feature | AWS Global Accelerator | Amazon CloudFront |
|---- | ---- | ---- |
| Traffic Handling | Assigns two Static Anycast Public IPs | Global CDN Edge Network |
| DNS Caching Mitigation | Eliminates DNS issues because IPs never change | Uses low TTLs while proxying traffic |
| Best Use Case | TCP/UDP apps, clients caching IPs aggressively | HTTP/HTTPS websites, APIs, Static Assets |



## 2. DNS TTL Management

Before rolling deployments:

Lower Route53 or AWS Cloud Map TTL values to **5–15 seconds** to minimize stale DNS cache issues.



# 🔹 4. Quick Reference Summary Table

| Exit Code / Error | Meaning | Primary AWS CLI Command |
|----| ---- | ----|
| Exit Code 137 | Out Of Memory (OOM Killer) | `aws ecs describe-tasks` |
| Exit Code 1 / 127 | Application Crash / Missing Executable | `aws logs get-log-events` |
| CannotPullContainer | ECR IAM Failure / Missing Image | `aws ecs describe-tasks` |
| Target.Timeout | ALB Health Check Failure | `aws elbv2 describe-target-health` |
| Unable to place task | Cluster Resource Exhaustion | `aws ecs describe-services` |
| Stale IP Routing | DNS TTL / Resolver Cache Issue | `dig +trace <domain>` |



# 📌 Interview Takeaways

- **Exit Code 137** almost always indicates an **Out of Memory (OOM)** condition.
- **CannotPullContainerError** is commonly caused by IAM permission issues, missing images, or ECR connectivity problems.
- **ALB Health Check failures** are usually related to incorrect health endpoints, security groups, or application startup delays.
- **Pending tasks** often point to insufficient cluster resources or AWS service quota limitations.
- **Exit Code 127** usually indicates an invalid `ENTRYPOINT` or missing executable in the container image.
- **AWS Global Accelerator** helps eliminate DNS caching issues by providing static Anycast IP addresses.
- **Lowering DNS TTL** before deployments helps reduce stale DNS cache problems during traffic cutovers.

# AWS ECS CloudWatch Agent Sidecar – Common Issues & Troubleshooting

This document contains common issues encountered while configuring the **AWS CloudWatch Agent as a Sidecar Container** in **Amazon ECS**, along with their root causes and resolutions.

# Troubleshooting Summary

| Issue / Error | Root Cause | Fix / Solution |
|---------------|------------|----------------|
| **ResourceInitializationError: `openat /etc/passwd: no such file or directory`** | The shared volume was mounted on system directories (such as `/tmp`, `/var/log`, etc.), masking essential files inside the container filesystem. | Never mount shared volumes over Linux system directories. Mount the shared volume to an isolated directory such as **`/mnt/nginx_logs`** or another custom path. |
| **Sidecar Container exits immediately (Exit Code: 1)** | Invalid JSON supplied in `CW_CONFIG_CONTENT` or missing ECS mode configuration. | Validate the JSON. Use a single-line (minified) JSON string and ensure the following exists: `"agent": { "mode": "ecs" }`. |
| **CloudWatch Log Group (`/ecs/nginx-sidecar-logs`) is not created** | CloudWatch Agent creates log groups only after it detects log files containing actual log entries. Empty log files do not trigger log group creation. | Generate application traffic (for example, `curl http://<TASK_PUBLIC_IP>`) so Nginx writes access logs. The agent will then automatically create the log group and stream. |
| **AccessDeniedException in CloudWatch Agent logs** | CloudWatch IAM permissions were attached to the **Execution Role** instead of the **Task Role**. The agent runs using the Task Role. | Attach **CloudWatchAgentServerPolicy** (or equivalent CloudWatch Logs permissions) directly to the **ECS Task Role**, not the Execution Role. |

# Best Practices

- Never mount shared volumes over Linux system directories.
- Always use a dedicated directory for application logs.
- Validate `CW_CONFIG_CONTENT` JSON before deploying.
- Keep CloudWatch Agent configuration minified when passing through environment variables.
- Ensure `"mode": "ecs"` is configured for ECS deployments.
- Verify the ECS **Task Role** has CloudWatch permissions.
- Generate application traffic before expecting CloudWatch log groups to appear.
- Monitor the CloudWatch Agent container logs for faster troubleshooting.

## ALB vs ELB vs GLB Load Balancer

# AWS Load Balancers Interview Notes (ALB vs NLB vs GLB)

> **Interview One-Liner**
>
> - **ALB** → Intelligent Layer-7 load balancer for web applications.
> - **NLB** → High-performance Layer-4 load balancer for TCP/UDP traffic.
> - **GLB** → Service insertion load balancer used to route traffic through security appliances.


# Quick Comparison

| Feature | ALB | NLB | GLB |
|----------|-----|-----|------|
| **OSI Layer** | Layer 7 | Layer 4 | Layer 3 / Layer 4 |
| **Protocols** | HTTP, HTTPS, gRPC | TCP, UDP, TLS | IP (GENEVE) |
| **Primary Purpose** | Web/Application traffic | High-performance network traffic | Security appliance insertion |
| **Routing** | Content-based | Connection-based | Network routing |
| **Connection** | Terminates HTTP/HTTPS | TCP/UDP connection handling | Transparent pass-through |
| **Target Types** | EC2, IP, Lambda | EC2, IP, ALB | EC2/IP (Virtual Appliances) |
| **Static IP** | ❌ No | ✅ Yes | ❌ No |
| **WAF Support** | ✅ Yes | ❌ No | ❌ No |
| **SSL Termination** | ✅ Yes | ✅ Yes (TLS Listener) | ❌ No |


# Routing Algorithm

## Application Load Balancer (ALB)

**Algorithm:** Round Robin *(default)* or Least Outstanding Requests

- Routes HTTP requests one after another
- Can inspect HTTP headers, URL, Hostname, Cookies

Example:

```
Client Requests

Request1 → EC2-1
Request2 → EC2-2
Request3 → EC2-3
Request4 → EC2-1
```


## Network Load Balancer (NLB)

**Algorithm:** Flow Hash (5-Tuple Hash)

Uses:

- Source IP
- Source Port
- Destination IP
- Destination Port
- Protocol

This ensures the same TCP/UDP session always reaches the same backend.

```
Client
   │
TCP Connection
   │
Flow Hash
   │
EC2 Instance
```


## Gateway Load Balancer (GLB)

**Algorithm:** Routing Table + GENEVE Tunnel

Traffic is redirected through security appliances.

```
Internet
    │
Gateway Load Balancer
    │
Firewall / IDS / IPS
    │
Application
```


# When to Use

## ALB

Choose ALB when you need:

- Web applications
- REST APIs
- Microservices
- ECS/EKS Ingress
- Path-based routing
- Host-based routing
- HTTPS termination
- AWS Lambda targets

**Examples**

- `example.com/api`
- `example.com/images`
- `app.company.com`
- `admin.company.com`


## NLB

Choose NLB when you need:

- Millions of requests/sec
- Ultra-low latency
- TCP/UDP traffic
- Static IP
- Database traffic
- MQTT/IoT
- Gaming servers
- Streaming


## GLB

Choose GLB when you need:

- Centralized firewall
- IDS/IPS
- Deep Packet Inspection
- Traffic inspection
- Security appliances
- Network monitoring

Supports appliances such as:

- Palo Alto
- Fortinet
- Check Point


# Easy Interview Memory Trick

### ALB = **Application**

- Understands URLs
- Understands HTTP
- Smart Routing


### NLB = **Network**

- Understands TCP/UDP
- Fastest Load Balancer
- Static IP


### GLB = **Gateway**

- Security
- Firewall
- Traffic Inspection


# Interview Questions

### Q1. Which Load Balancer supports Path-based Routing?

✅ **ALB**


### Q2. Which Load Balancer supports TCP and UDP?

✅ **NLB**


### Q3. Which Load Balancer provides Static IP?

✅ **NLB**


### Q4. Which Load Balancer works with AWS WAF?

✅ **ALB**


### Q5. Which Load Balancer is used with Firewall appliances?

✅ **GLB**


### Q6. Which Load Balancer supports Lambda as a target?

✅ **ALB**


### Q7. Which Load Balancer is best for HTTP/HTTPS applications?

✅ **ALB**


### Q8. Which Load Balancer is best for Gaming or IoT?

✅ **NLB**


### Q9. Which Load Balancer performs Deep Packet Inspection?

✅ **GLB**


### Q10. Which Load Balancer uses the 5-Tuple Hash?

✅ **NLB**


# 30-Second Interview Answer

> **Application Load Balancer (ALB)** operates at Layer 7 and is designed for HTTP/HTTPS applications. It supports intelligent routing features such as path-based and host-based routing, SSL termination, AWS WAF integration, and Lambda targets.
>
> **Network Load Balancer (NLB)** operates at Layer 4 and is optimized for high-performance TCP, UDP, and TLS traffic. It provides ultra-low latency, static IP addresses, and uses a 5-tuple flow hash to keep a connection pinned to the same backend target.
>
> **Gateway Load Balancer (GLB)** operates at Layer 3/4 and is used for transparent traffic steering through virtual security appliances such as firewalls and IDS/IPS solutions using the GENEVE protocol. It is ideal for centralized network security architectures.


# Interview Cheat Sheet

| Requirement | Best Choice |
|-------------|-------------|
| Website | ✅ ALB |
| REST API | ✅ ALB |
| Microservices | ✅ ALB |
| ECS/EKS Ingress | ✅ ALB |
| Lambda Target | ✅ ALB |
| Static IP | ✅ NLB |
| TCP/UDP | ✅ NLB |
| Gaming | ✅ NLB |
| IoT | ✅ NLB |
| Database Connections | ✅ NLB |
| Firewall | ✅ GLB |
| IDS / IPS | ✅ GLB |
| Traffic Inspection | ✅ GLB |
| Security Appliances | ✅ GLB |