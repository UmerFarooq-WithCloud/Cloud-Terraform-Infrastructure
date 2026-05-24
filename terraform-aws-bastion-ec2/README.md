# AWS EC2 & Security Groups ΓÇö Terraform Infrastructure

A Terraform project that provisions a complete AWS network and compute environment, including a custom VPC, public and private EC2 instances, security groups, an Elastic IP, and automated provisioners.

---

## Architecture Overview

![AWS VPC + EC2 Instance + Security Groups](docs/architecture.png)

> **AWS VPC + EC2 Instance + Security Groups**
>
> The diagram above shows the full infrastructure layout across two Availability Zones inside a single VPC.

### Terraform & AWS Concepts Used

| Concept | Purpose |
|---|---|
| **Terraform Module: VPC** | Creates the VPC, subnets, route tables, NAT & Internet Gateway |
| **Terraform Module: Security Group** | Manages inbound/outbound rules for public and private instances |
| **Terraform Module: AWS EC2 Instance** | Provisions the Bastion and Private EC2 instances |
| **Meta-Argument: `depends_on`** | Ensures private instances wait for VPC to be fully ready |
| **Terraform `null_resource`** | Triggers provisioners without creating a real AWS resource |
| **Terraform File Provisioner** | Copies the `.pem` key to the Bastion host |
| **Terraform Remote-exec Provisioner** | Runs commands on the remote Bastion EC2 instance |
| **Terraform Local-exec Provisioner** | Runs commands locally to log VPC creation details |

### Traffic Flow

```
Admin (SSH Port 22)
        Γöé
        Γû╝
ΓöîΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÉ
Γöé                     AWS Cloud                        Γöé
Γöé                                                      Γöé
Γöé  ΓöîΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÉ   Γöé
Γöé  Γöé                    VPC                        Γöé   Γöé
Γöé  Γöé                                              Γöé   Γöé
Γöé  Γöé   AZ 1 (Public Subnet)   AZ 2 (Public Subnet)Γöé   Γöé
Γöé  Γöé   ΓöîΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÉ        ΓöîΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÉΓöé   Γöé
Γöé  Γöé   Γöé NAT Gateway Γöé        Γöé Bastion EC2      ΓöéΓöé   Γöé
Γöé  Γöé   ΓööΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓö¼ΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÿ        Γöé + Elastic IP     ΓöéΓöé   Γöé
Γöé  Γöé          Γöé               Γöé SG: port 22      ΓöéΓöé   Γöé
Γöé  Γöé          Γöé               Γöé from 0.0.0.0/0   ΓöéΓöé   Γöé
Γöé  Γöé          Γöé               ΓööΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓö¼ΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÿΓöé   Γöé
Γöé  Γöé          Γöé  Internet Gateway (IGW)Γöé           Γöé   Γöé
Γöé  Γöé          ΓööΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÿ           Γöé   Γöé
Γöé  Γöé                                               Γöé   Γöé
Γöé  Γöé   AZ 1 (Private Subnet)  AZ 2 (Private Subnet)Γöé  Γöé
Γöé  Γöé   ΓöîΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÉ   ΓöîΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÉ Γöé  Γöé
Γöé  Γöé   Γöé Private EC2      Γöé   Γöé Private EC2      Γöé Γöé  Γöé
Γöé  Γöé   Γöé Apache HTTPD     Γöé   Γöé Apache HTTPD     Γöé Γöé  Γöé
Γöé  Γöé   Γöé SG: port 22 & 80 Γöé   Γöé SG: port 22 & 80 Γöé Γöé  Γöé
Γöé  Γöé   Γöé from 10.0.0.0/16 Γöé   Γöé from 10.0.0.0/16 Γöé Γöé  Γöé
Γöé  Γöé   ΓööΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÿ   ΓööΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÿ Γöé  Γöé
Γöé  Γöé                                               Γöé   Γöé
Γöé  Γöé   AZ 1 (Private Subnet)  AZ 2 (Private Subnet)Γöé  Γöé
Γöé  Γöé   ΓöîΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÉ   ΓöîΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÉ Γöé  Γöé
Γöé  Γöé   Γöé   For Databases  Γöé   Γöé   For Databases  Γöé Γöé  Γöé
Γöé  Γöé   ΓööΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÿ   ΓööΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÿ Γöé  Γöé
Γöé  ΓööΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÿ  Γöé
ΓööΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÿ
```

### Key Security Rules

| Instance | Security Group Rule | Source |
|---|---|---|
| Bastion (Public) | SSH port `22` inbound | `0.0.0.0/0` (internet) |
| Bastion (Public) | All outbound | anywhere |
| Private EC2 | SSH port `22` inbound | `10.0.0.0/16` (VPC only) |
| Private EC2 | HTTP port `80` inbound | `10.0.0.0/16` (VPC only) |
| Private EC2 | All outbound | anywhere (via NAT) |

---

## What Gets Created

