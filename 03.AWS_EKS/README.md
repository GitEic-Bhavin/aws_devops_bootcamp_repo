# Kubernetes Architecture: Complete Guide

## Table of Contents
1. [Overview](#overview)
2. [Master Node (Control Plane)](#master-node-control-plane)
3. [Worker Nodes](#worker-nodes)
4. [User Request Flow (ALB to Pods)](#user-request-flow-alb-to-pods)
5. [Key Concepts](#key-concepts)
6. [What Makes Kubernetes Powerful](#what-makes-kubernetes-powerful)
7. [Quick Reference](#quick-reference)

---

## Overview

Kubernetes is a container orchestration platform that manages containerized applications across a cluster of machines. It consists of two main types of nodes:

- **Master Node (Control Plane)**: Makes decisions about the cluster
- **Worker Nodes**: Run your actual application containers

Think of Kubernetes as an automated system administrator that:
- Deploys applications
- Manages networking
- Handles scaling and updates
- Ensures applications stay healthy
- Restarts failed containers automatically

---

## Master Node (Control Plane)

The master node is the brain of Kubernetes. It coordinates all activities in the cluster and manages the state of all worker nodes and pods.

### 1. API Server

**What it does:**
- Central hub of Kubernetes
- Every request (from users, CLI tools, internal components) goes through the API Server first
- Validates requests and checks permissions
- Processes requests and stores the desired state
- Provides REST API endpoints for cluster management

**How it works:**
- When you run `kubectl apply -f deployment.yaml`, the API Server receives this request
- It validates the YAML syntax and your permissions
- Stores the desired state in etcd
- Notifies other components (Scheduler, Controller Manager) about the change

**Example workflow:**
```
You: kubectl create pod nginx
  ↓
API Server: "Create a pod named 'nginx' with image 'nginx:latest'"
  ↓
Stored in etcd database
  ↓
Scheduler and Controller Manager notified
```

---

### 2. Scheduler

**What it does:**
- Watches for new Pods that haven't been assigned to any node yet
- Evaluates available worker nodes
- Decides which worker node is best for each Pod
- Assigns the Pod to the selected node

**Scheduling criteria:**
- Available CPU and memory
- Node affinity (prefer certain nodes)
- Pod requirements and constraints
- Taints and tolerations
- Resource requests and limits

**Example:**
```
Scheduler sees: "Need to create Pod-A with 2GB RAM"

Checks available nodes:
  - Node-1: 512MB free (not enough)
  - Node-2: 3GB free (perfect!)
  - Node-3: 100MB free (not enough)

Decision: Assign Pod-A to Node-2
```

---

### 3. Controller Manager

**What it does:**
- Continuously monitors cluster state
- Compares desired state (what you want) with actual state (what's running)
- Takes corrective actions to match desired state
- Runs multiple controllers for different resources

**Key controllers:**
- **ReplicaSet Controller**: Ensures correct number of Pod replicas
- **Deployment Controller**: Manages deployments and rolling updates
- **StatefulSet Controller**: Manages stateful applications
- **Job Controller**: Manages one-time tasks
- **Service Controller**: Creates/manages load balancers

**Example:**
```
You declare: "I want 3 replicas of my app"

Current state: Only 2 Pods are running (one crashed)

Controller Manager action: "Create 1 new Pod to match desired state"

Now: 3 Pods running ✓
```

---

### 4. etcd (Database)

**What it does:**
- Persistent key-value store
- Stores ALL cluster data
- Source of truth for cluster state
- Uses Raft consensus for consistency

**What it stores:**
- Pod configurations and status
- Service definitions
- Secrets and ConfigMaps
- Node information
- Persistent Volume claims
- All resource definitions

**Why it's important:**
- If the master node crashes and restarts, etcd remembers everything
- Without etcd, you'd lose all cluster configuration

**Data example:**
```json
{
  "deployments": {
    "default": {
      "myapp": {
        "replicas": 3,
        "image": "myapp:v1.0",
        "status": "running"
      }
    }
  },
  "services": {
    "default": {
      "myapp-service": {
        "type": "LoadBalancer",
        "port": 80
      }
    }
  }
}
```

![alt text](k8s-arch.png)


## Worker Nodes

Worker nodes are where your actual application containers run. Each worker node has several components that manage pods and networking.

### 1. Kubelet (Node Agent)

**What it does:**
- Runs on every worker node
- Communicates with the Master Node (API Server)
- Creates, updates, and deletes Pods on the node
- Ensures containers are running and healthy
- Reports node status to the master

**Responsibilities:**
- Receives Pod specifications from the master
- Pulls container images from registries
- Instructs the container runtime to start containers
- Monitors Pod and container health
- Restarts failed containers
- Reports node metrics (CPU, memory, disk)
- Sends heartbeats to the master

**Workflow:**
```
Master: "Hey Node-1, please create Pod-A"
  ↓
Kubelet: "Received. Creating Pod-A..."
  ↓
Kubelet: "Pod-A is now running. Health check: OK"
  ↓
Kubelet: "Sending heartbeat and status to master"
```

**Health checks:**
- Readiness probe: Is the app ready to receive traffic?
- Liveness probe: Is the app still alive, or should we restart it?
- Startup probe: Has the app finished starting up?

---

### 2. kube-proxy (Network Component)

**What it does:**
- Manages network rules on every worker node
- Routes traffic to Pods
- Load balances requests across multiple Pod replicas
- Implements Services networking

**How it works:**
- Watches the API Server for Service and Endpoint changes
- Updates iptables (Linux firewall) rules based on Services
- When a request comes to a Service IP, kube-proxy intercepts it
- Routes the request to one of the healthy Pod IPs (load balancing)
- Can use round-robin, session affinity, or other algorithms

**Real-world example:**
```
Service: "myapp-service" has 3 Pod replicas
  - Pod-1 (10.0.1.5)
  - Pod-2 (10.0.1.6)
  - Pod-3 (10.0.1.7)

Request comes to: 10.0.0.100:80 (Service IP)

kube-proxy logic:
  Request 1 → Pod-1
  Request 2 → Pod-2
  Request 3 → Pod-3
  Request 4 → Pod-1 (round-robin)
```

---

### 3. Container Runtime (Docker/containerd)

**What it does:**
- Pulls container images from registries
- Creates container processes
- Manages container networking
- Manages container storage
- Runs and stops containers

**Container lifecycle:**
```
1. Image Pull: Download image from Docker Hub/ECR/private registry
2. Create: Create container from image
3. Start: Run container process
4. Health Checks: Monitor container health
5. Stop: Gracefully stop container
6. Cleanup: Remove container and volumes
```

**Example:**
```
Kubelet: "Run image nginx:latest"
  ↓
Container Runtime: "Pulling nginx:latest..."
  ↓
Container Runtime: "Creating container..."
  ↓
Container Runtime: "Container ID: abc123def456"
  ↓
Container Runtime: "Container running, listening on port 80"
```

---

### 4. Pods (Your Applications)

**What is a Pod?**
- Smallest deployable unit in Kubernetes
- Wrapper around one or more containers
- Usually contains one container (can have more for sidecar patterns)
- All containers in a Pod share networking (same IP address)

**Pod characteristics:**
- Ephemeral: Pods can be created and destroyed quickly
- Mortal: Pods are not meant to be permanent
- Identifiable: Have unique IP addresses within the cluster
- Isolated: Have their own network namespace

**Containers in a Pod share:**
- IP address and port space
- Storage volumes
- Configuration information (environment variables)
- Local inter-process communication (localhost)

**Example Pod with sidecar:**
```yaml
Pod: my-app-pod
├── Container 1: app (main application)
│   └── Port 8080
└── Container 2: logging-sidecar (sends logs to central system)
    └── Port 3000

Both share: 10.0.1.50 (Pod IP)
Can communicate via: localhost:8080 or localhost:3000
```

---

## User Request Flow (ALB to Pods)

This is the complete journey of an HTTP request from when a user clicks a link to when it reaches your application.

### The Complete Journey

```
┌─────────────────────────────────────────────────┐
│ Step 1: User hits ALB public URL                │
│ URL: http://myapp.example.com                   │
│ User's browser sends HTTP request               │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ Step 2: ALB receives request                    │
│ - ALB is AWS load balancer with public IP       │
│ - Has routing rules configured                  │
│ - Forwards to Ingress Controller Pod            │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ Step 3: Ingress Controller intercepts           │
│ - Reads Ingress resources (Kubernetes objects)  │
│ - Matches hostname/path to Service              │
│ - Example routing rules:                        │
│   /api/* → payment-service                      │
│   /images/* → image-service                     │
│   / → frontend-service                          │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ Step 4: Request reaches Service                 │
│ - Service is virtual network address            │
│ - Stable DNS name: frontend-service.default     │
│ - ClusterIP: 10.0.0.100                         │
│ - Service itself doesn't process requests      │
│ - Just a routing rule/load balancer             │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ Step 5: kube-proxy load balances                │
│ - Intercepts request at Service IP              │
│ - Has list of Pod IPs backing this Service:     │
│   • Pod-1: 10.1.1.5 (Node-1)                    │
│   • Pod-2: 10.1.2.6 (Node-2)                    │
│   • Pod-3: 10.1.3.7 (Node-1)                    │
│ - Selects Pod-2 using load balancing algorithm  │
│ - Rewrites destination IP to Pod IP (10.1.2.6)  │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ Step 6: Network overlay routes to Pod's node    │
│ - Request destination: Node-2 (10.1.2.6)        │
│ - If Pod is on different node, overlay network  │
│   (Flannel, Calico, Weave) tunnels packet       │
│ - Packet arrives at Node-2 interface            │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ Step 7: Kubelet on Worker Node                  │
│ - Kubelet receives packet at node interface     │
│ - Has mapping: Pod IP → Container process       │
│ - Routes packet to correct container namespace  │
│ - Container runtime sees incoming connection    │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ Step 8: Container Runtime                       │
│ - Docker/containerd receives packet             │
│ - Forwards to container process (app)           │
│ - Container listens on port 8080 (or configured)│
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ Step 9: Your Application processes request      │
│ - Node.js server, Python Flask, Go app, etc.    │
│ - Reads request headers and body                │
│ - Executes business logic                       │
│ - Queries databases if needed                   │
│ - Generates HTTP response                       │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│ Step 10: Response travels BACK (reverse path)   │
│ Container → Container Runtime → Kubelet         │
│ → kube-proxy → Service → Ingress → ALB          │
│ → User's browser displays response              │
└─────────────────────────────────────────────────┘
```

### Request Flow Diagram Summary

```
External User
    ↓ (HTTP request)
┌─────────────┐
│   ALB       │ ← Public endpoint
└─────────────┘
    ↓
┌─────────────────────────────────────┐
│ Master Node (Control Plane)         │
│ - API Server (processes requests)   │
│ - Scheduler (assigns pods)          │
│ - Controller Manager (maintains)    │
│ - etcd (database)                   │
└─────────────────────────────────────┘
    ↓ (manages)
┌──────────────────────┬──────────────────────┐
│  Worker Node 1       │  Worker Node 2       │
│ ┌────────────┐      │ ┌────────────┐       │
│ │ Kubelet    │      │ │ Kubelet    │       │
│ │ kube-proxy │      │ │ kube-proxy │       │
│ │ Runtime    │      │ │ Runtime    │       │
│ ├────────────┤      │ ├────────────┤       │
│ │ Pod-1      │      │ │ Pod-2      │       │
│ │ Pod-3      │      │ │ Pod-4      │       │
│ └────────────┘      │ └────────────┘       │
└──────────────────────┴──────────────────────┘
    ↓ (actual app containers)
Your Applications (Node.js, Python, Go, etc.)
```

---

## Key Concepts

### Master Node vs Worker Node

| Aspect | Master Node | Worker Node |
|--------|-------------|-------------|
| **Purpose** | Manages cluster | Runs applications |
| **Key Components** | API Server, Scheduler, Controller Manager, etcd | Kubelet, kube-proxy, Container Runtime |
| **Makes Decisions** | Yes | No (follows master orders) |
| **Runs Pods** | Usually no | Yes |
| **High Availability** | Run 3+ masters in production | Can have many workers |
| **Failure Impact** | Cluster management stops | Individual pods stop, others continue |

### Important Terms

**Service**
- Virtual network address for a group of Pods
- Stable IP that doesn't change even if Pods are recreated
- Types: ClusterIP (internal), NodePort (node IP), LoadBalancer (cloud LB)
- Example: All database pods are behind `db-service`

**Ingress**
- Routes external HTTP/HTTPS traffic to Services
- Understands HTTP paths and hostnames
- Manages SSL certificates
- Example: Route `api.example.com` to `api-service`, `www.example.com` to `web-service`

**Deployment**
- Describes desired state of application
- How many replicas, which image, resource limits, etc.
- Kubernetes maintains this desired state automatically

**StatefulSet**
- Like Deployment but for stateful applications
- Provides stable network identities
- Manages persistent storage
- Example: Databases, caches, message queues

**ConfigMap**
- Store non-sensitive configuration data
- Key-value pairs that Pods can read
- Example: App settings, feature flags

**Secret**
- Store sensitive data (passwords, API keys, tokens)
- Base64 encoded (not encrypted by default)
- Should be encrypted at rest in production

**Namespace**
- Virtual cluster within a cluster
- Isolate resources, teams, environments
- Example: `production`, `staging`, `development` namespaces

**Persistent Volume (PV)**
- Storage resource independent of Pods
- Survives Pod restarts
- Can be backed by cloud storage, NFS, local disk, etc.

**Persistent Volume Claim (PVC)**
- Pod's request for storage
- Claims a Persistent Volume
- Pods use PVCs to access storage

---

## What Makes Kubernetes Powerful

### 1. Self-Healing
```
Pod crashes → Kubelet detects it → Controller Manager creates new Pod
Automatically, without manual intervention
```

### 2. Auto-Scaling
```
kubectl scale deployment myapp --replicas=10
# 10 Pods created automatically on available nodes
```

### 3. Rolling Updates (Zero-Downtime Deployments)
```
Old version: 3 Pods running
Deploy new version: Kubernetes gradually replaces old Pods with new ones
Throughout process: Traffic continues, no downtime
```

### 4. Service Discovery
```
Pod-1 needs to talk to Pod-2
Doesn't need to know Pod-2's IP (it changes when Pod restarts)
Just uses DNS: pod2-service.default.svc.cluster.local
Automatically resolves to Pod-2's current IP
```

### 5. Load Balancing
```
Service with 3 Pod replicas
Each request automatically distributed to one Pod
Handles traffic spikes smoothly
```

### 6. Resource Management
```
Set resource requests and limits:
- Scheduler ensures nodes have capacity
- If Pod exceeds limit, Kubernetes kills and restarts it
- Efficient cluster utilization
```

### 7. Declarative Configuration
```yaml
# You describe desired state in YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  image: myapp:v1.0
  
# Kubernetes makes it reality
# You don't worry about HOW, just declare WHAT you want
```

### 8. Multi-Cloud and Hybrid Cloud
```
Same Kubernetes cluster can run on:
- AWS
- Google Cloud
- Azure
- On-premises
- Multiple clouds simultaneously

No vendor lock-in
```

### 9. Storage Orchestration
```
Pods need storage
Kubernetes automatically provisions and mounts volumes
Can be cloud storage, NFS, local disk, etc.
```

### 10. Secret and Configuration Management
```
Store secrets separately from code
Pods access them without hardcoding credentials
Easy to rotate secrets without redeploying apps
```

---

## Architecture Summary

### Component Relationships

```
User Request
    ↓
┌─────────────────────────────────────┐
│ CLUSTER BOUNDARY                    │
│                                     │
│ ┌──────────────────────────────┐   │
│ │ Master Node (Control Plane)  │   │
│ │ - API Server                 │   │
│ │ - Scheduler                  │   │
│ │ - Controller Manager         │   │
│ │ - etcd                       │   │
│ └──────────────────────────────┘   │
│         ↓ orchestrates              │
│ ┌──────────────────────────────┐   │
│ │ Worker Nodes (Multiple)      │   │
│ │                              │   │
│ │ Node 1:                      │   │
│ │ ├─ Kubelet                   │   │
│ │ ├─ kube-proxy                │   │
│ │ ├─ Container Runtime         │   │
│ │ └─ Pods (running containers) │   │
│ │                              │   │
│ │ Node 2: (Same structure)     │   │
│ │ Node N: (Same structure)     │   │
│ │                              │   │
│ └──────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
    ↓
Application Response
```

### Data Flow

```
1. Desired State (YAML)
   ↓
2. API Server validates and stores in etcd
   ↓
3. Controller Manager reads desired state, compares with actual
   ↓
4. Scheduler assigns Pods to Nodes
   ↓
5. Kubelet receives assignments, creates Pods
   ↓
6. Container Runtime pulls images, runs containers
   ↓
7. kube-proxy sets up networking
   ↓
8. Service routes traffic to running Pods
   ↓
9. Ingress routes external traffic to Services
   ↓
10. Your application receives and processes requests
```

---

## Quick Reference

### Master Node Components Checklist
- [ ] API Server - Entry point for all requests
- [ ] Scheduler - Assigns Pods to Nodes
- [ ] Controller Manager - Maintains desired state
- [ ] etcd - Persists cluster state

### Worker Node Components Checklist
- [ ] Kubelet - Creates and manages Pods
- [ ] kube-proxy - Routes traffic to Pods
- [ ] Container Runtime - Runs containers
- [ ] Pods - Your application containers

### Request Path Checklist
1. [ ] ALB receives request
2. [ ] Ingress Controller routes to Service
3. [ ] Service routes to Pod
4. [ ] kube-proxy load balances
5. [ ] Network overlay tunnels if needed
6. [ ] Kubelet forwards to Container Runtime
7. [ ] Container Runtime forwards to application
8. [ ] Application processes and responds
9. [ ] Response travels back through same path

---

## Conclusion

Kubernetes is a powerful, self-healing container orchestration platform. Understanding these core components helps you:

- **Deploy applications reliably**: Master ensures desired state
- **Scale automatically**: Scheduler distributes work
- **Handle failures gracefully**: Controller Manager restarts failed Pods
- **Manage networking**: Services and kube-proxy route traffic
- **Persist data**: etcd and storage solutions
- **Monitor and debug**: View logs, metrics, events

The master node makes intelligent decisions, while worker nodes execute those decisions by running your containerized applications. Together, they create a resilient, scalable platform for modern cloud-native applications.


**understand variables**

- `cluster_endpoint_public_access = true`

- This makes your eks cluster's endpoints publically accessible.

- So, public user can access your applications directly from internet.

- `cluster_endpoint_public_access_cidr = ["0.0.0.0/0"]`

- This is inbound traffic restrictions.

- It will allow anybody from internet to your applications directly.

- If you set to `["1.2.3.4/24"]` or your ip ranges , then it will allow from this CIDR only.

