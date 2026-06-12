#!/bin/bash
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

echo
echo "${CYAN_TEXT}${BOLD_TEXT}===================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}        LET'S DO IT TOGETHER     ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}===================================${RESET_FORMAT}"
echo

# Welcome message
echo "${MAGENTA_TEXT}${BOLD_TEXT}Welcome to Dr. Abhishek's Dataprep Lab Setup${RESET_FORMAT}"
echo "${CYAN_TEXT}For more data engineering tutorials: https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo

# Create ecommerce dataset
echo "${GREEN_TEXT}${BOLD_TEXT}Creating ecommerce dataset...${RESET_FORMAT}"
bq mk ecommerce
echo "${CYAN_TEXT}${BOLD_TEXT}Subscribe for more tutorials: https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo

# Create raw sessions table
echo "${GREEN_TEXT}${BOLD_TEXT}Creating all_sessions_raw_dataprep table...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
'#standardSQL
 CREATE OR REPLACE TABLE ecommerce.all_sessions_raw_dataprep
 OPTIONS(
   description="Raw data from analyst team to ingest into Cloud Dataprep"
 ) AS
 SELECT * FROM `data-to-insights.ecommerce.all_sessions_raw`
 WHERE date = "20170801";'
echo "${CYAN_TEXT}${BOLD_TEXT}Subscribe for more tutorials: https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo

echo
echo "${BLUE_TEXT}${BOLD_TEXT}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}🎥         NOW FOLLOW VIDEO STEPS         🎥${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}OPEN DATAPREP FROM THE FOLLOWING LINK:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}https://console.cloud.google.com/dataprep${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}DOWNLOAD FILE FROM THE FOLLOWING LINK:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}https://github.com/abhishekmsm51w-star/gcpbyabhi/raw/refs/heads/main/Creating%20a%20Data%20Transformation%20Pipeline%20with%20Cloud%20Dataprep/flow_Ecommerce_Analytics_Pipeline.zip${RESET_FORMAT}"

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}DO LIKE THE VIDEO & , SUBSCRIBE TO DR. ABHISHEK! 👇${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo
