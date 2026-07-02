#!/bin/bash

# Enhanced Color Definitions
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BG_BLACK=$(tput setab 0)
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_YELLOW=$(tput setab 3)
BG_BLUE=$(tput setab 4)
BG_MAGENTA=$(tput setab 5)
BG_CYAN=$(tput setab 6)
BG_WHITE=$(tput setab 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

# Clear screen and display enhanced header
clear

# =============================================
# ███████╗████████╗ █████╗ ██████╗ ████████╗
# ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝
# ███████╗   ██║   ███████║██████╔╝   ██║   
# ╚════██║   ██║   ██╔══██║██╔══██╗   ██║   
# ███████║   ██║   ██║  ██║██║  ██║   ██║   
# ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   
# =============================================

echo "${BG_MAGENTA}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
echo "${BG_MAGENTA}${BOLD}║                                                          ║${RESET}"
echo "${BG_MAGENTA}${BOLD}║      🚀 DR. ABHISHEK'S TERRAFORM MODULES LAB 🚀         ║${RESET}"
echo "${BG_MAGENTA}${BOLD}║                                                          ║${RESET}"
echo "${BG_MAGENTA}${BOLD}║   🌟 Master Terraform Modules with Real-World Examples  ║${RESET}"
echo "${BG_MAGENTA}${BOLD}║                                                          ║${RESET}"
echo "${BG_MAGENTA}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo "${CYAN}${BOLD}📺 YouTube Channel:${RESET} ${YELLOW}https://www.youtube.com/@drabhishek.5460${RESET}"
echo "${CYAN}${BOLD}🎬 Video Tutorials:${RESET} ${YELLOW}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo "${CYAN}${BOLD}📚 GitHub Repository:${RESET} ${YELLOW}https://github.com/Itsabhishek7py/GoogleCloudSkillsboost${RESET}"
echo ""
echo "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# Get Region Input
echo "${CYAN}${BOLD}🌍 Step 1: Please enter your preferred region (e.g., us-central1):${RESET}"
read -p "➜ " REGION
export REGION
echo ""
echo "${GREEN}✅ Region set to: ${REGION}${RESET}"
echo ""

# Install Terraform
echo "${CYAN}${BOLD}🔧 Step 2: Installing Terraform${RESET}"
cat <<'EOF' > ~/.customize_environment
# Set up HashiCorp repository and install Terraform
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform
EOF
bash ~/.customize_environment || {
    echo "${RED}❌ Terraform installation failed${RESET}"
    exit 1
}
echo "${GREEN}✅ Terraform installed successfully${RESET}"
echo ""

# Verify Terraform Installation
echo "${CYAN}${BOLD}🔍 Step 3: Verifying Terraform Installation${RESET}"
terraform version || {
    echo "${RED}❌ Terraform verification failed${RESET}"
    exit 1
}
echo "${GREEN}✅ Terraform verified successfully${RESET}"
echo ""

# Start Execution
echo "${BG_MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo "${BG_MAGENTA}${BOLD}  🏗️  STARTING TERRAFORM MODULES DEPLOYMENT PIPELINE  🏗️${RESET}"
echo "${BG_MAGENTA}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# Clone Terraform Network Module
echo "${BLUE}${BOLD}📦 Step 4: Cloning Terraform Network Module${RESET}"
if [ -d "terraform-google-network" ]; then
  echo "${YELLOW}⚠️  Directory already exists, skipping clone${RESET}"
else
  git clone https://github.com/terraform-google-modules/terraform-google-network || {
    echo "${RED}❌ Failed to clone repository${RESET}"
    exit 1
  }
fi
cd terraform-google-network
git checkout tags/v6.0.1 -b v6.0.1
echo "${GREEN}✅ Network module ready${RESET}"
echo ""

# Configure Simple Project Example
echo "${BLUE}${BOLD}🔧 Step 5: Configuring VPC Network Example${RESET}"
cd ~/terraform-google-network/examples/simple_project

# Create configuration files
cat > variables.tf <<EOF
variable "project_id" {
  description = "The project ID to host the network in"
  default     = "$DEVSHELL_PROJECT_ID"
}

variable "network_name" {
  description = "The name of the VPC network being created"
  default     = "example-vpc"
}
EOF

cat > main.tf <<EOF
module "test-vpc-module" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 6.0"
  project_id   = var.project_id
  network_name = var.network_name
  mtu          = 1460

  subnets = [
    {
      subnet_name   = "subnet-01"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = "$REGION"
    },
    {
      subnet_name           = "subnet-02"
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = "$REGION"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    },
    {
      subnet_name               = "subnet-03"
      subnet_ip                 = "10.10.30.0/24"
      subnet_region             = "$REGION"
      subnet_flow_logs          = "true"
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling = 0.7
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
      subnet_flow_logs_filter   = "false"
    }
  ]
}
EOF

# Initialize and Apply Terraform
echo "${BLUE}${BOLD}🚀 Step 6: Deploying VPC Network${RESET}"
terraform init || {
  echo "${RED}❌ Terraform init failed${RESET}"
  exit 1
}

terraform apply -auto-approve || {
  echo "${RED}❌ Terraform apply failed${RESET}"
  exit 1
}
echo "${GREEN}✅ VPC network deployed${RESET}"
echo ""

# Clean up VPC
echo "${BLUE}${BOLD}🧹 Step 7: Cleaning Up VPC Resources${RESET}"
terraform destroy -auto-approve || {
  echo "${YELLOW}⚠️  Terraform destroy failed, attempting to continue${RESET}"
}
cd ~
rm -rf terraform-google-network
echo "${GREEN}✅ VPC resources cleaned up${RESET}"
echo ""

