#!/bin/bash

# Define color variables
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

# Clear screen and show welcome message
clear

echo "${BLUE_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}        Welcome to Dr. Abhishek's Cloud Tutorials         ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo

# Function to show spinner while commands run
show_spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Set Project ID
echo "${YELLOW_TEXT}${BOLD_TEXT}🔧 Setting project ID...${RESET_FORMAT}"
gcloud config set project $DEVSHELL_PROJECT_ID & show_spinner
echo "${GREEN_TEXT}✅ Project ID set to: ${WHITE_TEXT}${BOLD_TEXT}$DEVSHELL_PROJECT_ID${RESET_FORMAT}"
echo

# Create Firestore Database
echo "${YELLOW_TEXT}${BOLD_TEXT}🗄️  Creating Firestore database in nam5 region...${RESET_FORMAT}"
(gcloud firestore databases create --location=nam5 --quiet) & show_spinner
echo "${GREEN_TEXT}✅ Firestore database created successfully!${RESET_FORMAT}"
echo

# Clone Repository
echo "${YELLOW_TEXT}${BOLD_TEXT}📥 Cloning the pet-theory repository...${RESET_FORMAT}"
if [ -d "pet-theory" ]; then
    echo "${CYAN_TEXT}Repository already exists. Pulling latest changes...${RESET_FORMAT}"
    (cd pet-theory && git pull) & show_spinner
else
    (git clone https://github.com/rosera/pet-theory.git) & show_spinner
fi
echo "${GREEN_TEXT}✅ Repository ready!${RESET_FORMAT}"
echo

# Navigate to Directory
echo "${YELLOW_TEXT}${BOLD_TEXT}📁 Navigating to lab directory...${RESET_FORMAT}"
cd pet-theory/lab01 || { echo "${RED_TEXT}❌ Failed to navigate to directory!${RESET_FORMAT}"; exit 1; }
echo "${GREEN_TEXT}✅ Current directory: ${WHITE_TEXT}${BOLD_TEXT}$(pwd)${RESET_FORMAT}"
echo

# Install required packages
echo "${YELLOW_TEXT}${BOLD_TEXT}📦 Installing required Node.js packages...${RESET_FORMAT}"
echo "${CYAN_TEXT}Installing @google-cloud/firestore...${RESET_FORMAT}"
(npm install @google-cloud/firestore) & show_spinner
echo "${CYAN_TEXT}Installing @google-cloud/logging...${RESET_FORMAT}"
(npm install @google-cloud/logging) & show_spinner
echo "${CYAN_TEXT}Installing faker@5.5.3...${RESET_FORMAT}"
(npm install faker@5.5.3) & show_spinner
echo "${CYAN_TEXT}Installing csv-parse...${RESET_FORMAT}"
(npm install csv-parse) & show_spinner
echo "${GREEN_TEXT}✅ All packages installed successfully!${RESET_FORMAT}"
echo

# Download required scripts
echo "${YELLOW_TEXT}${BOLD_TEXT}📄 Downloading required scripts...${RESET_FORMAT}"
echo "${CYAN_TEXT}Downloading importTestData.js...${RESET_FORMAT}"
(curl -s https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/refs/heads/main/Importing%20Data%20to%20a%20Firestore%20Database/importTestData.js > importTestData.js) & show_spinner
echo "${CYAN_TEXT}Downloading createTestData.js...${RESET_FORMAT}"
(curl -s https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/refs/heads/main/Importing%20Data%20to%20a%20Firestore%20Database/createTestData.js > createTestData.js) & show_spinner
echo "${GREEN_TEXT}✅ Scripts downloaded successfully!${RESET_FORMAT}"
echo

# Create and import test data
echo "${YELLOW_TEXT}${BOLD_TEXT}🧪 Generating and importing test data...${RESET_FORMAT}"
echo "${CYAN_TEXT}Creating 1000 test records...${RESET_FORMAT}"
(node createTestData 1000) & show_spinner
echo "${CYAN_TEXT}Importing 1000 records to Firestore...${RESET_FORMAT}"
(node importTestData customers_1000.csv) & show_spinner
echo "${CYAN_TEXT}Creating 20000 test records...${RESET_FORMAT}"
(node createTestData 20000) & show_spinner
echo "${CYAN_TEXT}Importing 20000 records to Firestore...${RESET_FORMAT}"
(node importTestData customers_20000.csv) & show_spinner
echo "${GREEN_TEXT}✅ Test data generation and import completed!${RESET_FORMAT}"
echo

# Completion message
echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}              Lab Completed Successfully!               ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💖 If you found this helpful, subscribe to my channel:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo
