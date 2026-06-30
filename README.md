## Q-1 What is SLO,SLI,SLA ? Clear its concept ?

**SLO** = Service Level Object == Your Target to How much your svc and applications must be available ?

**SLO** == 99.9% - AWS Says, its serivces will must be available 99.9%

If your SLO is below 99.8% or like 99.5% You missed your SLO and SRE will investigate why its happens ? Where we should improve ?

**SLI** = Service Level Indicator == Its just your Actual value of Availability , Its measurement.

How healthy is my service ?

If your Service or Apps SLI is 99.5% and SLO is 99.9%. Your availability has measured 99.5% and You missed SLO.

```
100000 Requests

99800 Success

200 Failed

**SLI**

Availability

99800
  -
100000

=99.8%
```

**SLA** = Service Level Aggrement between the customer and company or cloud provider

- AWS ensure that its service must be available `99.5 %` every time.

- If your Apps has deployed in aws services and if disaster happens or maintenance happens or any down time happens from AWS side, At that time also your serivce must be available `99.5%`.

- If aws fails here, Customer will receives `Credits`, `Refund`, `Compensations`.

**Error Budget** - How much down time should be acceptable ?

If you missed your SLO , so how much down time , how much failure is acceptable ?

`SLO is 99.9%`

100 - 90% = 0.1%

`0.1%` is your `Error Budget`.

# Common Interview Questions

## Q1. What is the difference between SLI and CloudWatch Metrics?

CloudWatch collects raw infrastructure and application metrics.

SLIs are meaningful reliability indicators calculated from those metrics.

Example:

CloudWatch → Request Count & Error Count

↓

SLI → Success Rate

 

## Q2. How do you calculate Availability SLI?

Formula:

```text
Availability

Successful Requests
────────────────────────
Total Requests
```

  

## Q3. Why don't companies define a 100% SLO?

Because it is unrealistic, expensive, and impossible to guarantee in real production environments.

  

## Q4. What happens when the Error Budget is exhausted?

Typical SRE actions:

- Stop risky deployments
- Investigate incidents
- Improve service reliability
- Resolve recurring issues

 

## Q5. How would you build an SLO Dashboard?

Example stack:

```text
Application

↓

OpenTelemetry

↓

CloudWatch Metrics

↓

CloudWatch Dashboard

↓

SRE Team
```

Dashboard should include:

- Availability
- Error Rate
- Request Count
- Latency
- Error Budget Remaining
- Infrastructure Health

 

## Q6. What types of SLIs are commonly used?

- Availability
- Success Rate
- Error Rate
- Latency
- Throughput

 

# Common Interview Mistakes

❌ SLO only means availability.

✔️ SLO can also measure latency, throughput, or error rate.

 

❌ CloudWatch metrics are SLIs.

✔️ CloudWatch provides raw metrics. SLIs are derived from those metrics.

 

❌ SLA and SLO are the same.

✔️ SLA is a legal commitment. SLO is an internal engineering target.

 

❌ Error Budget means downtime only.

✔️ Error Budget represents the allowed amount of failure while still meeting the SLO. It can relate to availability, latency, or other SLOs.

 

# Quick Revision

| Concept | One-Line Definition |
|   -|       -|
| SLI | Actual measured performance of a service |
| SLO | Target reliability or performance objective |
| SLA | Legal agreement with customers |
| Error Budget | Allowed amount of failure before violating the SLO |

 

# Interview Answer

> SLI (Service Level Indicator) is the actual measured performance of a service, such as availability, latency, or success rate, over a defined time period.
>
> SLO (Service Level Objective) is the target value that the engineering or SRE team wants to achieve, for example maintaining 99.9% availability or keeping P95 latency below 200 ms.
>
> SLA (Service Level Agreement) is a legal agreement between the service provider and the customer. If the agreed service level is not achieved, the provider may offer service credits or compensation.
>
> Error Budget is the amount of failure allowed while still meeting the SLO. For example, with a 99.9% monthly availability SLO, the service has a 0.1% error budget, which is approximately 43.2 minutes of downtime in a 30-day month. If the error budget is exhausted, the team typically pauses risky deployments and focuses on improving service reliability.

 

# Final Memory Trick

```text
SLI
↓

Measure

↓

SLO
↓

Target

↓

SLA
↓

Legal Promise

↓

Error Budget
↓

Allowed Failure
```

> **Interview Tip:** Always explain these concepts with a real AWS production example (CloudFront → ALB → ECS Fargate → Aurora PostgreSQL → CloudWatch). This demonstrates practical understanding rather than just theoretical knowledge.


