#!/bin/bash

# Color definitions
BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

# Get current project ID
export PROJECT_ID=$(gcloud config get-value project)

# Zone selection/export
echo "${CYAN}${BOLD}Select or enter your zone:${RESET}"
echo "1) us-central1-a (Default)"
echo "2) us-east1-b"
echo "3) europe-west1-b"
echo "4) asia-southeast1-a"
echo "5) Enter custom zone"

read -p "Choose option [1-5] or type your zone directly: " zone_input

# Check if the input is a number for menu selection
if [[ "$zone_input" =~ ^[1-5]$ ]]; then
    case $zone_input in
        1) export ZONE="us-central1-a" ;;
        2) export ZONE="us-east1-b" ;;
        3) export ZONE="europe-west1-b" ;;
        4) export ZONE="asia-southeast1-a" ;;
        5) read -p "Enter your custom zone (e.g. us-central1-a): " ZONE ;;
    esac
else
    # If not a menu number, treat as direct zone input
    export ZONE="$zone_input"
fi

echo "${GREEN}Zone set to: ${WHITE}${BOLD}$ZONE${RESET}"

# Verify zone exists
if ! gcloud compute zones describe $ZONE --quiet >/dev/null 2>&1; then
    echo "${RED}${BOLD}Error: Zone $ZONE is not valid or not available in your project${RESET}"
    exit 1
fi

# Display current auth
gcloud auth list

# Create infrastructure directory
mkdir -p tfinfra
cd tfinfra

# Download Terraform files
echo "${YELLOW}${BOLD}Downloading Terraform configuration files...${RESET}"
wget -q https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/main/Automating%20the%20Deployment%20of%20Infrastructure%20Using%20Terraform/provider.tf
wget -q https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/main/Automating%20the%20Deployment%20of%20Infrastructure%20Using%20Terraform/terraform.tfstate
wget -q https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/main/Automating%20the%20Deployment%20of%20Infrastructure%20Using%20Terraform/variables.tf
wget -q https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/main/Automating%20the%20Deployment%20of%20Infrastructure%20Using%20Terraform/mynetwork.tf

# Create instance directory and download main.tf
mkdir -p instance
cd instance
wget -q https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/main/Automating%20the%20Deployment%20of%20Infrastructure%20Using%20Terraform/main.tf
cd ..

# Initialize Terraform
echo "${YELLOW}${BOLD}Initializing Terraform...${RESET}"
terraform init

# Format Terraform files
echo "${YELLOW}${BOLD}Formatting Terraform configuration...${RESET}"
terraform fmt

# Plan and Apply
echo "${YELLOW}${BOLD}Planning Terraform deployment...${RESET}"
echo -e "mynet-us-vm\nmynetwork\n$ZONE" | terraform plan -var="instance_name=$(</dev/stdin)" -var="instance_network=$(</dev/stdin)" -var="instance_zone=$(</dev/stdin)"

echo "${YELLOW}${BOLD}Applying Terraform configuration...${RESET}"
echo -e "mynet-us-vm\nmynetwork\n$ZONE" | terraform apply -var="instance_name=$(</dev/stdin)" -var="instance_network=$(</dev/stdin)" -var="instance_zone=$(</dev/stdin)" --auto-approve

# Completion message
echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"
echo "${CYAN}${BOLD}Remember to subscribe to Dr. Abhishek's YouTube channel:${RESET}"
echo "${BLUE}${BOLD}https://www.youtube.com/@drabhishek.5460${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
