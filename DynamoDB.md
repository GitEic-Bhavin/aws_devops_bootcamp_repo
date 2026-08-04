# AWS DynamoDB — L1 Interview Preparation Guide

This repository contains essential Level 1 (L1) interview questions and answers for **Amazon DynamoDB**, curated from the video tutorial: [Master AWS DynamoDB: 10 Essential Interview Questions](https://www.youtube.com/watch?v=L9kg1SCLCx0).



## 📌 Table of Contents
1. [What is Amazon DynamoDB?](#1-what-is-amazon-dynamodb)
2. [How does DynamoDB ensure High Availability and Fault Tolerance?](#2-how-does-dynamodb-ensure-high-availability-and-fault-tolerance)
3. [What are the key components of DynamoDB?](#3-what-are-the-key-components-of-dynamodb)
4. [What is the difference between a Primary Key and a Secondary Index?](#4-what-is-the-difference-between-a-primary-key-and-a-secondary-index)
5. [How does DynamoDB handle Read and Write Capacity Units (RCU/WCU)?](#5-how-does-dynamodb-handle-read-and-write-capacity-units-rcuwcu)
6. [Can you change Provisioned Throughput settings after table creation?](#6-can-you-change-provisioned-throughput-settings-after-table-creation)
7. [What is the purpose of DynamoDB Streams?](#7-what-is-the-purpose-of-dynamodb-streams)
8. [How does DynamoDB ensure data consistency and durability?](#8-how-does-dynamodb-ensure-data-consistency-and-durability)
9. [What is the difference between On-Demand and Provisioned Capacity modes?](#9-what-is-the-difference-between-on-demand-and-provisioned-capacity-modes)
10. [How can you optimize queries in DynamoDB?](#10-how-can-you-optimize-queries-in-dynamodb)



## 💡 Interview Questions & Answers

### 1. What is Amazon DynamoDB?
**Answer:**
Amazon DynamoDB is a fully managed NoSQL database service provided by AWS [00:01:00].
* **Fully Managed:** You don't need to provision servers or manage underlying infrastructure.
* **Performance & Scale:** Designed for high performance, low latency, and seamless auto-scaling of throughput capacity [00:01:30].



### 2. How does DynamoDB ensure High Availability and Fault Tolerance?
**Answer:**
DynamoDB automatically replicates data across multiple Availability Zones (AZs) within a single AWS Region [00:02:29].
* **Synchronous Replication:** Writes are synchronously replicated across AZs to guarantee durability [00:03:20].
* **Fault Isolation:** If one AZ fails, data remains accessible from other active AZs without downtime [00:03:06].



### 3. What are the key components of DynamoDB?
**Answer:**
The main building blocks of DynamoDB are [00:03:49]:
* **Tables:** Collections of data items (similar to tables in relational databases).
* **Items:** Individual records/rows inside a table.
* **Attributes:** Key-value pairs inside an item (similar to columns/fields).
* **Primary Key:** A mandatory attribute or pair of attributes that uniquely identifies each item [00:04:34].



### 4. What is the difference between a Primary Key and a Secondary Index?
**Answer:**
* **Primary Key:** Uniquely identifies an item in the table. It can be a simple primary key (Partition Key) or a composite primary key (Partition Key + Sort Key) [00:06:29].
* **Secondary Index:** Allows querying data using attributes other than the Primary Key (acting similarly to secondary lookup keys or foreign keys) [00:07:07].



### 5. How does DynamoDB handle Read and Write Capacity Units (RCU/WCU)?
**Answer:**
DynamoDB uses Read Capacity Units (RCU) and Write Capacity Units (WCU) to manage provisioned throughput [00:07:29]:
* **Provisioned Model:** You specify expected read/write throughput based on workload requirements [00:07:55].
* **Scaling:** Capacity can be adjusted up or down dynamically to accommodate varying traffic [00:08:22].



### 6. Can you change Provisioned Throughput settings after table creation?
**Answer:**
**Yes.** You can modify the RCU and WCU settings or enable Auto Scaling for an existing table at any time [00:08:59].
> ⚠️ **Note:** Updating provisioned capacity may take time to apply and can impact billing based on changed units [00:09:14].



### 7. What is the purpose of DynamoDB Streams?
**Answer:**
DynamoDB Streams capture time-ordered sequences of item-level modifications (inserts, updates, deletes) in real-time [00:09:59].
* **Use Cases:** Triggering AWS Lambda functions, updating search indexes (e.g., OpenSearch), or maintaining replica tables in real-time [00:10:20].



### 8. How does DynamoDB ensure data consistency and durability?
**Answer:**
* **Consistency:** Offers Strongly Consistent Reads and Eventually Consistent Reads within a region [00:10:59].
* **Durability:** Achieved by synchronously replicating writes across multiple AZs in the target region before confirming write success [00:11:29].



### 9. What is the difference between On-Demand and Provisioned Capacity modes?
**Answer:**
* **Provisioned Capacity Mode:** You specify RCU and WCU ahead of time. Best for predictable workloads with steady traffic [00:12:07].
* **On-Demand Capacity Mode:** Pay-per-request pricing with no capacity planning required. Ideal for unpredictable or bursty workloads [00:12:48].



### 10. How can you optimize queries in DynamoDB?
**Answer:**
Query optimization strategies include [00:13:12]:
1. **Access Pattern Design:** Design schema and primary keys around specific access patterns.
2. **Secondary Indexes:** Use Global Secondary Indexes (GSIs) or Local Secondary Indexes (LSIs) for efficient querying.
3. **Projection Expressions:** Fetch only necessary attributes rather than whole items to conserve RCU and network bandwidth [00:13:28].