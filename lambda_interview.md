## Q-1 How Can you manage state in AWS Lambda Functions ?

- AWS Lambda Functions is a stateless. It doesn't store data.

- You can manage state externally using Services like DynamoDB, RDS or other storage sols.

## Q-2 What is deployment pkg in lambda ?

- Whenever we creates a lambda functions , lambda creates .zip archive file which contains App code, dependencies which requires to execute lambda functions.

- It is uploaded to aws lambda function during creation or updates.

## Q-3 How does lambda handle Concurrency ?

- AWS Lambda automatically scales horizontally to handle your incoming a lot of concurrency requests.

- We can define the memory but we don't have to worry about to scale this memory , cpu.

- Each functions executions is independent.

- Lambda can run multiple instances of a function concurrently to handle increased loads.

## Q-4 Can aws lambda functions Access resources inside VPC ?

- Yes!. This allows functions to connect securly to pvt resources like RDS, EC2.

## Q-5 What is the cold start issue in lambda ? How it can be mitigated ?

- The cold start issue refers to the `Latency Experienced` When a Lambda functions is involked for the first time or after being idle.

- To mitigate this, you can use `Provisioned Concurrency`, `Warm up techniques`, or consider using `AWS Lambda's Provisioned concurrency feature`.


## 1. What is a Cold Start?

A **Cold Start** is the temporary delay (latency spike) when AWS Lambda receives a request and has to create a brand-new container environment from scratch before it can execute your code.

When a cold start occurs, AWS does 3 main things in the background before running your code:

1. **Downloads your code/container image.**
2. **Starts the runtime environment** (e.g., Python, Node.js, Java execution environment).
3. **Runs initialization code** (everything outside your main function handler, like importing packages, opening database connections, or creating SDK clients).

### When does a Cold Start happen?

Cold starts happen in three specific scenarios:

* **Scenario 1: First invocation after deployment / idle time.**
If a function hasn't been invoked for ~15–30 minutes, AWS terminates the idle environment to save resources. The next request triggers a cold start.
* **Scenario 2: Traffic spikes (scaling out).**
If 1 instance is warm, but 10 requests arrive simultaneously, AWS creates 9 new instances to handle the parallel traffic. Those 9 requests experience cold starts.
* **Scenario 3: Code or configuration updates.**
Whenever you deploy new code or update environment variables, all existing execution environments are destroyed.

## 2. Mitigation Techniques

Here are the primary ways SREs reduce or eliminate cold start latency:

### Method A: Provisioned Concurrency (Official AWS Feature)

* **What it is:** You pay AWS to keep a specified number of execution environments pre-warmed 24/7 (initialized and sitting ready in memory).
* **Result:** Zero cold start latency for requests up to your provisioned limit.

### Method B: Warm-Up Techniques (Custom Script Workaround)

* **What it is:** Creating an **Amazon EventBridge** rule that sends a dummy request (ping) to your Lambda every 5 to 10 minutes.
* **How it works:** This keeps at least **1** execution environment active and prevents AWS from reaping it due to idleness.
* **Limitation:** It only keeps **one** instance warm. If you get a sudden burst of 50 concurrent requests, 49 of them will still hit cold starts.

### Method C: Code and Architecture Optimization

* **Lean Imports:** Only import necessary packages (e.g., in Python, import specific SDK modules rather than `import boto3`).
* **Increase Memory Allocation:** Increasing Lambda memory (e.g., from 128 MB to 1024 MB) proportionally increases CPU performance, making initialization code run significantly faster.
* **SnapStart (For Java / Python 3.12+):** AWS takes a snapshot of the initialized memory state and restores it in milliseconds rather than running cold init code.

## 3. Where to Find and Configure Them in the AWS Console

Here is how you locate and set up these mitigations directly in the AWS Management Console:

### Configuring Provisioned Concurrency