## What is mTLS concept ?

# 🔐 Mutual TLS (mTLS) - CloudOps & SRE Interview Notes

  

# Table of Contents

* What is mTLS?
* Why do we need mTLS?
* One-Way TLS vs mTLS
* How mTLS Works
* Production AWS Example
* Where is mTLS Used?
* AWS Services Using mTLS
* mTLS vs HTTPS
* Advantages
* Limitations
* Interview Questions & Answers
* Quick Revision
* Memory Trick

  

# What is mTLS?

**mTLS (Mutual Transport Layer Security)** is an extension of TLS where **both the client and the server authenticate each other using X.509 certificates before exchanging data.**

Unlike normal HTTPS, where only the **server proves its identity**, mTLS requires **both parties** to prove their identities.

  

# Why do we need mTLS?

HTTPS protects communication by:

* Encrypting traffic
* Verifying the server's identity

However, the server still doesn't know whether the connecting client is actually trusted.

Example:

```text
Payment API

https://payment.company.com
```

Anyone with network access could attempt to connect. They may still need credentials, but the TLS connection itself does not verify the client's identity.

With **mTLS**, the server requires a trusted **client certificate** before allowing the connection.

  

# One-Way TLS vs mTLS

| Feature               | HTTPS (TLS) | mTLS        |
|                |       -- |       -- |
| Server Certificate    | ✅           | ✅           |
| Client Certificate    | ❌           | ✅           |
| Server Authentication | ✅           | ✅           |
| Client Authentication | ❌           | ✅           |
| Data Encryption       | ✅           | ✅           |
| Browser Websites      | ✅           | Rare        |
| Microservices         | Optional    | Common      |
| AWS IoT               | Rare        | Very Common |

  

# How mTLS Works

## Normal TLS

```text
Client
   │
   │ Hello
   ▼
Server
   │
   │ Sends Server Certificate
   ▼
Client verifies certificate
   │
   ▼
Encrypted communication starts
```

  

## Mutual TLS (mTLS)

```text
Client
   │
   │ Hello
   ▼
Server
   │
   │ Sends Server Certificate
   ▼
Client verifies Server Certificate
   │
   ▼
Server requests Client Certificate
   │
   ▼
Client sends Client Certificate
   │
   ▼
Server verifies Client Certificate
   │
   ▼
Secure communication begins
```

**Additional Step:** Client authentication.

  

# Production AWS Example

Architecture

```text
               Users
                 │
           CloudFront
                 │
                ALB
                 │
          ECS Service A
                 │
         (mTLS Connection)
                 │
          ECS Service B
                 │
        Aurora PostgreSQL
```

Flow

1. Service A sends a request.
2. Service B presents its certificate.
3. Service A verifies the server certificate.
4. Service B requests Service A's certificate.
5. Service A sends its client certificate.
6. Service B verifies it.
7. Secure communication starts.

  

# AWS IoT Example

```text
IoT Device
      │
Client Certificate
      │
AWS IoT Core
```

AWS IoT Core verifies the device certificate before allowing it to connect.

Without a valid certificate:

```text
Connection Rejected
```

  

# Where is mTLS Used?

Common production use cases:

* Microservice-to-Microservice Communication
* AWS IoT Core
* Banking APIs
* Healthcare Systems
* Internal Enterprise APIs
* B2B Partner Integrations
* Zero Trust Networks
* Service Meshes (Istio, Linkerd, etc.)

  

# AWS Services Related to mTLS

| AWS Service               | Usage                                                        |
|                 - |                                          |
| AWS IoT Core              | Device Authentication                                        |
| Application Load Balancer | Client Certificate Authentication (supported configurations) |
| API Gateway               | Client Certificate Authentication (supported scenarios)      |
| AWS Private CA            | Issue Private Client Certificates                            |
| Amazon ECS / EKS          | Internal Service-to-Service Communication                    |
| CloudFront                | Server-side TLS only (not typical client mTLS termination)   |

  

# Where are Certificates Stored?

## Server Side

Examples:

* AWS Certificate Manager (ACM)
* Application Load Balancer
* CloudFront
* API Gateway

  

## Client Side

Examples:

* IoT Devices
* Applications
* Containers
* Virtual Machines
* Mobile Applications

  

# mTLS vs HTTPS

| HTTPS                          | mTLS                                                     |
|                      |                                     -- |
| Only server is authenticated   | Both client and server are authenticated                 |
| Suitable for public websites   | Suitable for internal secure systems                     |
| Browser is the client          | Machines or trusted applications are usually the clients |
| No client certificate required | Client certificate is mandatory                          |

  

