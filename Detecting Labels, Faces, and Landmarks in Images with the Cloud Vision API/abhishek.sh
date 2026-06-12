#!/bin/bash

# ==============================================
#  Cloud Vision API
#  Created by Dr. Abhishek Cloud Tutorials
#  YouTube: https://www.youtube.com/@drabhishek.5460
# ==============================================

# Text styles and colors
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Header
echo
echo "${BLUE}${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo "${BLUE}${BOLD}║   CLOUD VISION API DEMO SETUP           ║${RESET}"
echo "${BLUE}${BOLD}║        by Dr. Abhishek Cloud           ║${RESET}"
echo "${BLUE}${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo

# Initialize environment
echo "${YELLOW}${BOLD}🔧 Initializing environment...${RESET}"
gcloud auth list

# Create API Key
echo "${YELLOW}${BOLD}🔑 Creating API Key...${RESET}"
gcloud alpha services api-keys create --display-name="vision-demo" > /dev/null 2>&1
KEY_NAME=$(gcloud alpha services api-keys list --format="value(name)" --filter "displayName=vision-demo")
export API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_NAME --format="value(keyString)")
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')

echo "${GREEN}✓ API Key created: ${API_KEY}${RESET}"
echo "${GREEN}✓ Project ID: ${PROJECT_ID}${RESET}"

# Create storage bucket
echo "${YELLOW}${BOLD}📦 Creating storage bucket...${RESET}"
gsutil mb gs://$PROJECT_ID > /dev/null 2>&1
echo "${GREEN}✓ Bucket created: gs://${PROJECT_ID}${RESET}"

# Download sample images
echo "${YELLOW}${BOLD}🌄 Downloading sample images...${RESET}"

# Updated GitHub URLs
declare -A IMAGES=(
    ["city.png"]="https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/5c7847c58b86b282a6e6598f725b6a9b1ef03e95/Detecting%20Labels%2C%20Faces%2C%20and%20Landmarks%20in%20Images%20with%20the%20Cloud%20Vision%20API/city.png"
    ["donuts.png"]="https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/main/Detecting%20Labels%2C%20Faces%2C%20and%20Landmarks%20in%20Images%20with%20the%20Cloud%20Vision%20API/donuts.png"
    ["selfie.png"]="https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/5c7847c58b86b282a6e6598f725b6a9b1ef03e95/Detecting%20Labels%2C%20Faces%2C%20and%20Landmarks%20in%20Images%20with%20the%20Cloud%20Vision%20API/selfie.png"
)

for filename in "${!IMAGES[@]}"; do
    echo "${YELLOW}➜ Downloading ${filename}...${RESET}"
    curl -L -o "$filename" "${IMAGES[$filename]}" > /dev/null 2>&1 && \
    echo "${GREEN}✓ Downloaded ${filename}${RESET}" || \
    echo "${RED}✗ Failed to download ${filename}${RESET}"
done

# Upload to Cloud Storage
echo "${YELLOW}${BOLD}☁️ Uploading images to Cloud Storage...${RESET}"
for filename in "${!IMAGES[@]}"; do
    if [ -f "$filename" ]; then
        gsutil cp "$filename" gs://$PROJECT_ID/ > /dev/null 2>&1 && \
        echo "${GREEN}✓ Uploaded ${filename}${RESET}" || \
        echo "${RED}✗ Failed to upload ${filename}${RESET}"
    fi
done

# Make images publicly accessible
echo "${YELLOW}${BOLD}🔓 Setting public access...${RESET}"
for filename in "${!IMAGES[@]}"; do
    gcloud storage objects update gs://$PROJECT_ID/"$filename" --add-acl-grant=entity=AllUsers,role=READER > /dev/null 2>&1 && \
    echo "${GREEN}✓ Made ${filename} public${RESET}" || \
    echo "${RED}✗ Failed to make ${filename} public${RESET}"
done

# Final output
echo
echo "${BLUE}${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo "${BLUE}${BOLD}║        SETUP COMPLETED SUCCESSFULLY     ║${RESET}"
echo "${BLUE}${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo
echo "${BOLD}Access your images at:${RESET}"
for filename in "${!IMAGES[@]}"; do
    echo "  ${BLUE}https://storage.googleapis.com/${PROJECT_ID}/${filename}${RESET}"
done
echo
echo "${YELLOW}${BOLD}For more cloud tutorials, subscribe to:${RESET}"
echo "${BLUE}https://www.youtube.com/@drabhishek.5460${RESET}"
echo