1. Open the **AWS Lambda Console** and click on your function.
2. Go to the **Configuration** tab.
3. In the left sidebar, click **Concurrency**.
4. Scroll down to the **Provisioned concurrency configurations** section and click **Add configuration**.
5. Choose **Alias** or **Version** (Provisioned Concurrency *cannot* be attached to `$LATEST`; you must publish a version or use an alias like `prod`).
6. Enter the number of concurrent instances you want to keep warm (e.g., `5`).
7. Click **Save**.

```
AWS Lambda Console
 └── Functions ──► [Your Function Name]
      └── Configuration (Tab)
           └── Concurrency (Left Side)
                └── Provisioned Concurrency ──► [Add Configuration]

```

### Configuring Warm-Up Scripts (EventBridge)

1. Open the **Amazon EventBridge Console**.
2. Go to **Rules** and click **Create rule**.
3. Set the Rule Type to **Schedule** (e.g., `rate(5 minutes)`).
4. For the **Target**, select **Lambda function** and choose your function.
5. In the target payload, pass a custom JSON flag like `{"source": "warmup-plugin"}`.
6. In your Lambda code, check for this flag and return early so you don't execute heavy business logic:

```python
def lambda_handler(event, context):
    # Quick exit for warmup pings
    if event.get("source") == "warmup-plugin":
        return {"statusCode": 200, "body": "Warmed!"}
    
    # Normal business logic runs below...

```

## Quick Summary Table

| Mitigation Strategy | AWS Console Location | Cost Impact | Handles Traffic Spikes? |
| --- | --- | --- | --- |
| **Provisioned Concurrency** | Lambda > Configuration > Concurrency | Charged hourly for warm instances | **Yes**, up to provisioned count |
| **EventBridge Warm-up** | EventBridge > Rules > Create Schedule | Pennies (standard invocation fee) | **No**, only keeps 1 instance warm |
| **Memory Tuning** | Lambda > Configuration > General configuration | Higher rate, but runs faster | **Yes**, reduces init duration |

## Q-6 You have a requireement to process files as they are uploaded to s3 bucket. How would you use Lambda ?

- I would set up S3 Event notification to trigger an AWS Lambda Functions whenever a file is uploaded to the bucket.

- The lambda function would then process the file as required.

- By using lambda in this way, the process is serverless and scales automatically based on file upload frequency.

## Q-7 How would you optimize Lambda if Cold-Start times are impacting performance ?

- I will use `Provisioned Concurrency`, which keeps a specified number of instances warm.

- Additionally, I would optimize the function code by minimizing external dependencies and using lambda layers effectively to handle shared libraries.

## Q-8 Your applicatoins exp unpredictable, spiky traffic patterns. How would you ensure that lambda can handle this ?

- AWS Lambda automatically scales with traffic.

- If requires, I will increase `Concurrent Execution Limit` for the lambda.

## Q-9 How would you manage database connections from aws lambda to an RDS DB in a high-traffic scenarios ?

-  Managing connections can be challenging since lambda scales horizontally, potentially overwhelming the RD DB with connections.

- I will use Amazon RDS Proxy, which pools and reuse connections, reducing the impact of lambda's scaling on the DB.

- This approach also reduce latency and improves lambda's ability to manage connections efficently.

## Q-10 You have a lambda functions to processing msg from SQS Queue, but Ocassionally it encounters Error. How would you handle error and retries ?

- Lambda automatically retries up to 2 times for asynchonous invocations.

- I will configure a Dead Letter Queue for failed msg that requires manual interventions.

- Additionally, I would use CW Logs and Metrics for high error rates to investigate recurring issues and handle them proactively.

## Q-11 Your lambda requires more than the Max minutes of execution times to complete a task which is max 15 minutes for lambda. What alternative approach would you consider ?

- Lambda has a Max 15 minutes execution limits, I would break down the task into smaller parts.

- I can trigger a multiple lambda in a step-by-step process using AWS Step Functions to orchestrate the executions.

## Q-12 You have an API Gateway EndPoint integrated with a Lambda functions, but users report latency issues. What steps could you take to reduce latency ?

- I will check for cold starts and enalbe `Provisioned Concurrency` if latency is due to initialization time.

- I will reduce Package Size, Optimizing the code and caching data.

