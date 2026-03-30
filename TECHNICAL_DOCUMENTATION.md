# Technical Documentation: ACS 6.1 Enterprise AWS Deployment

## Summary

This project provides a complete infrastructure-as-code solution for deploying Alfresco Content Services (ACS) 6.1 Enterprise on Amazon Web Services (AWS). The deployment follows a two-stage process: first, it builds custom Amazon Machine Images (AMIs) for different ACS components using Packer and Ansible, and second, it provisions the complete AWS infrastructure and deploys ACS using Terraform.

The solution implements a highly available, scalable architecture featuring multiple deployment tiers including the Alfresco Repository, Search Services (Solr with Insight Engine), Transformation Services, and supporting infrastructure components like RDS databases, load balancers, and message brokers. The architecture emphasizes automation, repeatability, and enterprise-grade reliability using industry-standard infrastructure tools.

Key technologies include Terraform for infrastructure orchestration, Packer for AMI creation, Ansible for configuration management, and AWS services including EC2 Auto Scaling, Application Load Balancer (ALB), RDS, ActiveMQ, and EFS. The project supports environment customization through variable files and enables continuous deployment through CodeDeploy integration.

This is a Proof of Concept (POC) implementation and is not officially supported by Alfresco. It demonstrates how open-source infrastructure automation tools can be leveraged to deploy ACS Enterprise at scale on AWS while maintaining flexibility and repeatability.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         AWS Region                                   │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                      VPC (vpc-cidr)                            │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │                  Public Subnets                          │ │ │
│  │  │  ┌────────────────┐          ┌────────────────┐        │ │ │
│  │  │  │  Bastion Host  │          │ ALB (Public)   │        │ │ │
│  │  │  │   (SSH Access) │          │ (Port 80/443)  │        │ │ │
│  │  │  └────────────────┘          └────────────────┘        │ │ │
│  │  │           ↓                           ↓                 │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  │                                  ↓                              │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │               Private Subnets (AZ1, AZ2)                │ │ │
│  │  │                                                          │ │ │
│  │  │  ┌──────────────────┐  ┌──────────────────────┐        │ │ │
│  │  │  │ Repo ASG         │  │ Solr ASG             │        │ │ │
│  │  │  │ - Alfresco Repo  │  │ - Search Services    │        │ │ │
│  │  │  │ - Share UI       │  │ - Insight Engine     │        │ │ │
│  │  │  │ - Digital WS     │  │ - Solr Indexes       │        │ │ │
│  │  │  └──────────────────┘  └──────────────────────┘        │ │ │
│  │  │                                                          │ │ │
│  │  │  ┌──────────────────────────────────────────┐           │ │ │
│  │  │  │  Transformation Services ASG             │           │ │ │
│  │  │  │  - LibreOffice                           │           │ │ │
│  │  │  │  - PDF Renderer                          │           │ │ │
│  │  │  │  - ImageMagick                           │           │ │ │
│  │  │  │  - Tika                                  │           │ │ │
│  │  │  │  - Shared File Store                     │           │ │ │
│  │  │  └──────────────────────────────────────────┘           │ │ │
│  │  │                                                          │ │ │
│  │  │  ┌────────────────┐                                     │ │ │
│  │  │  │ Internal NLB   │                                     │ │ │
│  │  │  │ (Port 8080/   │                                     │ │ │
│  │  │  │  Internal)     │                                     │ │ │
│  │  │  └────────────────┘                                     │ │ │
│  │  │                                                          │ │ │
│  │  │  ┌────────────────┐  ┌────────────────┐  ┌──────────┐ │ │ │
│  │  │  │  RDS MySQL     │  │  ActiveMQ      │  │   EFS    │ │ │ │
│  │  │  │  (Multi-AZ)    │  │  (MQ Service)  │  │(Storage) │ │ │ │
│  │  │  └────────────────┘  └────────────────┘  └──────────┘ │ │ │
│  │  │                                                          │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  │                                                                 │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  External Services                                             │ │
│  │  - S3 Buckets (Content Store, Terraform State)               │ │
│  │  - CloudWatch (Monitoring/Logging)                           │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘

Data Flow:
1. User traffic → ALB (public) → Repo/Solr/TS instances
2. Repo instances ↔ RDS MySQL (database)
3. All instances ↔ ActiveMQ (messaging)
4. All instances → EFS (shared storage for TS)
5. Repo instances → S3 (content store)
6. Bastion → internal instances (SSH administration)
```

**Architecture Explanation:**
The deployment creates a multi-tier, highly available architecture spanning two availability zones (AZ1, AZ2). The public tier contains a Bastion host for secure SSH access and an Application Load Balancer (ALB) that routes user traffic to backend services. The private tier contains three Auto Scaling Groups (ASGs) managing pools of EC2 instances for the Alfresco Repository, Search Services, and Transformation Services. These instances communicate through an internal Network Load Balancer (NLB) for service-to-service communication. Supporting services include RDS for persistent database storage, ActiveMQ for messaging, and EFS for shared file storage. All instances integrate with S3 for content storage and CloudWatch for monitoring.

## Modules

### Module: Terraform Infrastructure

**Purpose**: Infrastructure-as-code orchestration for AWS resource provisioning and ACS deployment

**Location**: `acs-61-aws-terraform/`

**Key Responsibilities**:
- Define and provision AWS infrastructure (VPC, subnets, security groups)
- Create and manage Auto Scaling Groups for ACS components
- Configure load balancers and networking
- Provision databases, storage, and messaging services
- Manage IAM roles and permissions
- Output connection endpoints and configuration details

**Dependencies**:
- Terraform >= 0.10
- AWS Provider
- Pre-built AMIs (from Packer builds)
- AWS account with administrator access

**Files**:
- `alfresco-6.1-aws-deployment.tf` - Main orchestration file
- `variables.tf` - Variable declarations
- `outputs.tf` - Output values
- `modules/vpc/` - VPC and networking
- `modules/rds/` - Database configuration
- `modules/alfresco-repo/` - Repository tier
- `modules/alfresco-solr/` - Search Services tier
- `modules/transformation-service/` - Content transformation tier
- `modules/bastion/` - Bastion host for SSH access
- `modules/alb/` - Public Application Load Balancer
- `modules/internal-nlb/` - Internal Network Load Balancer
- `modules/activemq/` - Message broker configuration
- `modules/efs/` - Elastic File System for shared storage

---

### Module: Packer AMI Building - Repository

**Purpose**: Automate creation of Amazon Machine Images (AMIs) for Alfresco Repository tier

**Location**: `acs-61-repo-aws-packer/`

**Key Responsibilities**:
- Build base AMI with CentOS/RHEL
- Install and configure Tomcat application server
- Deploy Alfresco Repository, Share UI, and Digital Workspace
- Configure Alfresco properties and integrations
- Install optional components (Insight Engine, ActiveMQ client)
- Handle custom AMPs (Alfresco Modules Packages) and JARs
- Create reusable image for horizontal scaling

**Dependencies**:
- Packer
- Ansible for configuration
- AWS credentials for EC2 instance access
- Nexus repository credentials for artifact downloads
- Custom AMPs and JARs (optional)

**Files**:
- `alfresco-61-Repo-AMI.json` - Packer template
- `build-ACS-61-Repo-AMI.sh` - Build orchestration script
- `vars-61.json` - Variable configuration
- `acs-61-files/ansible/` - Ansible playbooks
- `acs-61-files/configuration/` - Tomcat and runtime configuration
- `acs-61-files/amps/` - Custom modules (optional)
- `acs-61-files/modules/` - Custom JARs (optional)

---

### Module: Packer AMI Building - Search Services

**Purpose**: Automate creation of Amazon Machine Images for Alfresco Search Services tier

**Location**: `acs-61-search-aws-packer/`

**Key Responsibilities**:
- Build base AMI with CentOS/RHEL
- Install and configure Tomcat
- Deploy Alfresco Search Services (Solr) with Insight Engine
- Configure search indices and replication
- Install optional components and performance tuning
- Create reusable image for horizontal scaling

**Dependencies**:
- Packer
- Ansible for configuration
- AWS credentials
- Nexus repository credentials
- Alfresco license for Insight Engine

**Files**:
- `alfresco-61-Search-AMI.json` - Packer template
- `build-ACS-61-Search-AMI.sh` - Build orchestration script
- `vars-61.json` - Variable configuration
- `acs-61-files/ansible/` - Ansible playbooks

---

### Module: Packer AMI Building - Transformation Services

**Purpose**: Automate creation of Amazon Machine Images for content transformation services

**Location**: `acs-61-transformation-services-aws-packer/`

**Key Responsibilities**:
- Build base AMI with CentOS/RHEL
- Install transformation tools (LibreOffice, ImageMagick, Tika)
- Configure PDF renderer
- Deploy Alfresco Transformation Router and Shared File Store
- Set up EFS integration for shared transformation workspace
- Configure resource allocation and performance parameters

**Dependencies**:
- Packer
- Ansible with custom roles
- AWS credentials
- LibreOffice, ImageMagick, Tika packages
- Nexus credentials for Alfresco components

**Files**:
- `packer-template-transform-service.json` - Packer template
- `build-Transformation-Services-AMI.sh` - Build script
- `vars-61.json` - Configuration variables
- `acs-61-files/ansible/roles/transform-service/` - Ansible roles
- `acs-61-files/ansible/tasks/` - Installation tasks

---

### Module: CodeDeploy Integration

**Purpose**: Enable continuous deployment and updates to running ACS instances

**Location**: `CodeDeploy/`

**Key Responsibilities**:
- Define deployment specifications for Alfresco components
- Manage lifecycle hooks (before/after deployment)
- Handle application lifecycle scripts
- Enable zero-downtime updates

**Dependencies**:
- AWS CodeDeploy service
- IAM roles on EC2 instances
- CodeDeploy agent on instances

**Files**:
- `alfresco-repo-code-deploy/appspec.yml` - Repository deployment spec
- `alfresco-solr-code-deploy/appspec.yml` - Search Services deployment spec

---

## File Details

### `acs-61-aws-terraform/alfresco-6.1-aws-deployment.tf`

**Module**: Terraform Infrastructure

**Description**: Main orchestration file that defines all AWS modules and their interdependencies. Acts as the top-level composition layer that brings together VPC networking, databases, compute resources, load balancing, and messaging into a cohesive deployment.

**Dependencies**:
- AWS Provider (configured with region)
- S3 backend for Terraform state storage
- DynamoDB table for state locking
- All child modules

**Key Components**:

#### Terraform Backend Configuration
- **Type**: S3 with DynamoDB locking
- **Purpose**: Persistent state management and concurrent execution protection
- **Configuration**: Bucket name, key path, region, DynamoDB table for locking

#### AWS Provider
- **Type**: Terraform resource
- **Purpose**: Configures AWS authentication and region settings
- **Parameters**: Region interpolated from variables

#### VPC Module
- **Purpose**: Creates isolated network environment with public/private subnets across AZs
- **Outputs**: VPC ID, subnet IDs, default security group
- **Key Logic**: Defines network CIDR ranges, availability zones, and routing

#### RDS Module
- **Purpose**: Provisions MySQL database for Alfresco content repository
- **Dependencies**: VPC subnets, security groups from Repo and Solr modules
- **Configuration**: Multi-AZ setup, encryption, backup retention
- **Key Variables**: Database name, username, password, storage size, instance class

#### Alfresco Repository Module
- **Purpose**: Creates Auto Scaling Group for Alfresco Repository instances
- **Key Responsibilities**:
  - Defines launch configuration with custom user data
  - Configures security groups (port 8080 for app, 22 for SSH)
  - Integrates with ALB for load balancing
  - Manages database connectivity and messaging configuration
  - Configures EBS volumes for content caching
- **Scaling**: Auto Scaling Group with min/max/desired capacity

#### Alfresco Solr Module
- **Purpose**: Creates Auto Scaling Group for Search Services instances
- **Key Features**:
  - Dedicated instances for search indexing
  - Insight Engine integration
  - Connection to messaging broker for index synchronization
  - Internal NLB registration for service discovery

#### Transformation Service Module
- **Purpose**: Provisions content transformation services
- **Components**: LibreOffice, PDF Renderer, ImageMagick, Tika, Transformation Router
- **Storage**: EFS integration for shared workspace
- **Configuration**: Ports and memory allocation for each transformation tool

#### Bastion Module
- **Purpose**: Secure SSH access point to private resources
- **Configuration**: Public subnet placement, SSH port 22 access

#### ALB Module
- **Purpose**: Public Application Load Balancer
- **Functions**:
  - Routes HTTP/HTTPS traffic to Repository and Solr targets
  - Health checking
  - Session persistence
  - Serves as primary entry point for users

#### Internal NLB Module
- **Purpose**: Service-to-service communication
- **Configuration**: Private subnets, TCP port 8080
- **Use Cases**: Repo to Transformation Services, Repo to Search Services

#### ActiveMQ Module
- **Purpose**: Message broker for asynchronous communication
- **Endpoints**: SSL connections to Repository and Solr instances
- **Configuration**: User credentials, failover configuration

#### EFS Module
- **Purpose**: Shared file storage for transformation services
- **Availability**: Multi-AZ with automatic failover
- **Use Case**: Shared workspace for document transformation operations

---

### `acs-61-aws-terraform/modules/alfresco-repo/main.tf`

**Module**: Terraform Infrastructure / Alfresco Repository

**Description**: Terraform module that provisions the Alfresco Repository tier including Auto Scaling infrastructure, security configuration, IAM roles, and application-level configuration injection through user data scripts.

**Dependencies**:
- VPC module outputs
- RDS module outputs
- ALB module outputs
- Internal NLB outputs
- ActiveMQ module outputs
- Terraform variables for configuration

**Key Components**:

#### Local Variables
- `lb_url`: Load balancer DNS for external access
- `internal_lb_url`: Internal load balancer for service discovery
- `db_url`: JDBC connection string for MySQL database
- `mq_failover`: ActiveMQ failover configuration
- **Key Logic**: Properly escapes special characters for insertion into Alfresco configuration files

#### Security Group: alfresco-sg
- **Ingress Rules**:
  - Port 8080 (TCP): Alfresco web application from ALB
  - Port 22 (TCP): SSH access from anywhere (0.0.0.0/0) - security risk
  - Port 5701 (TCP): Hazelcast cluster communication from anywhere - for cache distribution
  - Port 61617 (TCP): ActiveMQ client connection from anywhere
- **Egress Rules**: All traffic allowed to anywhere (0.0.0.0/0)
- **Note**: Security group rules are overly permissive; ports 22, 5701, 61617 should be restricted to specific CIDR ranges

#### Launch Configuration: repo-lcfg
- **Instance Configuration**:
  - Image ID: Custom AMI from Packer build
  - Instance Type: Configurable (e.g., t2.large, m5.xlarge)
  - IAM Profile: Alfresco repository role (S3, CloudWatch permissions)
  - Key Pair: EC2 SSH key for access
  - Security Groups: alfresco-sg
- **Storage Configuration**:
  - EBS Volume (/dev/xvdb): Secondary volume for content store caching
  - Type: GP2 (general purpose)
  - Size: Configurable (typically 100-500GB)
  - Encryption: Enabled
  - Delete on Termination: True (cleanup on instance shutdown)
- **User Data Script** (bash, 100+ lines):
  - **Timing**: Executes when instance first launches
  - **Operations Performed**:
    - Injects ActiveMQ credentials and failover endpoints into alfresco-global.properties
    - Configures internal/external load balancer URLs
    - Sets database connection details (driver, hostname, port, credentials)
    - Configures S3 bucket location for content storage
    - Injects transformation service ports (LibreOffice, PDF Renderer, ImageMagick, Tika)
    - Uses sed to perform search/replace on configuration file
  - **Security Note**: Database password and credentials are passed in user data, visible to AWS (consider using AWS Secrets Manager instead)
  - **Scalability**: Enables all instances to receive identical configuration regardless of launch time

---

### `acs-61-aws-terraform/modules/alfresco-repo/vars.tf`

**Module**: Terraform Infrastructure / Alfresco Repository

**Description**: Variable declarations for the Repository module, defining all input parameters required for provisioning Repository instances.

**Dependencies**: None (input definitions only)

**Key Components**:

#### Network Variables
- `vpc-id`: Target VPC for resource placement
- `vpc-default-sg-id`: Default security group reference
- `private-subnet-1-id`, `private-subnet-2-id`: Subnets for multi-AZ deployment

#### Database Variables
- `rds-endpoint`: MySQL database hostname/port
- `rds-name`, `rds-username`, `rds-password`: Database credentials
- `rds-driver`: JDBC driver class (e.g., com.mysql.jdbc.Driver)

#### Load Balancer Variables
- `alb-name`: Public ALB name
- `alb-dns`: ALB DNS name (external URL)
- `alb-sg-id`: ALB security group
- `alb-arn`, `alb-listener-arn`: ARN references for target group registration
- `internal-nlb-arn`, `internal-nlb-dns`: Internal load balancer endpoints

#### Auto Scaling Variables
- `autoscaling-group-max-size`: Maximum instances (e.g., 5)
- `autoscaling-group-min-size`: Minimum instances (e.g., 2)
- `autoscaling-group-desired-capacity`: Target instances (e.g., 2)
- `autoscaling-group-instance-type`: EC2 instance class (e.g., m5.xlarge)
- `autoscaling-group-image-id`: AMI ID from Packer build
- `autoscaling-group-key-name`: SSH key pair name

#### Messaging Variables
- `mq-ssl-endpoint-1`, `mq-ssl-endpoint-2`: ActiveMQ brokers for high availability
- `mq-user`, `mq-password`: Broker credentials

#### Transformation Service Ports
- `jod-converter-port`: LibreOffice port (typically 8100)
- `pdf-renderer-port`: PDF Renderer port (typically 8090)
- `image-magick-port`: ImageMagick port (typically 8091)
- `tika-port`: Apache Tika port (typically 8092)
- `shared-file-store-port`: Shared File Store port (typically 8099)

#### Storage Variables
- `s3-bucket-location`: S3 bucket region
- `resource-prefix`: Naming prefix for all resources
- `solr-ebs-volume-size`, `cachedcontent-ebs-volume-size`: Storage allocation

---

### `acs-61-aws-terraform/modules/vpc/main.tf`

**Module**: Terraform Infrastructure / VPC Networking

**Description**: Defines Virtual Private Cloud (VPC) and network topology including subnets, internet gateway, NAT gateway, route tables, and network access control lists.

**Dependencies**: None (foundational infrastructure)

**Key Components**:

#### VPC Resource
- Creates isolated network environment
- CIDR block configurable (e.g., 10.0.0.0/16)
- DNS resolution enabled

#### Public Subnets (2 AZs)
- Purpose: Host load balancers and bastion host
- CIDR: Smaller blocks within VPC CIDR (e.g., 10.0.1.0/24, 10.0.2.0/24)
- Route: Direct route to internet via Internet Gateway
- Availability: One per AZ for fault tolerance

#### Private Subnets (2 AZs)
- Purpose: Host application servers (Repo, Solr, Transformation Services)
- CIDR: Larger blocks (e.g., 10.0.11.0/24, 10.0.12.0/24)
- Route: Internet access via NAT Gateway in public subnet
- Availability: One per AZ for fault tolerance

#### Internet Gateway
- Provides public subnet connectivity to internet
- Attached to VPC
- Routes traffic from public subnets to external networks

#### NAT Gateway
- Enables private subnet instances to initiate outbound connections
- Located in public subnet
- Uses Elastic IP for persistent external address

#### Route Tables
- **Public Route Table**: Routes 0.0.0.0/0 to Internet Gateway
- **Private Route Table**: Routes 0.0.0.0/0 to NAT Gateway
- **Subnets Association**: Each subnet explicitly associated with route table

#### Network ACLs (optional)
- Stateless network-level firewall
- Default rules typically allow all traffic
- Can be customized for granular traffic control

---

### `acs-61-aws-terraform/modules/rds/main.tf`

**Module**: Terraform Infrastructure / Database

**Description**: Provisions AWS RDS MySQL database for Alfresco content repository persistence.

**Dependencies**:
- VPC and security groups from dependent modules
- RDS parameter group (optional custom)
- Database snapshot (for restore operations)

**Key Components**:

#### DB Security Group
- Ingress Rule 1: Port 3306 from Repository security group
- Ingress Rule 2: Port 3306 from Solr security group
- Egress: All traffic allowed

#### RDS Instance
- **Engine**: MySQL (configurable version)
- **Multi-AZ**: Enabled for high availability (automatic failover to standby)
- **Storage**:
  - Type: Configurable (gp2, io1, etc.)
  - Size: 100-1000GB typically
  - Encryption: Enabled by default
  - Backup Retention: 7-30 days
- **Credentials**: Master username/password set at creation
- **Subnet Group**: Spans private subnets in multiple AZs
- **Monitoring**: CloudWatch monitoring enabled
- **Parameter Group**: Database configuration tuning
- **Backup Window**: Configurable maintenance window

#### Alfresco Database Requirements
- Character Set: utf8mb4 (Unicode support)
- Schema: Created by Alfresco on first connection
- Performance Tuning Parameters: Memory allocation, query cache, connection pools

---

### `acs-61-aws-terraform/modules/alb/main.tf`

**Module**: Terraform Infrastructure / Application Load Balancer

**Description**: Provisions public-facing Application Load Balancer (ALB) for distributing user traffic across repository and search services instances.

**Dependencies**:
- VPC and public subnets
- Security groups

**Key Components**:

#### ALB Security Group
- Ingress Rules:
  - Port 80 (HTTP) from 0.0.0.0/0
  - Port 443 (HTTPS) from 0.0.0.0/0
- Egress: All traffic allowed to backend targets

#### Application Load Balancer
- **Scheme**: internet-facing (public)
- **Subnets**: Public subnets in both AZs
- **Type**: application (Layer 7 - application layer routing)
- **Idle Timeout**: 60 seconds (configurable)

#### Listeners
- **HTTP Listener** (Port 80):
  - Path-based routing rules
  - Routes /share → Alfresco Share target group
  - Routes /solr → Alfresco Solr target group
  - Routes /digital-workspace → Digital Workspace target group
  - Default target group: Repository

#### Target Groups
- **Alfresco Repository**:
  - Protocol: HTTP
  - Port: 8080
  - Health Check: GET / (interval 30s, threshold 2 healthy)
- **Alfresco Solr**:
  - Protocol: HTTP
  - Port: 8080 (same port, different path routing)
  - Health Check: GET /solr (interval 30s, threshold 2 healthy)
- **Digital Workspace**:
  - Protocol: HTTP
  - Port: 8080
  - Path pattern: /digital-workspace*

#### Stickiness Configuration
- Duration: 1 day (cookie-based session persistence)
- Purpose: Route user to same backend instance for session continuity

---

### `acs-61-aws-terraform/modules/internal-nlb/main.tf`

**Module**: Terraform Infrastructure / Internal Network Load Balancer

**Description**: Provisions internal Network Load Balancer (NLB) for low-latency, service-to-service communication between transformation services, repository, and search instances.

**Dependencies**:
- VPC and private subnets
- Security groups

**Key Components**:

#### Internal NLB Configuration
- **Scheme**: internal (private)
- **Type**: network (Layer 4 - transport layer, ultra-high performance)
- **Subnets**: Private subnets in both AZs
- **Load Balancing Algorithm**: Flow hash based on protocol, source IP, source port, destination IP, destination port

#### Listener
- **Protocol**: TCP
- **Port**: 8080
- **Target Group**: Internal services (Repository, Transformation Services)

#### Use Cases
- Repository instances accessing transformation services
- Repository to Solr communication
- Direct service discovery without internet gateway

---

### `acs-61-aws-terraform/modules/activemq/main.tf`

**Module**: Terraform Infrastructure / ActiveMQ Message Broker

**Description**: Provisions AWS MQ (managed ActiveMQ) service for asynchronous messaging between Alfresco components.

**Dependencies**:
- VPC and private subnets
- Security groups from Repository and Solr modules

**Key Components**:

#### Security Group
- Ingress Rule 1: Port 61617 (SSL) from Repository security group
- Ingress Rule 2: Port 61617 (SSL) from Solr security group
- Egress: All traffic allowed

#### MQ Broker Configuration
- **Type**: ActiveMQ
- **Deployment**: Multi-AZ (high availability)
- **Instance Class**: mq.m5.large (configurable)
- **Storage**: 20-200 GB (configurable)
- **SSL/TLS**: Enabled for encrypted client connections
- **User**: Administrative user with broker management permissions

#### Use Cases
- **Repository to Search**: Publishing content changes
- **Async Processing**: Job queues for long-running operations
- **Event Distribution**: Publishing events across cluster

---

### `acs-61-aws-terraform/modules/efs/main.tf`

**Module**: Terraform Infrastructure / Elastic File System

**Description**: Provisions AWS EFS (Elastic File System) for shared storage accessed by transformation services and repository instances.

**Dependencies**:
- VPC and subnets
- Security groups

**Key Components**:

#### EFS Configuration
- **Performance Mode**: General Purpose (default)
- **Throughput Mode**: Bursting (scales with usage)
- **Availability**: Multi-AZ automatic replication
- **Lifecycle Policy**: Transition to IA (Infrequent Access) after 30 days
- **Encryption**: At-rest encryption enabled

#### Mount Targets
- One per AZ for fault tolerance
- Located in private subnets
- Security group allows port 2049 (NFS) from transformation services

#### Use Cases
- **Transformation Services**: Shared workspace for document conversion
- **Distributed Content**: Accessible from multiple instances simultaneously
- **Durability**: Automatic replication across AZs

---

### `acs-61-aws-terraform/modules/bastion/main.tf`

**Module**: Terraform Infrastructure / Bastion Host

**Description**: Provisions public-facing bastion host (jump server) for secure SSH access to private subnet resources.

**Dependencies**:
- VPC and public subnets
- EC2 SSH key pair

**Key Components**:

#### Bastion Security Group
- Ingress Rule: Port 22 (SSH) from 0.0.0.0/0
- Egress: All traffic allowed to private subnet

#### EC2 Instance
- **AMI**: Latest Amazon Linux 2 or CentOS
- **Subnet**: Public subnet (alternates between AZs)
- **Instance Type**: t2.micro or t2.small (low traffic)
- **Key Pair**: SSH key for management
- **Elastic IP**: Static public IP for reliable access
- **User Data**: SSH daemon configuration, security hardening

#### SSH Access Pattern
1. User: `ssh -i key.pem ec2-user@bastion-public-ip`
2. From Bastion: `ssh -i key.pem ec2-user@private-instance-ip` (via private subnet routing)

---

### `acs-61-repo-aws-packer/alfresco-61-Repo-AMI.json`

**Module**: Packer AMI Building - Repository

**Description**: Packer template that defines the build process for creating Alfresco Repository AMI using Amazon EC2 source, provisioning with Ansible.

**Dependencies**:
- Packer >= 1.5.0
- AWS credentials (IAM user with EC2 permissions)
- VPC and security group ID
- Ansible installed locally or in build environment

**Key Components**:

#### Builders Section
- **Type**: amazon-ebs (builds AMI from EC2 instance)
- **AMI Name**: Pattern includes timestamp for uniqueness
- **Source AMI**: CentOS 7 base image
- **Instance Type**: m5.large or larger (sufficient for compilation)
- **Region**: Configurable (e.g., eu-west-2)
- **VPC ID**: Target VPC for build instance
- **Security Group**: Allows SSH (port 22) for Packer access
- **SSH Timeout**: 5 minutes for connection establishment
- **Associate Public IP**: true (enables internet access for downloads)
- **Run Tags**: Identifies Packer builder instances
- **Ami Description**: Human-readable description of image

#### Provisioners Section
- **File Provisioner**:
  - Uploads local Ansible playbooks to `/tmp/ansible/`
  - Uploads configuration files, scripts, custom AMPs/JARs
- **Ansible Provisioner**:
  - Local playbook execution on build instance
  - Playbook: `alfresco-instance.yaml`
  - Configures packages, Java, Tomcat, Alfresco
  - Idempotent (safe to run multiple times)
- **Shell Provisioner**:
  - Cleanup scripts before AMI creation
  - Removes SSH keys, temporary files
  - Clears logs and caches

#### Post-Processors
- Manifest: Output final AMI ID and metadata

---

### `acs-61-repo-aws-packer/acs-61-files/ansible/alfresco-instance.yaml`

**Module**: Packer AMI Building - Repository

**Description**: Ansible playbook orchestrating the complete installation and configuration of Alfresco Repository, Share UI, and supporting services on CentOS/RHEL.

**Dependencies**:
- Ansible 2.9+
- Target system: CentOS 7/RHEL 7
- Java Development Kit (JDK)
- Tomcat application server
- MySQL client
- Git (for version control of configurations)

**Key Components**:

#### Playbook Hosts
- Target: Localhost (run on build instance)
- Gather Facts: Yes (collect system information)
- Become: Yes (execute as root)

#### Role/Task Sequence
1. **System Preparation** (pre-tasks)
   - Update package manager (yum)
   - Install system packages (git, wget, curl)
   - Disable SELinux (security context may interfere with Alfresco)

2. **Java Installation**
   - Install OpenJDK (typically 11 or 8)
   - Set JAVA_HOME environment variable
   - Verify Java version

3. **Tomcat Installation** (tasks/tomcat.yaml)
   - Download Tomcat 9 (configurable version)
   - Extract to /opt/tomcat
   - Create alfresco user/group
   - Configure ownership and permissions
   - Enable Tomcat manager application
   - Create startup scripts

4. **MySQL Client Installation** (tasks/mysql.yaml)
   - Install MySQL client libraries
   - Download MySQL JDBC driver
   - Copy driver to Tomcat shared libraries

5. **Alfresco Repository Installation** (tasks/alfresco.yaml)
   - Create /opt/alfresco-content-services directory
   - Download Alfresco WAR from Nexus repository
   - Deploy WAR to Tomcat webapps
   - Download required plugins (transformation services, etc.)
   - Apply custom AMPs (Alfresco Modules) if provided
   - Deploy custom JARs if provided

6. **Alfresco Share Installation**
   - Download Share UI WAR
   - Deploy to Tomcat
   - Configure Share connection to Repository

7. **Digital Workspace Installation** (tasks/digital-workspace.yaml)
   - Deploy digital-workspace.war if provided
   - Configure proxy settings

8. **Insight Engine Installation** (tasks/insight-engine.yaml)
   - Deploy Insight Engine plugin
   - Configure advanced search indexing

9. **Configuration Files**
   - Copy alfresco-global.properties template
   - Set placeholder values for later injection (Terraform user data)
   - Placeholders: MQ-USER, DB-URL, LB-URL, etc.
   - Enable additional modules (Smart Folder, Records Management)

10. **Tomcat Configuration** (tasks/alfresco-tomcat-conf.yaml)
    - Memory settings (JAVA_OPTS, Xmx, Xms)
    - Database connection pooling
    - Cache configuration
    - Thread pools for async jobs

11. **System Optimization**
    - Set file descriptor limits
    - Configure kernel parameters
    - Enable system service startup

#### Output
- Base AMI ready for deployment
- Placeholder configuration values replaced by Terraform user data
- System configured but not yet connected to database/messaging

---

### `acs-61-repo-aws-packer/build-ACS-61-Repo-AMI.sh`

**Module**: Packer AMI Building - Repository

**Description**: Shell script orchestrating the complete AMI build process, managing credentials, environment setup, and invoking Packer.

**Dependencies**:
- Bash shell
- Packer command-line tool
- AWS credentials (via environment or config file)
- ~/.nexus-cfg file containing Nexus credentials

**Key Components**:

#### Script Execution Flow

1. **Source Nexus Credentials**
   - Command: `. ~/.nexus-cfg`
   - Exports environment variables: `nexus_user`, `nexus_password`
   - These variables passed to Packer for artifact downloads

2. **Invoke Packer Build**
   - Command: `packer build -var-file=vars-61.json -on-error=ask alfresco-61-Repo-AMI.json`
   - Arguments:
     - `-var-file=vars-61.json`: Variables for VPC, region, instance type, etc.
     - `-on-error=ask`: Prompts user if build fails (useful for debugging)
     - `alfresco-61-Repo-AMI.json`: Template file location
   - Environment: Inherits Nexus credentials from shell

#### Error Handling
- Exit on first error (set -e)
- On-error prompt allows investigation of failed build
- User can retry or abandon build

#### Security Considerations
- Nexus credentials sourced from file (should have restricted permissions: 600)
- Build instance has temporary EC2 key pair (destroyed after build)
- Temporary security group restricted to SSH access

---

### `CodeDeploy/alfresco-repo-code-deploy/appspec.yml`

**Module**: CodeDeploy Integration

**Description**: YAML specification for AWS CodeDeploy defining how to deploy application updates to running Repository instances.

**Dependencies**:
- AWS CodeDeploy service
- CodeDeploy agent running on EC2 instances
- S3 bucket containing application artifacts
- IAM role with CodeDeploy permissions

**Key Components**:

#### Version
- `version: 0.0`
- Specifies AppSpec format version

#### OS
- `os: linux`
- Target operating system (CentOS/RHEL)

#### Files Section
- **Source**: Local path in application bundle
- **Destination**: Target path on instance
- Copies updated WAR files, configuration files to Tomcat

#### Permissions Section
- Sets file ownership (alfresco:alfresco)
- Sets permissions (644 for files, 755 for directories)

#### Hooks Section
- **before-install**: Stop services, backup current installation
- **after-install**: Extract files, restore configuration
- **application-start**: Start Tomcat service
- **application-stop**: Graceful shutdown of services
- **validate-service**: Health checks to verify deployment success

#### Script References
- Each hook executes shell scripts
- Scripts define:
  - Service stop/start commands
  - File validation
  - Log rotation
  - Notification mechanisms

#### Lifecycle Flow
1. CodeDeploy downloads application revision from S3
2. Executes before-install hooks
3. Copies files as specified
4. Executes after-install hooks
5. Starts application
6. Validates health
7. Marks deployment complete or rolls back

---

## Variable Configuration

### Key Terraform Variables (terraform.tfvars)

```hcl
# Naming and Identification
resource-prefix = "acs-61"          # Prefix for all AWS resources

