#!/bin/bash
# Define color variables

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

# Array of color codes excluding black and white
TEXT_COLORS=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)
BG_COLORS=($BG_RED $BG_GREEN $BG_YELLOW $BG_BLUE $BG_MAGENTA $BG_CYAN)

# Pick random colors
RANDOM_TEXT_COLOR=${TEXT_COLORS[$RANDOM % ${#TEXT_COLORS[@]}]}
RANDOM_BG_COLOR=${BG_COLORS[$RANDOM % ${#BG_COLORS[@]}]}

#----------------------------------------------------start--------------------------------------------------#

# Header with 
echo "${CYAN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${CYAN}${BOLD}        Welcome to Dr abhishek Cloud tutorials       ${RESET}"
echo "${CYAN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${BLUE}${BOLD}          Tutorial by Dr. Abhishek                       ${RESET}"
echo "${YELLOW}For more GCP tutorials, visit: https://www.youtube.com/@drabhishek.5460${RESET}"
echo
echo "${RANDOM_BG_COLOR}${RANDOM_TEXT_COLOR}${BOLD}Starting Execution${RESET}"

# Step 1: Enable Cloud Run API
echo "${CYAN}${BOLD}Enabling Cloud Run API...${RESET}"
gcloud services enable run.googleapis.com

# Step 2: Clone the repository
echo "${GREEN}${BOLD}Cloning Google Cloud generative AI repository...${RESET}"
git clone https://github.com/GoogleCloudPlatform/generative-ai.git

# Step 3: Navigate to the required directory
echo "${YELLOW}${BOLD}Navigating to the 'gemini-streamlit-cloudrun' directory...${RESET}"
cd generative-ai/gemini/sample-apps/gemini-streamlit-cloudrun

# Step 4: Remove existing files
echo "${BLUE}${BOLD}Removing existing files: Dockerfile, chef.py, requirements.txt...${RESET}"
rm -rf Dockerfile chef.py requirements.txt

# Step 5: Download required files from updated URLs
echo "${RED}${BOLD}Downloading required files...${RESET}"
wget https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/main/Develop%20GenAI%20Apps%20with%20Gemini%20and%20Streamlit%20Challenge%20Lab/chef.py
wget https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/main/Develop%20GenAI%20Apps%20with%20Gemini%20and%20Streamlit%20Challenge%20Lab/Dockerfile
wget https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/main/Develop%20GenAI%20Apps%20with%20Gemini%20and%20Streamlit%20Challenge%20Lab/requirements.txt

# Step 6: Upload chef.py to the Cloud Storage bucket
echo "${CYAN}${BOLD}Uploading 'chef.py' to Cloud Storage bucket...${RESET}"
gcloud storage cp chef.py gs://$DEVSHELL_PROJECT_ID-generative-ai/

# Step 7: Set project and region variables
echo "${GREEN}${BOLD}Setting GCP project and region variables...${RESET}"
GCP_PROJECT=$(gcloud config get-value project)
GCP_REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

# Step 8: Create a virtual environment and install dependencies
echo "${YELLOW}${BOLD}Setting up Python virtual environment...${RESET}"
python3 -m venv gemini-streamlit
source gemini-streamlit/bin/activate
python3 -m pip install -r requirements.txt

# Step 9: Start Streamlit application
echo "${MAGENTA}${BOLD}Running Streamlit application in the background...${RESET}"
nohup streamlit run chef.py \
  --browser.serverAddress=localhost \
  --server.enableCORS=false \
  --server.enableXsrfProtection=false \
  --server.port 8080 > streamlit.log 2>&1 &

# Step 10: Create Artifact Repository
echo "${BLUE}${BOLD}Creating Artifact Registry repository...${RESET}"
AR_REPO='chef-repo'
SERVICE_NAME='chef-streamlit-app' 
gcloud artifacts repositories create "$AR_REPO" --location="$GCP_REGION" --repository-format=Docker

# Step 11: Submit Cloud Build
echo "${RED}${BOLD}Submitting Cloud Build...${RESET}"
gcloud builds submit --tag "$GCP_REGION-docker.pkg.dev/$GCP_PROJECT/$AR_REPO/$SERVICE_NAME"

# Step 12: Deploy Cloud Run Service
echo "${CYAN}${BOLD}Deploying Cloud Run service...${RESET}"
gcloud run deploy "$SERVICE_NAME" \
  --port=8080 \
  --image="$GCP_REGION-docker.pkg.dev/$GCP_PROJECT/$AR_REPO/$SERVICE_NAME" \
  --allow-unauthenticated \
  --region=$GCP_REGION \
  --platform=managed  \
  --project=$GCP_PROJECT \
  --set-env-vars=GCP_PROJECT=$GCP_PROJECT,GCP_REGION=$GCP_REGION

# Step 13: Get Cloud Run Service URL
echo "${GREEN}${BOLD}Fetching Cloud Run service URL...${RESET}"
CLOUD_RUN_URL=$(gcloud run services describe "$SERVICE_NAME" --region="$GCP_REGION" --format='value(status.url)')

echo
echo "${YELLOW}${BOLD}Streamlit running at: ${RESET}""http://localhost:8080"
echo
echo "${MAGENTA}${BOLD}Cloud Run Service is available at: ${RESET}""$CLOUD_RUN_URL"
echo

# Completion message with Dr. Abhishek branding
echo "${GREEN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${GREEN}${BOLD}             Lab Completed Successfully!                ${RESET}"
echo "${GREEN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${RED}${BOLD}🙏 Thank you for following Dr. Abhishek's tutorial!${RESET}"
echo "${YELLOW}${BOLD}📺 Subscribe for more GCP content:${RESET}"
echo "${BLUE}https://www.youtube.com/@drabhishek.5460${RESET}"
echo

# Cleanup function
remove_files() {
    # Loop through all files in the current directory
    for file in *; do
        # Check if the file name starts with "gsp", "arc", or "shell"
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            # Check if it's a regular file (not a directory)
            if [[ -f "$file" ]]; then
                # Remove the file and echo the file name
                rm "$file"
                echo "File removed: $file"
            fi
        fi
    done
}

# Execute cleanup
remove_files
cd