- I will configure lambda's memory allocations, as increasing memory often reduces execution time, which could help to reduce latency.

## Q-13 How would you share a common code acrosse multiple Lambda without duplicating it in each functions ?

- I will use Lambda Layers, which allows code and libraries to be packaged and shared across multiple lambda functions.

- Layeres are stored seperately, which will enable each functions to import the layer at runtime.

## Q-14 How would you ensure data processed by lambda is secures and meets compliance requirements ?

- I will use KMS to encrypt env vars and any data at rest.

- I will configure VPC access if the function interacts with secure internal resources and use CW Logs for auditing.

# Real Interivew Questions

## Q-1 how to plan to upgrade Lambda functions ?

- **Understand requirement** - Why we are going to upgrade ? What things we are going to upgrade in lambda, like Runtime due to End-Of-Life of Lambda Functions, Any dependencies like in .zip file or in Lambda Layers ?.

- **Analyze Impact and Risk** - I will understand about `Which lambda functions may affected ?` , `Will Any AWS Services may affect to this Lambda ?` , `Can user will face some downtime issue during or after upgradations ?`, `Any IAM Permissions Issues ?`, `Will this new version of lambda can failed due to executions time, dependencies issues`.

- **Create change request** - I will follow the Organizations change management process. I will create docs for what we are going to change, its imapct on our infra and active user, Prepare for rollback. I will get approvals from stackholders.


- **Zoho Communications for Advance** - I will send advance communications to our active user via Zoho, ServiceNow, Emails to inform our clients.

- **Test in QA, UAT** - Before deploying to Prod, i will test this new versions of lambda into QA or UAT. If everything is ok then i will schedule mantainence windows for Prod Deployment.

- **Deploy to Prod** - I will publish new version with use of Alias to shift traffic gradually. 

- **Monitor Lambda and its behavior Closely** - After deployment, I will closely monitor CW Metrics, Logs, Error Rates, Execution times. During my L0 Monitoring, my responsibility was to monitor  dashbaords, alerts, APM behaviros during and after the planned deployment, changes. 

- If we observed anything wrongs , we have to collect metrics, logs, its impact to other services and inform to L1/L2 team. They will investigate further.


## Q-2 What is landing zone ?

- "A Landing Zone is a pre-configured, secure AWS environment that provides a standard foundation for all AWS accounts in an organization. It automatically configures networking, security, logging, IAM, and governance so every new AWS account follows the company's standards."

```
                    Company

                       │

                AWS Organization

                       │

                Landing Zone

                       │

        ┌──────────────┼───────────────┐

        │              │               │

     Dev Account    Test Account   Prod Account

        │              │               │

 All automatically configured
```

Here is a clear breakdown of the difference between the two and how to set up your first landing zone:
## AWS Organizations vs. AWS Control Tower

* AWS Organizations is the foundational infrastructure layer. It provides the raw capability to create new accounts, group them into Organizational Units (OUs), and apply Service Control Policies (SCPs) for centralized billing and security.

* AWS Control Tower is the orchestration layer. It is a managed service that sits on top of AWS Organizations. It automates the setup of a landing zone by automatically creating the recommended OUs, setting up log archives, and deploying pre-configured security guardrails.

## How to Set Up Your First Landing Zone
The easiest way to build a landing zone is by using AWS Control Tower within a new or existing management account:

   1. Prepare Account Requirements: You will need a dedicated AWS account to act as your Management account, along with two unique, unassociated email addresses to automatically create your Log Archive and Audit security accounts.

   2. Launch Control Tower: Log into the AWS Management Console, navigate to the AWS Control Tower dashboard, and click Set up landing zone.

   3. Configure Your OUs: Review the default 
   Organizational Units (typically a Security OU for logs/audits and a Sandbox or Workloads OU for development).

   4. Select Guardrails: Choose the mandatory and strongly recommended guardrails (such as disallowing public S3 buckets or forcing MFA) that you want to enforce across all accounts.

   5. Deploy: Click launch. The automated setup process takes about 30 to 45 minutes to provision your foundational secure environment.

