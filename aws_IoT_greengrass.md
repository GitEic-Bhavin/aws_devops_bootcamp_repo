# AWS IoT Greengrass V2 - Core Concepts

- AWS IoT Greengrass is a tool from Amazon that helps you run software directly on "edge devices" (like a smart camera, a factory sensor, or a mini-computer like a Raspberry Pi) rather than running everything up in the cloud. 



## 🏗️ Main Concepts

### 1. Greengrass Core Device
This is your physical hardware (the device on your desk or in a factory) that has the Greengrass software installed on it. Once installed, AWS treats this device as an "IoT Thing" that it can talk to and manage.

### 2. Components
Think of components as the Lego blocks of your software. Instead of writing one massive, messy program, you break your code into smaller, reusable pieces.

*   **The Nucleus:** This is the most important component. It is the mandatory "brain" or engine that manages all the other Lego blocks, handles updates, and lets components talk to each other locally.
*   **Optional/Pre-built Components:** Ready-made blocks provided by AWS so you don't have to write code from scratch (e.g., blocks for streaming data or running a machine learning model).
*   **Custom Components:** Blocks you build yourself using your own code, Docker containers, or Lambda functions.

### 3. Recipes and Artifacts
To make a component, you need two things:
*   **Recipe:** A simple text file (JSON or YAML configuration) that explains what the component is, what it needs to run, and how it should behave.
*   **Artifact:** The actual muscle—the code, script, or binary file that does the real work.

### 4. Dependencies

- This is how components rely on each other. 
- If Component A (like a data processor) needs Component B (an encryption tool) to work, Greengrass links them. 
- If you update the encryption tool, Greengrass automatically restarts the data processor so everything keeps working smoothly.

### 5. Deployment

- This is the process of pushing your components and configurations from the AWS cloud down to your physical devices. 
- If you have 100 devices in the field, you can deploy your software to all of them at once through the AWS console.



## 💡 Why Use It?

- It allows your devices to make decisions locally and instantly without waiting for a round-trip internet connection to the cloud, and it keeps them running even if the internet goes down temporarily.

## 🛠️ Workshop Project: What You Are Going to Build (1.1)

Here is exactly what you will do step-by-step:

1. **Install the Core Engine:** You will download and set up the main AWS IoT Greengrass software onto your virtual machine so it can act as the "brain."
2. **Build Local Communicators:** You will create two custom, small blocks of software that talk directly to each other on the device without needing the internet.
   * **The Publisher:** A software block that sends out data.
   * **The Subscriber:** A software block that listens for and catches that data.
3. **Bridge to the Cloud:** You will set up an "MQTT bridge." This acts like a data highway that lets your local device easily pass its messages up to the AWS Cloud when it needs to.

![alt text](diag.png)

### 2.3 Greengrass Service Role

- To allow the Greengrass cloud service to securely verify your local devices and manage their connection info, you have to assign it an ID badge called a **Service Role**. 

- In this step, you install a utility command (`jq`) in your terminal and run the provided AWS scripts to automatically create and link this permission role to your account.

- 1. Install jq

```bash
sudo apt install -y jq
```

- 2. Create GreenGrass service role

```bash
aws iam create-role --role-name Greengrass_ServiceRole --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "greengrass.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "arn:aws:greengrass:region:account-id:*"
        },
        "StringEquals": {
          "aws:SourceAccount": "account-id"
        }
      }
    }
  ]
}'
```

- 3. Associate the service role with the AWS IoT Greengrass service in your account and region.

```bash
ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')
ROLE_ARN=$(aws iam get-role --role-name Greengrass_ServiceRole | jq -r '.Role.Arn')
aws greengrassv2 associate-service-role-to-account --role-arn $ROLE_ARN --region $AWS_DEFAULT_REGION
```

### 3.1 Greengrass Setup (How to Install the Core Engine)
To turn your Linux machine (the client EC2 / VS Code Server environment) into a Greengrass device, follow these exact steps:

1. **Go to the AWS Console:** Open the AWS IoT Core console in your browser and make sure your top-right Region matches your project area.
2. **Find the Menu:** On the left side menu, click on **Greengrass devices** and then choose **Core devices**.
3. **Start the Setup:** Click the button that says **Set up core device** (or **Set up one core device**).
4. **Name Your Device:** Give your device a name and a group name (or keep the default names AWS gives you).

![alt text](nd.png)


5. **Pick the OS & Software:** Choose **Linux** as your platform and choose **Nucleus Classic** as your software type.

![alt text](poss.png)

6. **Copy the Magic Command:** AWS will instantly show you a long text command on the screen. Click the copy button next to it.

![alt text](rinstaller.png)


7. **Run the Installer:** Open your VS Code terminal (your local/client EC2 environment), paste that command, and hit **Enter**.

**What happens next?** The script automatically downloads the software, creates security certificates so your device can safely talk to the cloud, installs the main **Nucleus** brain, and marks it as active!

- To check status of greengrass service

```bash
sudo systemctl status greengrass.service
```

- To start greengrass service

```bash
sudo systemctl enable greengrass.service
```

### 3.2 Core Device Role (Device Permissions)

- To allow your physical/virtual device to talk back to AWS Cloud services securely, it needs an IAM permission pass called a **Core Device Role**. 

*   **What it does:** It gives the device permission to upload local logs to AWS CloudWatch and pull required software deployment files down from Amazon S3 buckets.

*   **Workshop Note:** These IAM policies and roles have already been pre-built for your lab environment, meaning you don't need to manually configure them during this step.

* IAM Roles for core devices to perform action like send logs to S3 Bucket, access IoT Services etc

```json
# Create Policy workshop_s3_iot_gg_policy

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3BucketActions",
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:GetBucketLocation",
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::ggcv2-workshop-*",
                "arn:aws:s3:::ggcv2-workshop-*/*"
            ]
        },
        {
            "Sid": "S3ListBuckets",
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets"
            ],
            "Resource": "*"
        },
        {
            "Sid": "IoTActions",
            "Effect": "Allow",
            "Action": [
                "iot:*"
            ],
            "Resource": "arn:aws:iot:*:*:*"
        },
        {
            "Sid": "GreengrassActions",
            "Effect": "Allow",
            "Action": [
                "greengrass:*"
            ],
            "Resource": "arn:aws:greengrass:*:*:*"
        }
    ]
}
```