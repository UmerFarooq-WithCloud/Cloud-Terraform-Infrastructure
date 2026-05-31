# AWS Bastion EC2 + ALB + ACM + Route53 — Terraform Infrastructure

A Terraform project that provisions a complete, production-ready AWS infrastructure including a custom VPC, Bastion host, two private application tiers (App1 & App2), an Application Load Balancer with HTTPS, ACM SSL certificate with DNS validation, and Route53 integration.

---

## Architecture Overview

![AWS Infrastructure](1_project%20infrastructure.png)

> **AWS VPC + Bastion EC2 + ALB + ACM + Route53**
>
> The diagram above shows the full infrastructure layout across two Availability Zones inside a single VPC with HTTPS-terminated load balancing.

### Terraform & AWS Concepts Used

| Concept | Purpose |
|---|---|
| **Terraform Module: VPC** | Creates the VPC, subnets, route tables, NAT & Internet Gateway |
| **Terraform Module: Security Group** | Manages inbound/outbound rules for Bastion, private instances, and ALB |
| **Terraform Module: EC2 Instance** | Provisions Bastion, App1, and App2 EC2 instances |
| **Terraform Module: ALB** | Application Load Balancer with HTTP→HTTPS redirect and path-based routing |
| **Terraform Module: ACM** | SSL/TLS certificate with automatic DNS validation via Route53 |
| **Data Source: Route53** | Fetches existing hosted zone for `devsecflow.me` |
| **Meta-Argument: `depends_on`** | Ensures private instances wait for VPC to be fully ready |
| **Meta-Argument: `for_each`** | Deploys multiple EC2 instances across subnets dynamically |
| **`aws_lb_target_group_attachment`** | Manually attaches EC2 instances to ALB target groups |
| **Terraform `null_resource`** | Triggers provisioners without creating a real AWS resource |
| **Terraform File Provisioner** | Copies the `.pem` key to the Bastion host |
| **Terraform Remote-exec Provisioner** | Sets key permissions on the remote Bastion EC2 instance |
| **Terraform Local-exec Provisioner** | Logs VPC creation details locally |

---

### Traffic Flow