# AWS Configuration
aws-region = "eu-west-2"            # Deployment region
aws-availability-zones = ["a", "b"] # Multi-AZ configuration

# VPC and Networking
vpc-cidr = "10.0.0.0/16"            # Private IP range for VPC

# Database Configuration
rds-name = "alfresco"               # Database name
rds-username = "alfresco"           # DB admin user
rds-password = "SecurePassword123"  # DB password (use AWS Secrets Manager)
rds-engine = "mysql"                # Database engine
rds-engine-version = "5.7"          # MySQL version
rds-instance-class = "db.m5.large"  # Instance size
rds-storage-size = 100              # Storage GB
rds-storage-type = "gp2"            # Storage type
rds-port = 3306                     # MySQL port

# Repository Auto Scaling
autoscaling-repo-group-min-size = 2
autoscaling-repo-group-max-size = 5
autoscaling-repo-group-desired-capacity = 2
autoscaling-repo-group-instance-type = "m5.xlarge"
autoscaling-repo-group-image-id = "ami-0123456789abcdef0"  # From Packer build

# Solr Auto Scaling
autoscaling-solr-group-min-size = 2
autoscaling-solr-group-max-size = 3
autoscaling-solr-group-desired-capacity = 2
autoscaling-solr-group-instance-type = "m5.xlarge"
autoscaling-solr-group-image-id = "ami-0123456789abcdef1"  # From Packer build

# Transformation Services Auto Scaling
autoscaling-ts-group-min-size = 1
autoscaling-ts-group-max-size = 3
autoscaling-ts-group-desired-capacity = 1
autoscaling-ts-group-instance-type = "m5.xlarge"
autoscaling-ts-group-image-id = "ami-0123456789abcdef2"   # From Packer build

# Storage
s3-bucket-location = "eu-west-2"    # S3 bucket region
cachedcontent-ebs-volume-size = 100 # Content cache volume GB
solr-ebs-volume-size = 50           # Solr index volume GB

# SSH Access
autoscaling-group-key-name = "my-ec2-keypair"  # SSH key pair name

# Message Broker
mq-user = "alfresco"                # ActiveMQ user
mq-password = "MQPassword123"       # ActiveMQ password

# Transformation Services Ports
jod-converter-port = 8100
pdf-renderer-port = 8090
image-magick-port = 8091
tika-port = 8092
shared-file-store-port = 8099
```

### Packer Variables (vars-61.json)

```json
{
  "aws_access_key": "AKIAIOSFODNN7EXAMPLE",
  "aws_secret_key": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
  "aws_region": "eu-west-2",
  "vpc_id": "vpc-0123456789abcdef0",
  "instance_type": "m5.large",
  "source_ami": "ami-0b850d8c1bce0d213",  // CentOS 7 base
  "ami_name": "acs-61-repo-{{timestamp}}",
  "ansible_host": "localhost"
}
```

---

## Deployment Workflow

### Step 1: Build Repository AMI
```bash
cd acs-61-repo-aws-packer
export nexus_user="your_nexus_user"
export nexus_password="your_nexus_password"
./build-ACS-61-Repo-AMI.sh
# Output: ami-xxxxxxxxxxxxx (note this ID)
```

### Step 2: Build Search Services AMI
```bash
cd acs-61-search-aws-packer
./build-ACS-61-Search-AMI.sh
# Output: ami-yyyyyyyyyyyyyyyyyy (note this ID)
```

### Step 3: Build Transformation Services AMI
```bash
cd acs-61-transformation-services-aws-packer
./build-Transformation-Services-AMI.sh
# Output: ami-zzzzzzzzzzzzzzzzzz (note this ID)
```

### Step 4: Configure Terraform
```bash
cd acs-61-aws-terraform
# Edit terraform.tfvars with:
# - autoscaling-repo-group-image-id = ami-xxxxxxxxxxxxx
# - autoscaling-solr-group-image-id = ami-yyyyyyyyyyyyyy
# - autoscaling-ts-group-image-id = ami-zzzzzzzzzzzzzz
# - Update resource-prefix, region, VPC CIDR, credentials
```

### Step 5: Deploy Infrastructure
```bash
cd acs-61-aws-terraform
terraform init  # Initialize backend and modules
terraform plan  # Preview changes
terraform apply # Create resources (15-20 minutes)
# Output: ALB URL, RDS endpoint, VPC ID
```

### Step 6: Verify Deployment
- Navigate to ALB URL (from terraform output)
- Login to Alfresco Share with default credentials
- Check CloudWatch logs for any errors

---

## Security Considerations

### Current Vulnerabilities
1. **SSH Port 22**: Open to 0.0.0.0/0 (should be restricted to bastion/VPN)
2. **ActiveMQ Port 61617**: Open to 0.0.0.0/0 (should be internal-only)
3. **Hazelcast Port 5701**: Open to 0.0.0.0/0 (inter-node communication only)
4. **Database Credentials**: Passed via user data (visible to AWS, EC2 metadata)
5. **S3 State**: Not encrypted by default (enable server-side encryption)
6. **RDS Password**: Hardcoded in variables (use AWS Secrets Manager)

### Recommended Improvements
1. Restrict security group ingress to specific CIDR blocks
2. Use VPN/bastion for administrative access
3. Implement AWS Secrets Manager for credential management
4. Enable VPC Flow Logs for network monitoring
5. Configure CloudTrail for audit logging
6. Implement SSL/TLS termination at ALB
7. Use AWS Systems Manager Session Manager instead of direct SSH
8. Enable encryption on all EBS volumes
9. Implement network ACLs for additional protection

---

## Maintenance and Scaling

### Horizontal Scaling
- Adjust `autoscaling-group-desired-capacity` in terraform.tfvars
- Run `terraform apply` to update Auto Scaling Group
- New instances automatically receive configuration via user data
- Load balancer automatically registers new instances

### Vertical Scaling
- Change `autoscaling-group-instance-type` to larger instance class
- Create new launch configuration
- Terminate old instances one-by-one (rolling update)
- Application stays available during migration

### Database Scaling
- Modify `rds-instance-class` for compute scaling
- Modify `rds-storage-size` for storage scaling
- RDS Multi-AZ ensures minimal downtime during scaling

### AMI Updates
- Update Ansible playbooks in Packer templates
- Rebuild AMI with `./build-ACS-61-Repo-AMI.sh`
- Update `autoscaling-repo-group-image-id` in terraform.tfvars
- Deploy CodeDeploy update or terminate instances for automatic rebuild

---

## Troubleshooting

### Common Issues

#### Issue: Alfresco Repository fails to start
**Symptoms**: HTTP 503 Service Unavailable from ALB
**Diagnosis**:
- SSH to instance via bastion
- Check Tomcat logs: `tail -f /opt/alfresco-content-services/tomcat/logs/catalina.out`
- Check alfresco-global.properties for configuration errors
- Verify database connectivity: `mysql -h RDS_ENDPOINT -u DB_USER -p`

**Solutions**:
- Verify database endpoint, credentials
- Check security groups allow port 3306 to RDS
- Review CloudWatch logs for detailed error messages

#### Issue: Search Services (Solr) not indexing
**Symptoms**: Search queries return zero results
**Diagnosis**:
- Check Solr health endpoint: ALB_URL/solr/admin/cores
- Verify ActiveMQ connectivity from Solr instance
- Check Solr logs for indexing errors

**Solutions**:
- Verify security group allows ActiveMQ port 61617
- Check message queue depth for blocked messages
- Rebuild Solr indexes via Repository admin panel

#### Issue: High latency on content operations
**Symptoms**: Document uploads/downloads slow
**Diagnosis**:
- Check CloudWatch metrics for CPU, memory utilization
- Monitor network throughput to S3
- Check RDS slow query log

**Solutions**:
- Increase instance type for more resources
- Enable query caching in RDS
- Optimize S3 bucket configuration (transfer acceleration)

---

## Additional Resources

- **Alfresco Documentation**: https://docs.alfresco.com/
- **Terraform AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/
- **Packer Documentation**: https://www.packer.io/docs
- **Ansible Documentation**: https://docs.ansible.com/
- **AWS Best Practices**: https://aws.amazon.com/architecture/well-architected/

---

*This documentation was generated for Alfresco Content Services 6.1 Enterprise on AWS. References to version 6.1 and specific URLs are based on historical deployment information. For production deployments, verify compatibility with current versions and consult official Alfresco and AWS documentation.*
