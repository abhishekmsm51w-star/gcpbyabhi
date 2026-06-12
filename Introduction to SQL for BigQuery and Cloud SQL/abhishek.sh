#!/bin/bash

# Color Definitions
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

# Display header with Dr. Abhishek branding
echo "${CYAN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${CYAN}${BOLD}         SQL for BigQuery and Cloud SQL Lab Setup         ${RESET}"
echo "${CYAN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${BLUE}${BOLD}          Tutorial by Dr. Abhishek                       ${RESET}"
echo "${YELLOW}For more GCP tutorials, visit: https://www.youtube.com/@drabhishek.5460${RESET}"
echo
echo "${YELLOW}${BOLD}Starting${RESET} ${GREEN}${BOLD}Execution${RESET}"
echo

# Set region interactively with free-form input
set_region() {
    echo "${MAGENTA}${BOLD}Please enter your preferred zone (e.g., us-central1, europe-west1, etc.):${RESET}"
    read -p "Zone: " REGION
    echo "${GREEN}Selected Zone: ${REGION}${RESET}"
    echo
}

# Create storage bucket
echo "${BLUE}${BOLD}Creating Cloud Storage bucket...${RESET}"
gsutil mb gs://$DEVSHELL_PROJECT_ID || {
    echo "${RED}Failed to create bucket${RESET}"
    exit 1
}

# Download CSV files from new source
echo "${BLUE}${BOLD}Downloading dataset files...${RESET}"
curl -O https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/refs/heads/main/Introduction%20to%20SQL%20for%20BigQuery%20and%20Cloud%20SQL/start_station_name.csv || {
    echo "${RED}Failed to download start_station_name.csv${RESET}"
    exit 1
}

curl -O https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/refs/heads/main/Introduction%20to%20SQL%20for%20BigQuery%20and%20Cloud%20SQL/end_station_name.csv || {
    echo "${RED}Failed to download end_station_name.csv${RESET}"
    exit 1
}

# Upload to bucket
echo "${BLUE}${BOLD}Uploading files to bucket...${RESET}"
gsutil cp start_station_name.csv gs://$DEVSHELL_PROJECT_ID/ || {
    echo "${RED}Failed to upload start_station_name.csv${RESET}"
    exit 1
}

gsutil cp end_station_name.csv gs://$DEVSHELL_PROJECT_ID/ || {
    echo "${RED}Failed to upload end_station_name.csv${RESET}"
    exit 1
}

# Set region interactively
set_region

# Create Cloud SQL instance
echo "${BLUE}${BOLD}Creating Cloud SQL instance...${RESET}"
gcloud sql instances create my-demo \
    --database-version=MYSQL_8_0 \
    --region=$REGION \
    --tier=db-f1-micro \
    --root-password=abhishek || {
    echo "${RED}Failed to create Cloud SQL instance${RESET}"
    exit 1
}

# Create database
echo "${BLUE}${BOLD}Creating bike database...${RESET}"
gcloud sql databases create bike --instance=my-demo || {
    echo "${RED}Failed to create database${RESET}"
    exit 1
}

# Completion message
echo
echo "${GREEN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${GREEN}${BOLD}             Lab Completed Successfully!                ${RESET}"
echo "${GREEN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${RED}${BOLD}🙏 Thank you for following Dr. Abhishek's tutorial!${RESET}"
echo "${YELLOW}${BOLD}📺 Subscribe for more GCP content:${RESET}"
echo "${BLUE}https://www.youtube.com/@drabhishek.5460${RESET}"
echo

# Cleanup
rm -f start_station_name.csv end_station_name.csv

#-----------------------------------------------------end----------------------------------------------------------#