```
Internet (HTTPS :443 / HTTP :80)
        │
        ▼
┌─────────────────────────────────────────────────────────────┐
│                        AWS Cloud                             │
│                                                              │
│   Route53 (devsecflow.me)  ──►  ACM Certificate (*.devsecflow.me)
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                        VPC (10.0.0.0/16)              │  │
│  │                                                       │  │
│  │   ┌─────────────────────────────────────────────┐    │  │
│  │   │         Public Subnets (AZ1 & AZ2)          │    │  │
│  │   │                                             │    │  │
│  │   │  ┌──────────────┐    ┌───────────────────┐  │    │  │
│  │   │  │  ALB (HTTPS) │    │  Bastion EC2      │  │    │  │
│  │   │  │  SG: 80, 443 │    │  + Elastic IP     │  │    │  │
│  │   │  │  from 0.0.0.0│    │  SG: port 22      │  │    │  │
│  │   │  └──────┬───────┘    └────────┬──────────┘  │    │  │
│  │   └─────────┼────────────────────┼─────────────┘    │  │
│  │             │  Path-based Routing │ SSH Jump          │  │
│  │    /app1*   │                     │                   │  │
│  │    /app2*   │                     │                   │  │
│  │   ┌─────────▼─────────────────────▼───────────────┐  │  │
│  │   │         Private Subnets (AZ1 & AZ2)           │  │  │
│  │   │                                               │  │  │
│  │   │  ┌──────────────┐    ┌──────────────────┐    │  │  │
│  │   │  │  App1 EC2 x2 │    │  App2 EC2 x2     │    │  │  │
│  │   │  │  /app1/*     │    │  /app2/*         │    │  │  │
│  │   │  │  Port 80     │    │  Port 80         │    │  │  │
│  │   │  └──────────────┘    └──────────────────┘    │  │  │
│  │   │                                               │  │  │
│  │   │  ┌──────────────────────────────────────┐    │  │  │
│  │   │  │   Database Subnets (reserved)        │    │  │  │
│  │   │  └──────────────────────────────────────┘    │  │  │
│  │   └───────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

### Key Security Rules

| Instance | Security Group Rule | Source |
|---|---|---|
| ALB | HTTP port `80` inbound | `0.0.0.0/0` (internet) |
| ALB | HTTPS port `443` inbound | `0.0.0.0/0` (internet) |
| ALB | Custom port `81` inbound | `0.0.0.0/0` (internet) |
| ALB | All outbound | anywhere |
| Bastion (Public) | SSH port `22` inbound | `0.0.0.0/0` (internet) |
| Bastion (Public) | All outbound | anywhere |
| Private EC2 (App1 & App2) | SSH port `22` inbound | `10.0.0.0/16` (VPC only) |
| Private EC2 (App1 & App2) | HTTP port `80` inbound | `10.0.0.0/16` (VPC only) |
| Private EC2 (App1 & App2) | All outbound | anywhere (via NAT) |

---

## What Gets Created

| Resource | Details |
|---|---|
| **VPC** | CIDR `10.0.0.0/16`, DNS hostnames & support enabled |
| **Public Subnets** | 3 subnets across `us-east-1a`, `us-east-1b`, `us-east-1d` |
| **Private Subnets** | 3 subnets across the same AZs |
| **Database Subnets** | 3 subnets with dedicated subnet group and route table |
| **NAT Gateway** | Single NAT gateway for private subnet outbound traffic |
| **Internet Gateway** | Attached to VPC for public subnet internet access |
| **ALB Security Group** | Allows HTTP `80`, HTTPS `443`, custom `81` from internet |
| **Public Security Group** | Allows inbound SSH (`22`) from anywhere, all outbound |
| **Private Security Group** | Allows inbound SSH (`22`) and HTTP (`80`) from VPC only |
| **Bastion EC2 Instance** | Amazon Linux 2, `t2.micro`, placed in public subnet |
| **App1 EC2 Instances** | 2× Amazon Linux 2, `t2.micro`, one per private subnet, serves `/app1/*` |
| **App2 EC2 Instances** | 2× Amazon Linux 2, `t2.micro`, one per private subnet, serves `/app2/*` |
| **Elastic IP** | Static public IP attached to the Bastion EC2 instance |
| **Application Load Balancer** | Internet-facing ALB with HTTP→HTTPS redirect and path-based routing |
| **ALB Listener (HTTP :80)** | Redirects all traffic to HTTPS `301` |
| **ALB Listener (HTTPS :443)** | Terminates SSL, routes `/app1*` → TG1, `/app2*` → TG2 |
| **Target Group 1 (mytg1)** | Health check on `/app1/index.html`, attached to App1 instances |
| **Target Group 2 (mytg2)** | Health check on `/app2/index.html`, attached to App2 instances |
| **ACM Certificate** | SSL cert for `devsecflow.me` + `*.devsecflow.me`, DNS validated |
| **Route53 Data Source** | Fetches hosted zone for `devsecflow.me` to validate ACM cert |

---

## Project Structure

```
.
├── a1_version.tf               # Terraform & provider version constraints
├── a2_variable.tf              # Global variables (region, environment, business division)
├── a2_local_var.tf             # Local values and common tags
├── a3_1_vpc_var.tf             # VPC-specific variables (CIDR, subnets, AZs)
├── a3_2_vpc_module.tf          # VPC module configuration
├── a3_3_vpc_output.tf          # VPC outputs
├── a4_1_Pub_SG.tf              # Public (Bastion) security group
├── a4_2_Priv_SG.tf             # Private (App) security group
├── a4_3_output_SG.tf           # Security group outputs
├── a4_4_ALb_SG.tf              # ALB security group (HTTP 80, HTTPS 443, port 81)
├── a5_2_ec2_var.tf             # EC2 variables (instance type, count, key pair)
├── a5_3_ec2_public.tf          # Bastion EC2 instance (public subnet)
├── a5_4_ec2_private_app1.tf    # App1 EC2 instances x2 (private subnets, for_each)
├── a5_5_ec2_private_app2.tf    # App2 EC2 instances x2 (private subnets, for_each)
├── a5_6_ec2_output.tf          # EC2 outputs (IDs and IPs for all instances)
├── a5_6_elasticIP.tf           # Elastic IP attached to Bastion
├── a6_1_datasource_ami.tf      # Data source: latest Amazon Linux 2 AMI
├── a6_2_data_route53.tf        # Data source: Route53 hosted zone for devsecflow.me
├── a7_provisioner.tf           # File, remote-exec, and local-exec provisioners
├── a8_1_ALb.tf                 # ALB module + target group attachments
├── a8_4_Alb_output.tf          # ALB outputs (ARN, DNS name, zone ID, listeners, TGs)
├── a9_1_acm.tf                 # ACM certificate with DNS validation
├── app1.sh                     # User data: installs Apache + App1 content on App1 instances
├── app2.sh                     # User data: installs Apache + App2 content on App2 instances
├── ec2_inst.auto.tfvars        # Auto-loaded variable values
└── private_key/
    └── titan_attack.pem        # SSH key pair (not committed to version control)
```

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- AWS CLI configured with appropriate credentials (`aws configure`)
- An existing EC2 key pair named `titan_attack` in your AWS account
- The private key file placed at `private_key/titan_attack.pem`
- An existing Route53 hosted zone for `devsecflow.me` in your AWS account

---

## Providers & Modules Used

| Name | Source | Version |
|---|---|---|
| `hashicorp/aws` | registry.terraform.io | `6.46.0` |
| `hashicorp/null` | registry.terraform.io | `~> 3.2` |
| `terraform-aws-modules/vpc/aws` | registry.terraform.io | `6.6.1` |
| `terraform-aws-modules/security-group/aws` | registry.terraform.io | `5.3.1` |
| `terraform-aws-modules/ec2-instance/aws` | registry.terraform.io | latest |
| `terraform-aws-modules/alb/aws` | registry.terraform.io | `9.2.0` |
| `terraform-aws-modules/acm/aws` | registry.terraform.io | `6.3.0` |

---

## Usage

**1. Clone the repository**
```bash
git clone https://github.com/UmerFarooq-WithCloud/Cloud-Terraform-Infrastructure.git
cd terraform-aws-bastion-ec2
```

**2. Add your private key**
```bash
mkdir private_key
cp /path/to/titan_attack.pem private_key/titan_attack.pem
```

**3. Initialize Terraform**
```bash
terraform init
```

**4. Review the plan**
```bash
terraform plan
```

**5. Apply the infrastructure**
```bash
terraform apply
```

**6. Access your applications**

After apply, use the ALB DNS name from outputs:
- `https://devsecflow.me/app1/index.html` → App1 instances
- `https://devsecflow.me/app2/index.html` → App2 instances

**7. Destroy when done**
```bash
terraform destroy
```

---

## Variables

| Variable | Default | Description |
|---|---|---|
| `region` | `us-east-1` | AWS region to deploy into |
| `envoirment` | `DEvelop` | Deployment environment label |
| `busniess_division` | `SAP` | Business division tag |
| `vpc_name` | `Day_2_vpc` | Name tag for the VPC |
| `Cidr_block` | `10.0.0.0/16` | VPC CIDR block |
| `instance_type` | `t2.micro` | EC2 instance type for all instances |
| `private_instance_count` | `2` | Number of private EC2 instances per app |
| `key_pair` | `titan_attack` | Name of the EC2 key pair |

---

## Outputs

### VPC
| Output | Description |
|---|---|
| `vpc_id` | ID of the created VPC |
| `vpc_cidr_block` | CIDR block of the VPC |
| `public_subnets` | List of public subnet IDs |
| `private_subnets` | List of private subnet IDs |

### Security Groups
| Output | Description |
|---|---|
| `public_sg_group_id` | Security group ID for the Bastion instance |
| `private_sg_group_id` | Security group ID for the private App instances |

### EC2 Instances
| Output | Description |
|---|---|
| `public_instance_id` | ID of the Bastion EC2 instance |
| `public_instance_ip` | Public IP of the Bastion EC2 instance |
| `private_instance_id_for_app1` | List of App1 EC2 instance IDs |
| `private_instance_id_for_app2` | List of App2 EC2 instance IDs |
| `ec2_private_ip_app1` | List of private IPs for App1 instances |
| `ec2_private_ip_app2` | List of private IPs for App2 instances |

### ALB
| Output | Description |
|---|---|
| `id` | ID and ARN of the load balancer |
| `arn` | ARN of the load balancer |
| `arn_suffix` | ARN suffix (useful for CloudWatch metrics) |
| `dns_name` | DNS name of the load balancer |
| `zone_id` | Zone ID of the ALB (for Route53 alias records) |
| `listeners` | Map of listeners and their attributes (sensitive) |
| `listener_rules` | Map of listener rules and their attributes (sensitive) |
| `target_groups` | Map of target groups and their attributes |

### ACM & Route53
| Output | Description |
|---|---|
| `acm_certificate_arn` | ARN of the issued ACM certificate |
| `validation_route53_record_fqdns` | FQDNs of the DNS validation records |
| `hosted_zone_id` | ID of the Route53 hosted zone |
| `hosted_zone_name` | Name of the Route53 hosted zone |

---

## ALB Routing Rules

| Path Pattern | Target Group | Backend Instances |
|---|---|---|
| `/app1*` | `mytg1` | App1 EC2 x2 (weighted, sticky sessions 1hr) |
| `/app2*` | `mytg2` | App2 EC2 x2 (weighted, sticky sessions 1hr) |
| `/` (root) | Fixed Response | Returns `200` with static message |

HTTP port `80` traffic is automatically redirected to HTTPS `443` via a `301` redirect listener.

---

## Provisioners

The `null_resource` in `a7_provisioner.tf` does three things after the Bastion instance is ready:

1. **`file` provisioner** — Copies `titan_attack.pem` to `/tmp/` on the Bastion host so you can SSH-hop into private App instances.
2. **`remote-exec` provisioner** — Sets correct permissions (`chmod 400`) on the copied key.
3. **`local-exec` provisioner** — Logs the VPC creation time and VPC ID to `record_provider_data/created_time_vpc_id.txt`.

---

## User Data Scripts

| Script | Installed On | Content Served |
|---|---|---|
| `app1.sh` | App1 EC2 instances | Apache HTTPD + `/app1/index.html` (pink background) + EC2 metadata |
| `app2.sh` | App2 EC2 instances | Apache HTTPD + `/app2/index.html` (teal background) + EC2 metadata |

Both scripts use IMDSv2 (token-based metadata) to fetch instance identity documents.

---

## Security Notes

- The `private_key/` directory is in `.gitignore` — never commit `.pem` files.
- The Bastion security group allows SSH from `0.0.0.0/0`. For production, restrict this to your own IP.
- Private App instances are only reachable from within the VPC CIDR (`10.0.0.0/16`), accessible via the Bastion host.
- ALB handles SSL termination — backend instances communicate over plain HTTP within the VPC.
- ACM certificate covers both `devsecflow.me` and `*.devsecflow.me` (wildcard).
- ALB deletion protection is disabled (`enable_deletion_protection = false`) — enable this for production.

---

## Tags

All resources are tagged with:
```hcl
{
  owners      = "SAP"
  environment = "DEvelop"
}
```