# Advantages

* Strong client authentication
* Strong server authentication
* Encrypted communication
* Prevents unauthorized clients from connecting
* Ideal for Zero Trust architectures
* Reduces impersonation risk
* Widely used for machine-to-machine communication

  

# Limitations

* Certificate lifecycle management
* Certificate renewal complexity
* Certificate distribution challenges
* Increased operational overhead
* Requires a Certificate Authority (CA)
* More complex than standard HTTPS

  

# Interview Questions & Answers

## Q1. What is mTLS?

**Answer**

mTLS (Mutual TLS) is a security protocol where both the client and the server authenticate each other using digital certificates before establishing an encrypted communication channel.

  

## Q2. Why do we need mTLS if HTTPS already encrypts traffic?

**Answer**

HTTPS encrypts traffic and authenticates the server only.

mTLS adds client authentication, ensuring that only trusted clients can communicate with the server.

  

## Q3. Does mTLS provide stronger encryption than HTTPS?

**Answer**

No.

Both use the same TLS encryption.

The difference is that mTLS adds **mutual authentication**, not stronger encryption.

  

## Q4. Where is mTLS commonly used?

**Answer**

* AWS IoT Core
* Microservices
* Banking APIs
* Healthcare Systems
* Enterprise Internal APIs
* Service Meshes

  

## Q5. Can JWT replace mTLS?

**Answer**

No.

JWT is used at the application layer for authentication and authorization after the secure connection is established.

mTLS authenticates both parties during the TLS handshake.

Many production systems use both together.

  

## Q6. What happens if the client certificate is invalid?

**Answer**

The server rejects the TLS handshake, and the secure connection is never established.

  

## Q7. Is a browser required to have a client certificate for normal HTTPS?

**Answer**

No.

Browsers normally verify only the server certificate.

Client certificates are required only when the server is configured for mTLS.

  

## Q8. What problem does mTLS solve?

**Answer**

It prevents unauthorized clients from communicating with a server by requiring both sides to prove their identities using certificates.

  

# Interview Answer

> **Mutual TLS (mTLS)** is an extension of TLS in which both the client and the server authenticate each other using digital certificates before establishing an encrypted connection. In standard HTTPS, only the server presents a certificate and proves its identity, while the client is typically authenticated later using credentials or tokens. With mTLS, the client must also present a valid certificate, allowing the server to verify that it is communicating with a trusted client. This makes mTLS ideal for machine-to-machine communication, such as microservices, AWS IoT Core devices, banking systems, healthcare applications, and other enterprise environments where strong identity verification is required.


## SSL Cert Authentication Handshake works

Your domain is xyz.mycompany.com

You created SSL Certificate using ACM and used by ALB or CloudFront.

While User hits your domain from his any of browsers, The flow will like this.

```
User
 |
 |
Browser already has installed Root CA
 |
 |
Intermediate CA - *-ca-chain.pem provided by servers. - Founded at your browser
 | 
 |
Server's SSL Cert - *.cert - Amazon_Root_CA_1.pem - /etc/ssl/certs/
```

If all this checks passed , your HTTPS will establish.

# Certificate Revocation — Interview Prep (CRL, OCSP, OCSP Stapling)

Part of the SSL/TLS interview series. Builds on: TLS handshake → certificate chain (root/intermediate CA) → **this topic**.

## Why this exists

A certificate can be technically valid (not expired, correctly signed, domain matches) and still be untrustworthy — for example, if its private key was stolen. Revocation is how a CA invalidates a certificate before its expiry date.

## Core concepts

### Certificate Revocation
A CA marks a certificate as invalid before its expiration date. Common triggers:
- Private key compromised
- Organization or domain ownership changed
- Certificate issued by mistake
- Weak/compromised cryptographic keys
- CA policy violation

### CRL (Certificate Revocation List)
A blacklist of revoked certificate serial numbers, published by the CA. The client downloads the full list and checks if the cert's serial number is in it.

- Pros: simple
- Cons: list can grow huge (millions of entries) for large CAs, slow to download/search, updated only periodically — not real-time

### OCSP (Online Certificate Status Protocol)
The client queries the CA's OCSP responder about a single certificate, instead of downloading the whole list. Response is one of: `Good`, `Revoked`, `Unknown`.

- Pros: smaller request, faster, near real-time
- Cons: adds an extra network round-trip on every connection, depends on OCSP server uptime, and leaks browsing activity to the CA (privacy issue)

### OCSP Stapling
The server — not the browser — periodically fetches a signed OCSP response from the CA and attaches ("staples") it to the TLS handshake.

- Removes the browser's separate OCSP round-trip → faster handshake
- Better privacy (CA doesn't see which sites users are visiting in real time)
- Reduces load on the OCSP responder

## Comparison table

| | CRL | OCSP | OCSP Stapling |
|---|---|---|---|
| What's checked | Full revoked list | Single certificate | Single certificate |
| Who asks | Browser downloads list | Browser queries CA | Server queries CA, browser gets it for free |
| Size/speed | Large, slow | Small, fast | Fastest (no extra browser round-trip) |
| Freshness | Periodic | Near real-time | Near real-time (cached + signed by CA) |
| Privacy | N/A | CA sees client's lookups | CA doesn't see per-client lookups |

## How it fits AWS

- **Public ACM certificates**: AWS/the issuing public CA manages revocation lifecycle; you don't configure CRL/OCSP yourself.
- **AWS Private CA**: if you run your own PKI, you're responsible for revocation — publishing CRLs and/or configuring OCSP depending on your design.
- **mTLS between services**: if a service's client certificate is stolen, revoking it means the next connection attempt is checked and rejected by the peer — this is what stops a compromised client from continuing to authenticate.

## Mental model / flow

```
Certificate issued → used → private key stolen?
   → yes → CA revokes certificate
        → CRL (download list) or OCSP (ask CA directly)
   → browser learns cert is revoked → connection blocked
```

This completes the SSL/TLS lifecycle covered so far:
`TLS handshake → server certificate → certificate chain → root CA → intermediate CA → revocation (CRL/OCSP)`

## Interview Q&A (rapid recall)

**Q: Why do we need certificate revocation if certificates already expire?**
A: Expiry is a fixed future date; revocation handles certificates that become untrustworthy *before* that date (e.g. key compromise) — you can't wait months for natural expiry.

**Q: What is a CRL?**
A: A CA-published list of revoked certificate serial numbers that clients download and check against.

**Q: What is OCSP?**
A: A protocol for asking the CA (or its OCSP responder) the real-time status of one specific certificate — Good, Revoked, or Unknown.

**Q: What is OCSP Stapling and why does it matter?**
A: The server fetches and caches a signed OCSP response from the CA, then includes it directly in the TLS handshake — removing the browser's separate OCSP call, which improves latency, privacy, and reduces load on the OCSP responder.

**Q: CRL vs OCSP — give the one-line distinction.**
A: CRL = full list, downloaded periodically. OCSP = single-certificate query, near real-time.

## Common mistakes to avoid saying

- "Certificates only become invalid at expiry." → Wrong, they can be revoked early.
- "CRL and OCSP are the same thing." → Wrong, CRL is a list; OCSP is a per-certificate query.
- "OCSP Stapling is an encryption method." → Wrong, it's a performance/privacy optimization for status checking, not encryption.

## Next topic in the series

**AWS Private Certificate Authority (Private CA)** — issuing and managing internal certificates for mTLS, internal services, and enterprise PKI.


# Demo - Private CA to revolke pvt certificates

## 1. Go to Private CA - Create Root Private CA

![alt text](rpca.png)

## 2. Create Subordinate Private CA

- Choose CA type - `Subordinate`.

- Fill Configurations

- Organizations Unit, Country, State, Command Name of CA - `Subordinate CA 1`.

![alt text](fc.png)

## 3. Trun on Certificate Revocations options

- Choose OCSP - Its not install whole list of ca in your local or browser. User send request to this OCSP server, this server will look for that domains ca, if its good or bad, user will access or declined to your apps.

![alt text](cr.png)

## 4. Installing CA Certificate to your Root CA

![alt text](icatr.png)

- 4.1 Add Subordinary CA to your Root CA

- 4.2 Set validatoins date.

## 5. Issuing a Certificate to the Load Balancer

- LB will required Certificate issued from ACM.

- Go to ACM > Request a `Private Certificate`

- Choose your Private CA common name here `Subordinary CA 1`.

- Choose your domain name.

- Go to LB

- Choose Listener Settings > Default SSL/TLS Certificate > Choose your Private ACM.

![alt text](pacm.png)

## Revokations of your Private CA

```bash
aws acm-pca revoke-certificate --certificate-authority-arn <Your_ACM_Private_CA_ARNs> --certificate-serial <Your_ACM_Cert_Sr_Number> --revocation-reason <Enter reasons>