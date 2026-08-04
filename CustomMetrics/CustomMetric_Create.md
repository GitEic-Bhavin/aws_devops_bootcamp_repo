## Create Custom Metrics and send to CW Logs and Dashboard

## Approach 1: Instrument your apps nginx by use _aws.

## Approach 2: Use CW Agent as sidecar container.

# 📊 AWS ECS Fargate - Custom CloudWatch Metrics Using Embedded Metric Format (EMF)

> A production-style guide demonstrating how to create **application-level custom CloudWatch metrics** from an **Nginx application running on Amazon ECS Fargate** using the **CloudWatch Embedded Metric Format (EMF)**—without calling the CloudWatch `PutMetricData` API or installing additional monitoring agents.

---

# 📑 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Project Goal](#-project-goal)
- [How EMF Works](#-how-emf-works)
- [End-to-End Data Flow](#-end-to-end-data-flow)
- [Why Use EMF?](#-why-use-emf)
- [Step 1 - Nginx Receives HTTP Requests](#-step-1---nginx-receives-http-requests)
- [Step 2 - Generate EMF JSON Logs](#-step-2---generate-emf-json-logs)
- [Step 3 - Send Logs to CloudWatch Logs](#-step-3---send-logs-to-cloudwatch-logs)
- [Step 4 - CloudWatch Extracts Metrics](#-step-4---cloudwatch-extracts-metrics)
- [Step 5 - Custom Metrics are Created](#-step-5---custom-metrics-are-created)
- [Understanding EMF Fields](#-understanding-emf-fields)
- [Why RequestCount = 1?](#-why-requestcount--1)
- [Why Use Dimensions?](#-why-use-dimensions)
- [CloudWatch Dashboard](#-cloudwatch-dashboard)
- [Interview Questions](#-interview-questions)
- [Key Takeaways](#-key-takeaways)

---

# 🎯 Overview

Amazon CloudWatch automatically provides infrastructure metrics such as:

- ECS CPU Utilization
- ECS Memory Utilization
- Network In/Out
- ALB Request Count

However, it **does not automatically know** about your application's internal metrics such as:

- HTTP 200 responses
- HTTP 404 responses
- HTTP 500 errors
- Login success/failure
- Business transactions

To monitor these application-specific events, we created **custom CloudWatch metrics** using the **Embedded Metric Format (EMF)**.

---

# 🏗 Architecture

```text
                  HTTP Request
                        │
                        ▼
              ECS Task (Fargate)
        ┌────────────────────────────┐
        │        Nginx Container      │
        │                            │
        │ Custom EMF JSON Log Format │
        │ access_log → /dev/stdout   │
        └────────────────────────────┘
                        │
                        ▼
           ECS awslogs Log Driver
                        │
                        ▼
              CloudWatch Logs Group
                        │
      Detect "_aws" EMF Metadata
                        │
                        ▼
     Extract Embedded Metrics
                        │
                        ▼
     CloudWatch Custom Metrics
      Namespace: Nginx/EMFMetrics
                        │
                        ▼
        CloudWatch Dashboard
```

---

# 🎯 Project Goal

The objective of this project was to create **real-time application metrics** for an Nginx application running on ECS Fargate.

Instead of monitoring only infrastructure metrics, we wanted to monitor:

- Number of successful requests (HTTP 200)
- Number of client errors (HTTP 404)
- Number of server errors (HTTP 500)

These metrics would then be visualized on a CloudWatch Dashboard.

---

# ⚙️ How EMF Works

CloudWatch Embedded Metric Format (EMF) allows applications to publish metrics simply by writing specially formatted JSON logs.

Unlike the traditional approach:

```
Application
      │
PutMetricData API
      │
CloudWatch Metrics
```

EMF works like this:

```
Application
      │
EMF JSON Log
      │
CloudWatch Logs
      │
Automatic Metric Extraction
      │
CloudWatch Metrics
```

No explicit API call is required.

---

# 🔄 End-to-End Data Flow

```text
HTTP Request
      │
      ▼
Nginx Receives Request
      │
      ▼
Generate EMF JSON Log
      │
      ▼
Write Log to stdout
      │
      ▼
awslogs Driver
      │
      ▼
CloudWatch Logs
      │
      ▼
CloudWatch Detects "_aws"
      │
      ▼
Extracts Metric
      │
      ▼
Stores Metric
      │
      ▼
CloudWatch Dashboard
```

---

# ✅ Why Use EMF?

## No CloudWatch API Calls

No need to invoke:

```bash
aws cloudwatch put-metric-data
```

CloudWatch automatically extracts metrics from logs.

---

## No Additional Monitoring Agent

No need for:

- CloudWatch Agent
- Fluent Bit
- Fluentd
- OpenTelemetry Collector
- Prometheus Exporter

The standard ECS `awslogs` log driver is sufficient.

---

## Cost Effective

Since logs are already being shipped to CloudWatch Logs, EMF enables metrics without adding another metric publishing mechanism.

---

## Easy to Scale

Every container automatically emits metrics using its own application logs.

No additional infrastructure is required.

---

# 🟢 Step 1 - Nginx Receives HTTP Requests

Suppose a client sends:

```text
GET /
```

Nginx responds:

```text
HTTP 200
```

or

```text
HTTP 404
```

Normally Nginx would generate a plain-text access log like:

```text
GET / HTTP/1.1 200
```

CloudWatch treats this as plain text and **cannot create metrics** from it.

---

# 🟢 Step 2 - Generate EMF JSON Logs

Instead of plain-text logs, Nginx is configured to generate EMF-compliant JSON.

Example:

```json
{
  "_aws": {
    "Timestamp": 1722680000123,
    "CloudWatchMetrics": [
      {
        "Namespace": "Nginx/EMFMetrics",
        "Dimensions": [
          [
            "ServiceName",
            "Status"
          ]
        ],
        "Metrics": [
          {
            "Name": "RequestCount",
            "Unit": "Count"
          }
        ]
      }
    ]
  },
  "ServiceName": "NginxService",
  "Status": "200",
  "RequestCount": 1
}
```

The special `_aws` section tells CloudWatch that this log contains embedded metrics.

---

# 🟢 Step 3 - Send Logs to CloudWatch Logs

The Nginx access log is written to:

```text
/dev/stdout
```

The ECS Task Definition uses:

```json
"logConfiguration": {
  "logDriver": "awslogs"
}
```

Flow:

```text
Nginx
   │
stdout
   │
awslogs Driver
   │
CloudWatch Logs
```

No custom agent is installed.

---

# 🟢 Step 4 - CloudWatch Extracts Metrics

When CloudWatch Logs receives an EMF JSON document, it automatically detects the `_aws` metadata.

It extracts:

| Property | Value |
|----------|-------|
| Namespace | Nginx/EMFMetrics |
| Metric Name | RequestCount |
| Dimension | ServiceName |
| Dimension | Status |
| Metric Value | 1 |

CloudWatch internally converts the log into a custom metric.

---

# 🟢 Step 5 - Custom Metrics are Created

Suppose the application receives:

```text
200
200
200
404
404
500
```

CloudWatch stores:

| Status | RequestCount |
|---------|-------------|
| 200 | 3 |
| 404 | 2 |
| 500 | 1 |

These values become available under:

```
CloudWatch
    ↓
Metrics
    ↓
Custom Namespaces
    ↓
Nginx/EMFMetrics
```

---

# 📖 Understanding EMF Fields

| Field | Purpose |
|--------|----------|
| `_aws` | Indicates this log contains Embedded Metric Format metadata |
| `Namespace` | Groups related custom metrics together |
| `Metrics` | Defines which metric(s) should be created |
| `Dimensions` | Used to filter and group metrics |
| `Timestamp` | Time when the metric occurred |
| `RequestCount` | Numeric value stored as the metric |
| `Status` | HTTP response code used as a dimension |

---

# ❓ Why RequestCount = 1?

Each HTTP request emits:

```json
"RequestCount": 1
```

Example:

```
Request 1
↓

1

Request 2
↓

1

Request 3
↓

1
```

CloudWatch aggregates these values.

Using:

```
Statistic = Sum
```

CloudWatch displays:

```
3 Requests
```

The application does not count requests itself—CloudWatch performs the aggregation.

---

# ❓ Why Use Dimensions?

Without dimensions, CloudWatch would only know:

```
RequestCount = 100
```

There would be no way to distinguish successful requests from failed requests.

Using the `Status` dimension:

```
Status = 200
Status = 404
Status = 500
```

CloudWatch creates separate metric series.

This allows dashboards to display:

- Successful Requests
- Client Errors
- Server Errors

independently.

---

# 📈 CloudWatch Dashboard

Navigate to:

```
CloudWatch
    ↓
Metrics
    ↓
All Metrics
    ↓
Custom Namespaces
    ↓
Nginx/EMFMetrics
```

Select:

- RequestCount
- Status = 200
- Status = 404
- Status = 500

Recommended Graph Settings:

- Statistic: **Sum**
- Period: **1 Minute**

Example Dashboard:

```text
HTTP 200 Requests ███████████████

HTTP 404 Requests ██

HTTP 500 Requests █
```

---

# 💬 Interview Questions

### Why did you use EMF instead of PutMetricData?

EMF eliminates explicit API calls. CloudWatch automatically extracts metrics from logs, reducing application complexity and avoiding API throttling.

---

### Why write logs to `/dev/stdout`?

The ECS `awslogs` log driver captures everything written to stdout and forwards it to CloudWatch Logs.

---

### Did you install the CloudWatch Agent?

No.

The solution uses only:

- Nginx
- ECS awslogs driver
- CloudWatch Logs
- Embedded Metric Format (EMF)

---

### How does CloudWatch know a log contains metrics?

CloudWatch looks for the special `_aws` object. If present, it parses the log as an Embedded Metric Format document and extracts the metric definitions automatically.

---

### What is the benefit of using dimensions?

Dimensions allow metrics to be grouped and filtered. For example, using the `Status` dimension lets you separately visualize HTTP 200, 404, and 500 responses.

---

# 🎯 Key Takeaways

- Custom application metrics are not generated automatically by CloudWatch.
- EMF enables metrics to be embedded directly within application logs.
- The ECS `awslogs` log driver forwards logs to CloudWatch Logs.
- CloudWatch detects the `_aws` metadata and automatically creates custom metrics.
- No `PutMetricData` API calls are required.
- No CloudWatch Agent or sidecar container is required.
- Dimensions such as `Status` make it easy to filter and visualize metrics.
- CloudWatch Dashboards can display these custom metrics in near real time for operational monitoring.

---

# 📊 AWS ECS Fargate - CloudWatch Agent Sidecar for Nginx Log Collection

> A production-style guide demonstrating how to collect **application logs** from an **Nginx container running on Amazon ECS Fargate** using the **CloudWatch Agent Sidecar pattern**. The CloudWatch Agent runs as a separate container in the same ECS Task, reads log files from a shared volume, and publishes them to Amazon CloudWatch Logs.

---

# 📑 Table of Contents

- [Overview](#-overview)
- [Architecture Overview](#-architecture-overview)
- [How the Sidecar Pattern Works](#-how-the-sidecar-pattern-works)
- [Project Goal](#-project-goal)
- [Step 1 - Configure Nginx Logging](#-step-1---configure-nginx-logging)
- [Step 2 - Create a Shared ECS Volume](#-step-2---create-a-shared-ecs-volume)
- [Step 3 - Configure the CloudWatch Agent](#-step-3---configure-the-cloudwatch-agent)
- [Step 4 - Configure IAM Permissions](#-step-4---configure-iam-permissions)
- [Step 5 - Create CloudWatch Metric Filters](#-step-5---create-cloudwatch-metric-filters)
- [End-to-End Data Flow](#-end-to-end-data-flow)
- [Troubleshooting Guide](#-troubleshooting-guide)
- [Interview Questions](#-interview-questions)
- [Key Takeaways](#-key-takeaways)

---

# 🎯 Overview

In this approach, the **CloudWatch Agent** runs as a **sidecar container** inside the same ECS Task as the application.

Unlike the **Embedded Metric Format (EMF)** approach, the application does **not** write metrics directly.

Instead:

- Nginx writes standard access logs to a shared file.
- The CloudWatch Agent continuously tails that file.
- The agent uploads logs to Amazon CloudWatch Logs.
- CloudWatch Metric Filters convert matching log patterns into CloudWatch Metrics.

---

# 🏗 Architecture Overview

```text
                    HTTP Request
                          │
                          ▼
                 ECS Task (Fargate)
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  ┌──────────────────────┐      Shared Volume               │
│  │   Nginx Container    │──────────────┐                   │
│  │                      │              │                   │
│  │ Writes access.log    │              │                   │
│  └──────────────────────┘              │                   │
│                                        ▼                   │
│                             /mnt/nginx_logs/access.log     │
│                                        ▲                   │
│  ┌──────────────────────┐              │                   │
│  │ CloudWatch Agent     │──────────────┘                   │
│  │ Sidecar Container    │                                  │
│  │ Reads log file       │                                  │
│  │ Pushes logs          │                                  │
│  └──────────────────────┘                                  │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
               Amazon CloudWatch Logs
                          │
                          ▼
             CloudWatch Metric Filters
                          │
                          ▼
              CloudWatch Custom Metrics
                          │
                          ▼
               CloudWatch Dashboard
```

---

# 🔄 How the Sidecar Pattern Works

A **sidecar container** is a helper container that runs alongside the main application container in the same ECS Task.

In this project:

- **Main Container**
  - Runs Nginx
  - Generates access logs

- **Sidecar Container**
  - Runs the official CloudWatch Agent
  - Continuously monitors log files
  - Sends logs to CloudWatch Logs

Both containers share the same storage volume.

---

# 🎯 Project Goal

Collect Nginx access logs from an ECS Fargate application without modifying application code.

After logs are collected:

- Store them in CloudWatch Logs
- Create Metric Filters
- Generate CloudWatch Metrics
- Visualize them on a CloudWatch Dashboard

---

# 🟢 Step 1 - Configure Nginx Logging

By default, Nginx writes logs to:

```text
/dev/stdout
```

For the sidecar approach, configure Nginx to write logs to a shared directory.

Example:

```text
/mnt/nginx_logs/access.log
```

The CloudWatch Agent will continuously monitor this file.

### Important

Avoid writing logs to shared system directories such as:

```text
/var/log
/tmp
/etc
```

Mounting these paths across containers can hide critical system files and may result in:

```text
ResourceInitializationError
```

After updating the configuration:

- Rebuild the Docker image
- Push the updated image to Amazon ECR

---

# 🟢 Step 2 - Create a Shared ECS Volume

Create an ECS **Bind Mount Volume**.

Example:

```text
Volume Name

nginx-logs
```

Mount the volume into both containers.

### Nginx Container

```text
Mount Path

/mnt/nginx_logs

Read / Write
```

### CloudWatch Agent Sidecar

```text
Mount Path

/mnt/nginx_logs

Read Only
```

This enables the agent to read the same log file created by Nginx.

---

# 🟢 Step 3 - Configure the CloudWatch Agent

Use the official CloudWatch Agent image:

```text
public.ecr.aws/cloudwatch-agent/cloudwatch-agent:latest
```

Instead of mounting a configuration file, provide the configuration through the environment variable:

```text
CW_CONFIG_CONTENT
```

The configuration should include:

- ECS mode
- Log file path
- Log Group name
- Log Stream name

Example configuration:

```json
{
  "agent": {
    "mode": "ecs"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/mnt/nginx_logs/access.log",
            "log_group_name": "/ecs/nginx-sidecar-logs",
            "log_stream_name": "{hostname}-access"
          }
        ]
      }
    }
  }
}
```

### Important

When using `CW_CONFIG_CONTENT` inside the Task Definition, provide the JSON as a **single-line minified string**.

Multi-line JSON often causes the CloudWatch Agent to fail during startup.

---

# 🟢 Step 4 - Configure IAM Permissions

The CloudWatch Agent sends logs directly to AWS APIs.

Therefore, it requires permissions through the **Task Role**, not the **Task Execution Role**.

Attach the following managed policy:

```text
CloudWatchAgentServerPolicy
```

This policy includes permissions such as:

- logs:CreateLogGroup
- logs:CreateLogStream
- logs:PutLogEvents
- cloudwatch:PutMetricData

---

# 🟢 Step 5 - Create CloudWatch Metric Filters

After logs appear in:

```text
/ecs/nginx-sidecar-logs
```

Create CloudWatch Metric Filters.

Example:

### HTTP Success

Pattern:

```text
[..., status_code = 200, ...]
```

Metric Name:

```text
RequestSuccessCount
```

---

### HTTP Errors

Pattern:

```text
[..., status_code = 4*, ...]
```

or

```text
[..., status_code = 5*, ...]
```

Metric Name:

```text
RequestFailureCount
```

These Metric Filters automatically convert matching log events into CloudWatch Metrics.

---

# 🔄 End-to-End Data Flow

```text
HTTP Request
      │
      ▼
Nginx Container
      │
Writes access.log
      │
      ▼
Shared ECS Volume
      │
      ▼
CloudWatch Agent Sidecar
      │
Reads access.log
      │
      ▼
CloudWatch Logs
      │
      ▼
CloudWatch Metric Filters
      │
      ▼
CloudWatch Metrics
      │
      ▼
CloudWatch Dashboard
```

---

# 🛠 Troubleshooting Guide

| Issue | Root Cause | Solution |
|--------|------------|----------|
| Exit Code 1 | Missing `"agent":{"mode":"ecs"}` or invalid JSON in `CW_CONFIG_CONTENT` | Add ECS mode and use single-line JSON |
| ResourceInitializationError | Mounted shared volume over `/tmp`, `/etc`, or other system paths | Use a dedicated path such as `/mnt/nginx_logs` |
| Log Group Not Created | Log file does not exist or contains no data | Generate traffic using `curl` so Nginx creates the log file |
| AccessDeniedException | Task Role lacks CloudWatch permissions | Attach `CloudWatchAgentServerPolicy` to the Task Role |

---

# 💬 Interview Questions

## Why use a CloudWatch Agent Sidecar?

The sidecar continuously collects application log files and sends them to CloudWatch Logs without modifying the application code.

---

## Why use a shared ECS volume?

The Nginx container writes logs while the CloudWatch Agent reads those same logs. A shared volume allows both containers to access the same files.

---

## Why shouldn't logs be stored in `/tmp` or `/etc`?

Mounting shared volumes over system directories can hide required files inside the container filesystem, causing container initialization failures.

---

## Why does the CloudWatch Agent need the Task Role?

The CloudWatch Agent runs as a container after the ECS Task starts and directly calls AWS APIs such as:

- `logs:PutLogEvents`
- `logs:CreateLogGroup`
- `logs:CreateLogStream`

Since the running container performs these API calls, it uses the **Task Role**.

---

## Why aren't metrics created automatically?

The CloudWatch Agent only uploads log data.

CloudWatch Metric Filters must be configured separately to match specific log patterns and create CloudWatch Metrics.

---

## What is the difference between EMF and the CloudWatch Agent Sidecar?

| Embedded Metric Format (EMF) | CloudWatch Agent Sidecar |
|------------------------------|--------------------------|
| Application writes EMF JSON logs | Application writes normal log files |
| CloudWatch automatically extracts metrics | Metric Filters convert logs into metrics |
| No CloudWatch Agent required | CloudWatch Agent container required |
| No Metric Filters required | Metric Filters required |
| Best for structured application metrics | Best for collecting existing log files |

---

# 🎯 Key Takeaways

- The CloudWatch Agent runs as a sidecar container within the same ECS Task.
- A shared ECS Bind Mount Volume enables both containers to access the same log file.
- Nginx writes logs to a dedicated shared directory instead of `stdout`.
- The CloudWatch Agent tails the log file and uploads entries to CloudWatch Logs.
- The CloudWatch Agent requires IAM permissions through the **Task Role**.
- CloudWatch Metric Filters convert matching log patterns into custom CloudWatch Metrics.
- The resulting metrics can be visualized on CloudWatch Dashboards for monitoring and alerting.