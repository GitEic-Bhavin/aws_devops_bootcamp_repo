Terraform - The way of managing and provisioning Infrastructure
---

**Terraform Commands**

1. Initialize Terraform configurations files in the working dir.

```bash
terraform init
```

- **Install Provider Plugins** 
    
  - It will install required providers from looing into provider.tf. It will create **.terraform** dir where your required providers plugin will downloads.

- **Create .terraform.lock.hcl**

  - It will create **.terraform.lock.hcl** file where your providers versions will defined and used to ensure consistency across diff envs.

- **Initialize the Backend**

  - It will initialize terraform backend to store your state file locally or remote based on defined backedin in `terraform backend` block.

**Important Init Commands**

  - **-upgrade** - use to switch / modify provider plugin and its verions.

  - **reconfigure** - Reinitialize backend configurations to use new one backend configurations instead of existing.


- 2. Plan of resource provisions

```bash
terraform plan
```

- It will give the whole plan of terraform executions to provisions, delete, update resources.

- 3. validate configurations and syntax

```bash
terraform validate
```

- This will validate your terraform resource block arguments and its syntax before failing any of execution during plan and apply.

- 4. Authenticate and provision plans

```bash
terraform apply
```

- 5. Destroy terraform managed resources

```bash
terraform destroy
```

- 6. List all defined output block for resource attributes.

```bash
terraform output
```

- 7. Create terraform plan files

```bash
terraform plan -out=<file_name>

terraform plan -out=s3planv1
```

- 8. Create plan files for destroy

```bash
terraform plan -destroy -out=s3destroy
```

- This will use by CI/CD Automations tools to review, approve by user.

- This will `never execute terraform plan and not require to wait for plans`

- This will `reduce terraform executions times`.

- 9. Destory resources by using this `s3destroy`

```bash
terraform apply "s3destroy"
```

- Here, `terraform destory "s3destroy" will not work.

- 10. Show state file

```bash
terraform show
```

- 11. Show s3destroy or s3plan files

```bash
terraform show s3destroy
```

- 12. Create and show plan in jsons

```bash
terraform show -json s3destroy | jq > s3destroy.json
```

- 13. Destroy

```bash
terraform apply --destory
```

## Data Source

- To fetch existing resource into terraform which is not managed by terraform or created manually.

```bash
data "aws_availability_zones" "available" {
    state = "available"
}
```

- `available` is a argument we are passing and its shows only availabe availability zones.

- For instance, there are 10 azs, but 2 are downs for aws maintenance. So only 8 azs are availalbe. So only 8 azs will be shows.


## Locals Block

- Local block is used to Assign name to the Expressions, which letting you use this local name multiple times without repeating that expressions.

- This will reduce human typo error by reusability.

- Define Local values by `locals` block.

```bash
locals {
  # Naming convention
  resource_name = "${var.project_name}-${var.environment}"

  # Process the subnet list # Functions Use
  primary_public_subnet = var.subnet_ids[0]
  subnet_count          = length(var.subnet_ids)

  # Environmental deployment settings # Resource Attributes
  is_production      = var.environment == "prod"
  monitoring_enabled = var.monitoring || local.is_production
}
```

- Access or Give Reference to use this Locals value in your resource block by using `local`.

```bash
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = local.primary_public_subnet
  monitoring    = local.monitoring_enabled

  tags = {
    Name        = local.resource_name
    Environment = var.environment
  }
}

resource "aws_security_group" "web" {
  name = "${local.resource_name}-sg"

  tags = {
    Name = "${local.resource_name}-security-group"
  }
}
```


## Functions

### 1. Slice Functions

```bash
slice(list, startindex, endindex)

slice(["a", "b", "c", "d"], 1, 3)
# Ans is - "b", "c"
```

- login to terraoform console

```bash
terraform console

slice(["a", "b", "c", "d"], 1, 3)
```

![alt text](slice.png)

- Let's create locals block and try to list first 3 available azs.

```bash
# Use Locals to define the expressions for reusability

data "aws_availability_zones" "available" {
    state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

output  "az_name" {
  value = local.azs
}
```

- Plan it

![alt text](locals.png)

### 2. cidrsubnets Functions

- cidrsubnets calculates a sequence of consecutive IP address ranges within a particular CIDR prefix.

```bash
cidrsubnets(prefix, newbits...)
```

- `prefix` must be given in CIDR notations `/24`.

- `newbits`  specify the number of additional network prefix bits for one returned address range.

![alt text](cidrs.png)