# Create GCS Static Website Module
echo "${BLUE}${BOLD}📁 Step 8: Creating GCS Static Website Module${RESET}"
mkdir -p modules/gcs-static-website-bucket
cd modules/gcs-static-website-bucket

# Create module files with enhanced configuration
cat > website.tf <<EOF
resource "google_storage_bucket" "bucket" {
  name          = "\${var.project_id}-\${var.name}"
  project       = var.project_id
  location      = var.location
  storage_class = var.storage_class
  labels        = var.labels
  force_destroy = var.force_destroy
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = var.versioning
  }

  website {
    main_page_suffix = "index.html"
    not_found_page   = "error.html"
  }
}
EOF

cat > variables.tf <<EOF
variable "name" {
  description = "The name suffix for the bucket (will be combined with project ID)"
  type        = string
  default     = "static-website"
}

variable "project_id" {
  description = "The ID of the project to create the bucket in"
  type        = string
}

variable "location" {
  description = "The location of the bucket"
  type        = string
  default     = "US"
}

variable "storage_class" {
  description = "The storage class of the bucket"
  type        = string
  default     = "STANDARD"
}

variable "labels" {
  description = "A map of labels to apply to the bucket"
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "When set to true, delete all objects when deleting bucket"
  type        = bool
  default     = false
}

variable "versioning" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}
EOF

# Create root configuration
cd ~
cat > main.tf <<EOF
module "gcs-static-website-bucket" {
  source     = "./modules/gcs-static-website-bucket"
  name       = "website"
  project_id = var.project_id
  location   = "US"
  
  labels = {
    environment = "test"
    owner       = "terraform"
  }
  
  force_destroy = true
}
EOF

cat > variables.tf <<EOF
variable "project_id" {
  description = "The ID of the project in which to provision resources"
  type        = string
  default     = "$DEVSHELL_PROJECT_ID"
}
EOF

# Deploy GCS Bucket with error handling
echo "${BLUE}${BOLD}🚀 Step 9: Deploying GCS Bucket${RESET}"
terraform init || {
  echo "${RED}❌ Terraform init failed${RESET}"
  exit 1
}

terraform apply -auto-approve || {
  echo "${RED}❌ Failed to create GCS bucket. Common issues:${RESET}"
  echo "${YELLOW}  • Bucket name may already be in use (globally unique names required)${RESET}"
  echo "${YELLOW}  • Insufficient permissions${RESET}"
  echo "${YELLOW}  • Invalid project ID${RESET}"
  exit 1
}
echo "${GREEN}✅ GCS bucket deployed successfully${RESET}"
echo ""

# Upload Website Files
echo "${BLUE}${BOLD}📤 Step 10: Uploading Website Files${RESET}"
BUCKET_NAME=$(terraform output -raw bucket_name 2>/dev/null || echo "$DEVSHELL_PROJECT_ID-website")

curl -s -O https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/main/Interact%20with%20Terraform%20Modules/index.html || {
  echo "${YELLOW}⚠️  Failed to download index.html${RESET}"
}

curl -s -O https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/main/Interact%20with%20Terraform%20Modules/error.html || {
  echo "${YELLOW}⚠️  Failed to download error.html${RESET}"
}

if [ -f "index.html" ] && [ -f "error.html" ]; then
  gsutil cp *.html gs://$BUCKET_NAME || {
    echo "${RED}❌ Failed to upload files to bucket${RESET}"
    exit 1
  }
  echo "${GREEN}✅ Website files uploaded successfully${RESET}"
else
  echo "${YELLOW}⚠️  Skipping file upload - required files not found${RESET}"
fi
echo ""

# Completion Message
echo "${BG_RED}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
echo "${BG_RED}${BOLD}║                                                          ║${RESET}"
echo "${BG_RED}${BOLD}║      🎉 TERRAFORM MODULES LAB COMPLETED! 🎉             ║${RESET}"
echo "${BG_RED}${BOLD}║                                                          ║${RESET}"
echo "${BG_RED}${BOLD}║   ✅ All modules deployed successfully!                  ║${RESET}"
echo "${BG_RED}${BOLD}║   🌟 You've mastered Terraform Modules!                 ║${RESET}"
echo "${BG_RED}${BOLD}║                                                          ║${RESET}"
echo "${BG_RED}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo "${GREEN}${BOLD}🎯 Congratulations on completing the lab!${RESET}"
echo ""
echo "${CYAN}${BOLD}📚 What you've learned:${RESET}"
echo "  ✅ Terraform Installation and Setup"
echo "  ✅ VPC Network Creation with Terraform Modules"
echo "  ✅ GCS Static Website Hosting"
echo "  ✅ Module Customization and Configuration"
echo "  ✅ Infrastructure as Code Best Practices"
echo ""
echo "${BLUE}${BOLD}🔗 Stay connected with Dr. Abhishek:${RESET}"
echo "${CYAN}  📺 YouTube Channel:${RESET} ${YELLOW}https://www.youtube.com/@drabhishek.5460${RESET}"
echo "${CYAN}  🎬 Video Tutorials:${RESET} ${YELLOW}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo "${CYAN}  📂 GitHub:${RESET} ${YELLOW}https://github.com/Itsabhishek7py/GoogleCloudSkillsboost${RESET}"
echo ""
echo "${MAGENTA}${BOLD}⭐ Don't forget to LIKE, SHARE & SUBSCRIBE! ⭐${RESET}"
echo "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