| Resource | Details |
|---|---|
| **VPC** | CIDR `10.0.0.0/16`, DNS hostnames & support enabled |
| **Public Subnets** | 3 subnets across `us-east-1a`, `us-east-1b`, `us-east-1d` |
| **Private Subnets** | 3 subnets across the same AZs |
| **Database Subnets** | 3 subnets with dedicated subnet group and route table |
| **NAT Gateway** | Single NAT gateway for private subnet outbound traffic |
| **VPN Gateway** | Attached to the VPC |
| **Public Security Group** | Allows inbound SSH (`22`) from anywhere, all outbound |
| **Private Security Group** | Allows inbound SSH (`22`) and HTTP (`80`) from within VPC only |
| **Public EC2 Instance** | Amazon Linux 2, `t2.micro`, placed in public subnet |
| **Private EC2 Instances** | 2├ù Amazon Linux 2, `t2.micro`, one per private subnet |
| **Elastic IP** | Static public IP attached to the public EC2 instance |
| **Web Server (user_data)** | Apache HTTPD auto-installed on private instances |

---

## Project Structure

```
.
Γö£ΓöÇΓöÇ a1_version.tf           # Terraform & provider version constraints
Γö£ΓöÇΓöÇ a2_variable.tf          # Global variables (region, environment, business division)
Γö£ΓöÇΓöÇ a2_local_var.tf         # Local values and common tags
Γö£ΓöÇΓöÇ a3_1_vpc_var.tf         # VPC-specific variables (CIDR, subnets, AZs)
Γö£ΓöÇΓöÇ a3_2_vpc_module.tf      # VPC module configuration
Γö£ΓöÇΓöÇ a3_3_vpc_output.tf      # VPC outputs
Γö£ΓöÇΓöÇ a4_1_Pub_SG.tf          # Public security group
Γö£ΓöÇΓöÇ a4_2_Priv_SG.tf         # Private security group
Γö£ΓöÇΓöÇ a4_3_output_SG.tf       # Security group outputs
Γö£ΓöÇΓöÇ a5_1_datasource_ami.tf  # Data source: latest Amazon Linux 2 AMI
Γö£ΓöÇΓöÇ a5_2_ec2_var.tf         # EC2 variables (instance type, count, key pair)
Γö£ΓöÇΓöÇ a5_3_ec2_public.tf      # Public EC2 instance
Γö£ΓöÇΓöÇ a5_4_ec2_private.tf     # Private EC2 instances (x2)
Γö£ΓöÇΓöÇ a5_5_ec2_output.tf      # EC2 outputs
Γö£ΓöÇΓöÇ a6_elasticIP.tf         # Elastic IP resource
Γö£ΓöÇΓöÇ a7_provisioner.tf       # File, remote-exec, and local-exec provisioners
Γö£ΓöÇΓöÇ ec2_inst.auto.tfvars    # Auto-loaded variable values
Γö£ΓöÇΓöÇ ec2_web.sh              # User data script ΓÇö installs Apache on private instances
ΓööΓöÇΓöÇ private_key/
    ΓööΓöÇΓöÇ titan_attack.pem    # SSH key pair (not committed to version control)
```

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- AWS CLI configured with appropriate credentials (`aws configure`)
- An existing EC2 key pair named `titan_attack` in your AWS account
- The private key file placed at `private_key/titan_attack.pem`

---

## Providers & Modules Used

| Name | Source | Version |
|---|---|---|
| `hashicorp/aws` | registry.terraform.io | `6.46.0` |
| `hashicorp/null` | registry.terraform.io | `~> 3.2` |
| `terraform-aws-modules/vpc/aws` | registry.terraform.io | `6.6.1` |
| `terraform-aws-modules/security-group/aws` | registry.terraform.io | `5.3.1` |
| `terraform-aws-modules/ec2-instance/aws` | registry.terraform.io | latest |

---

## Usage

**1. Clone the repository**
```bash
git clone <your-repo-url>
cd "Ec2 and SecurityGroups"
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

**6. Destroy when done**
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
| `instance_type` | `t2.micro` | EC2 instance type |
| `private_instance_count` | `2` | Number of private EC2 instances |
| `key_pair` | `titan_attack` | Name of the EC2 key pair |

---

## Outputs

| Output | Description |
|---|---|
| `vpc_id` | ID of the created VPC |
| `vpc_cidr_block` | CIDR block of the VPC |
| `public_subnets` | List of public subnet IDs |
| `private_subnets` | List of private subnet IDs |
| `public_sg_group_id` | Security group ID for the public instance |
| `private_sg_group_id` | Security group ID for the private instances |
| `public_instance_id` | ID of the public EC2 instance |
| `public_instance_ip` | Public IP of the public EC2 instance |
| `private_instance_id` | List of private EC2 instance IDs |
| `private_instance_ip` | List of private EC2 instance IPs |

---

## Provisioners

The `null_resource` in `a7_provisioner.tf` does three things after the public instance is ready:

1. **`file` provisioner** ΓÇö Copies `titan_attack.pem` to `/tmp/` on the bastion host so you can SSH-hop into private instances.
2. **`remote-exec` provisioner** ΓÇö Sets correct permissions (`chmod 400`) on the copied key.
3. **`local-exec` provisioner** ΓÇö Logs the VPC creation time and VPC ID to `record_provider_data/created_time_vpc_id.txt`.

---

## Security Notes

- The `private_key/` directory should be added to `.gitignore` ΓÇö never commit `.pem` files.
- The public security group allows SSH from `0.0.0.0/0`. For production, restrict this to your own IP.
- Private instances are only reachable from within the VPC CIDR (`10.0.0.0/16`), accessible via the bastion host.

---

## Tags

All resources are tagged with:
```hcl
{
  owners      = "SAP"
  environment = "DEvelop"
}
```
