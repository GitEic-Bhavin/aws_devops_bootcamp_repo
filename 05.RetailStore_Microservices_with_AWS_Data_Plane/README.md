A Global Secondary Index (GSI) is used to query data using alternative keys instead of the table's primary partition key.
In DynamoDB, you can normally only look up items efficiently using the primary key. If you try to look up items using any other attribute, DynamoDB must perform a Scan, which reads every single item in the table. This is slow, expensive, and fails on large datasets. A GSI solves this problem.
------------------------------
## Why use a GSI? (Key Benefits)

* Fast Queries on Non-Key Attributes: A GSI creates a "shadow copy" of your table, rearranged by a new partition key. This allows for lightning-fast lookups (millions of requests per second) on attributes that are not your primary key.
* Flexible Data Access Patterns: Single-table design in NoSQL requires you to answer multiple business questions. A GSI lets you query the exact same data from different angles.
* Cost and Performance Optimization: By preventing full table scans, you drastically reduce read costs and application latency.
* Custom Scaling: A GSI has its own read/write capacity settings. If one specific query pattern is heavily used, you can scale that index independently without paying to scale the whole main table.

------------------------------
## Real-World Example
Imagine an E-commerce Orders table:

* Main Table Primary Key: OrderId (String)

| OrderId (Hash Key) | CustomerId | OrderDate | TotalAmount | Status |
|---|---|---|---|---|
| ORD-001 | CUST-99 | 2026-05-01 | $150.00 | Shipped |
| ORD-002 | CUST-44 | 2026-05-02 | $45.00 | Pending |
| ORD-003 | CUST-99 | 2026-05-03 | $80.00 | Shipped |

## The Problem
If your app needs to "Find all orders for Customer CUST-99", DynamoDB cannot do this efficiently because CustomerId is not the primary key. It has to scan the whole database.
## The GSI Solution
You create a GSI where:

* GSI Partition Key: CustomerId
* GSI Sort Key: OrderDate

DynamoDB automatically copies and maintains a secondary view behind the scenes:

| CustomerId (GSI Hash) | OrderDate (GSI Sort) | OrderId | TotalAmount | Status |
|---|---|---|---|---|
| CUST-44 | 2026-05-02 | ORD-002 | $45.00 | Pending |
| CUST-99 | 2026-05-01 | ORD-001 | $150.00 | Shipped |
| CUST-99 | 2026-05-03 | ORD-003 | $80.00 | Shipped |

Now, your application can instantly query by CustomerId to fetch all orders for a user, sorted by date.
------------------------------
If you are designing a table right now, I can help you set up the index. Let me know:

* What main attributes are in your data?
* What questions/queries does your application need to ask the database?
* How large do you expect the table to grow?


**CheckOut** - Will connect to the AWS ElastiCache - Redis

- It will not requires PIA, PIA Associations, Just need to connect to `AWS ElastiCache - Redis`.

**How ?**

- By SG of AWS EKS Nodes.

- AWS ElastiCache - Redis should create in pvt subnet

**What will do for CheckOut ?**

1. Create AWS ElasticCache - Redis Cluster in Pvt Subnet.

2. Create Redis Security Group

3. Create Pvt Subnet Group for Redis just like RDS MySQL.

4. Allow Traffic from source of AWS EKS Node's SG to Redis SG.


![alt text](arch.png)

**Setup required IAM Policy, Roles and Use to PIA Associations**

- We have created all required resources like IAM Policy, IAM Roles, IAM role policy attachment for all services like orders, checkout, cart, catalog.

- This IAM Roles will used to Associate to PIA Assocations to get AWS Resource Access to assume role by Pods via Service Account.

```bash
# Initial Terraform and deploy resources

terraform init
terraform validate
terraform plan
terraform apply
```

- Ensure all resources has created

![alt text](dbs.png)

- DynamoDB Table

![alt text](dndb.png)

- ElastiCache Redis Cluster

![alt text](redisc.png)

- AWS SQS Queue

![alt text](sqsq.png)

