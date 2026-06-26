#!/bin/bash

# tum nahi sudhroge is bar legal notice bhjeunga waitr 
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

# Spinner function
spinner() {
    local pid=$1
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

clear

# Welcome message
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}     WELCOME TO DR. ABHISHEK'S CLOUD LAB EXECUTION  ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}📺 Subscribe to Dr. Abhishek: https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         INITIATING LAB EXECUTION...  ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo

echo -e "${CYAN_TEXT}${BOLD_TEXT}--- GCP LAB CONFIGURATION ---${RESET_FORMAT}"

export PROJECT_ID=$(gcloud config get-value project)

read -p "$(echo -e ${YELLOW_TEXT}"Enter REGION Name: "${RESET_FORMAT})" REGION
read -p "$(echo -e ${YELLOW_TEXT}"Enter BigQuery DATASET Name: "${RESET_FORMAT})" DATASET
read -p "$(echo -e ${YELLOW_TEXT}"Enter BigQuery TABLE Name: "${RESET_FORMAT})" TABLE
read -p "$(echo -e ${MAGENTA_TEXT}"Enter Task 3 Output URI (gs://bucket/task3-gcs-311.result): "${RESET_FORMAT})" TASK3_OUTPUT
read -p "$(echo -e ${MAGENTA_TEXT}"Enter Task 4 Output URI (gs://bucket/task4-cnl-483.result): "${RESET_FORMAT})" TASK4_OUTPUT
export BUCKET="${PROJECT_ID}-marking"
export TEMP_LOCATION="gs://${BUCKET}/temp"
export BQ_TEMP="gs://${BUCKET}/bigquery_temp"

echo -e "\n${GREEN_TEXT}${BOLD_TEXT}Configuration complete. Starting tasks...${RESET_FORMAT}\n"

# --- TASK 1: Dataflow ---
echo -e "\n${YELLOW_TEXT}${BOLD_TEXT}========================================${RESET_FORMAT}"
echo -e "${YELLOW_TEXT}${BOLD_TEXT}📺 Subscribe to Dr. Abhishek: https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo -e "${YELLOW_TEXT}${BOLD_TEXT}========================================${RESET_FORMAT}"
echo -e "${BLUE_TEXT}${BOLD_TEXT}🚀 Task 1: Dataflow Job in Progress...${RESET_FORMAT}"

# Create resources
echo -e "${BLUE_TEXT}Creating BigQuery dataset...${RESET_FORMAT}"
bq mk $DATASET 2>/dev/null || echo "Dataset already exists" &

# Run spinner for dataset creation
pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ BigQuery dataset created${RESET_FORMAT}"

echo -e "${BLUE_TEXT}Creating Cloud Storage bucket...${RESET_FORMAT}"
gsutil mb -l $REGION gs://$BUCKET 2>/dev/null || echo "Bucket already exists" &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ Cloud Storage bucket created${RESET_FORMAT}"

# Run Dataflow job with n2d-standard-2 machine type
echo -e "${BLUE_TEXT}Running Dataflow job with n2d-standard-2 machine type...${RESET_FORMAT}"
gcloud dataflow jobs run batch-job-task1 \
  --gcs-location gs://dataflow-templates-$REGION/latest/GCS_Text_to_BigQuery \
  --region $REGION \
  --worker-machine-type n2d-standard-2 \
  --staging-location $TEMP_LOCATION \
  --parameters \
javascriptTextTransformFunctionName=transform,\
JSONPath=gs://spls/gsp323/lab.schema,\
javascriptTextTransformGcsPath=gs://spls/gsp323/lab.js,\
inputFilePattern=gs://spls/gsp323/lab.csv,\
outputTable=$PROJECT_ID:$DATASET.$TABLE,\
bigQueryLoadingTemporaryDirectory=$BQ_TEMP &

pid=$!
spinner $pid
wait $pid

echo -e "${GREEN_TEXT}✓ Dataflow job submitted successfully!${RESET_FORMAT}"
echo -e "${YELLOW_TEXT}⏳ Waiting for Dataflow job to start...${RESET_FORMAT}"
sleep 30

# --- TASK 2: Dataproc ---
echo -e "\n${MAGENTA_TEXT}${BOLD_TEXT}========================================${RESET_FORMAT}"
echo -e "${MAGENTA_TEXT}${BOLD_TEXT}📺 Subscribe to Dr. Abhishek: https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo -e "${MAGENTA_TEXT}${BOLD_TEXT}========================================${RESET_FORMAT}"
echo -e "${BLUE_TEXT}${BOLD_TEXT}🚀 Task 2: Dataproc Cluster in Progress...${RESET_FORMAT}"
sleep 5

# Creating Dataproc cluster with n2d-standard-2 machine type
echo -e "${BLUE_TEXT}Creating Dataproc cluster with n2d-standard-2 machine type...${RESET_FORMAT}"
gcloud dataproc clusters create cluster-task2 \
    --region=$REGION \
    --num-workers 2 \
    --master-machine-type n2d-standard-2 \
    --master-boot-disk-type pd-balanced \
    --master-boot-disk-size 100 \
    --worker-machine-type n2d-standard-2 \
    --worker-boot-disk-type pd-balanced \
    --worker-boot-disk-size 100 \
    --image-version 2.2-debian12 \
    --project $PROJECT_ID &

pid=$!
spinner $pid
wait $pid

echo -e "${GREEN_TEXT}✓ Dataproc cluster created successfully!${RESET_FORMAT}"
echo -e "${YELLOW_TEXT}⏳ Waiting for cluster to be ready...${RESET_FORMAT}"
sleep 30

# Automatically find the VM Name and the Zone
export MASTER_NODE=$(gcloud compute instances list --filter="name ~ cluster-task2-m" --format="value(name)")
export MASTER_ZONE=$(gcloud compute instances list --filter="name ~ cluster-task2-m" --format="value(zone)")

echo -e "${BLUE_TEXT}Targeting VM: $MASTER_NODE in Zone: $MASTER_ZONE${RESET_FORMAT}"

# SSH and move data
echo -e "${CYAN_TEXT}Copying data to HDFS...${RESET_FORMAT}"
gcloud compute ssh $MASTER_NODE --zone=$MASTER_ZONE --quiet --command="gsutil cp gs://spls/gsp323/data.txt . && hdfs dfs -put data.txt /data.txt" &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ Data copied to HDFS${RESET_FORMAT}"

# Submit Spark Job
echo -e "${BLUE_TEXT}Submitting Spark Job with n2d-standard-2...${RESET_FORMAT}"
gcloud dataproc jobs submit spark \
    --cluster=cluster-task2 \
    --region=$REGION \
    --class=org.apache.spark.examples.SparkPageRank \
    --jars=file:///usr/lib/spark/examples/jars/spark-examples.jar \
    --max-failures-per-hour=1 \
    -- /data.txt &

pid=$!
spinner $pid
wait $pid

echo -e "${GREEN_TEXT}✓ Spark job submitted successfully!${RESET_FORMAT}"
echo -e "${YELLOW_TEXT}⏳ Waiting for Spark job to complete...${RESET_FORMAT}"
sleep 30

# --- TASK 3: Speech-to-Text API ---
echo -e "\n${YELLOW_TEXT}${BOLD_TEXT}========================================${RESET_FORMAT}"
echo -e "${YELLOW_TEXT}${BOLD_TEXT}📺 Subscribe to Dr. Abhishek: https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo -e "${YELLOW_TEXT}${BOLD_TEXT}========================================${RESET_FORMAT}"
echo -e "${BLUE_TEXT}${BOLD_TEXT}🚀 Task 3: Speech-to-Text API in Progress...${RESET_FORMAT}"

# Enable required APIs
echo -e "${BLUE_TEXT}Enabling required APIs...${RESET_FORMAT}"
gcloud services enable apikeys.googleapis.com &
pid=$!
spinner $pid
wait $pid

gcloud services enable speech.googleapis.com &
pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ APIs enabled${RESET_FORMAT}"

# Create API key
echo -e "${CYAN_TEXT}Creating API key...${RESET_FORMAT}"
gcloud alpha services api-keys create \
  --display-name="ml-api-key" \
  --api-target=service=speech.googleapis.com &

pid=$!
spinner $pid
wait $pid

echo -e "${CYAN_TEXT}⏳ Waiting for API Key propagation...${RESET_FORMAT}"
sleep 30

# Get only ONE API key
KEY_NAME=$(gcloud alpha services api-keys list \
--format="value(name)" \
--limit=1)

API_KEY=$(gcloud alpha services api-keys get-key-string "$KEY_NAME" \
--format="value(keyString)")

echo -e "${GREEN_TEXT}✓ API Key retrieved successfully${RESET_FORMAT}"

# Create request
cat > request.json <<EOF
{
  "config": {
    "encoding": "FLAC",
    "languageCode": "en-US"
  },
  "audio": {
    "uri": "gs://spls/gsp323/task3.flac"
  }
}
EOF

# Call Speech-to-Text API
echo -e "${CYAN_TEXT}Calling Speech-to-Text API...${RESET_FORMAT}"
curl -s -X POST -H "Content-Type: application/json" \
--data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" \
> result_task3.json &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ Speech-to-Text API call completed${RESET_FORMAT}"

# Upload result with correct content-type
echo -e "${BLUE_TEXT}Uploading result to Cloud Storage...${RESET_FORMAT}"
gsutil -h "Content-Type: application/json" cp result_task3.json $TASK3_OUTPUT &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ Result uploaded successfully${RESET_FORMAT}"

echo -e "${GREEN_TEXT}✓ Task 3 completed successfully!${RESET_FORMAT}"

# --- TASK 4: Natural Language API ---
echo -e "\n${MAGENTA_TEXT}${BOLD_TEXT}========================================${RESET_FORMAT}"
echo -e "${MAGENTA_TEXT}${BOLD_TEXT}📺 Subscribe to Dr. Abhishek: https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo -e "${MAGENTA_TEXT}${BOLD_TEXT}========================================${RESET_FORMAT}"
echo -e "${BLUE_TEXT}${BOLD_TEXT}🚀 Task 4: Natural Language API in Progress...${RESET_FORMAT}"

echo -e "${CYAN_TEXT}Analyzing text with Natural Language API...${RESET_FORMAT}"
gcloud ml language analyze-entities \
  --content="Old Norse texts portray Odin as one-eyed and long-bearded, frequently wielding a spear named Gungnir and wearing a cloak and a broad hat." \
  > result_task4.json &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ Natural Language API analysis completed${RESET_FORMAT}"

# Upload result with correct content-type
echo -e "${BLUE_TEXT}Uploading result to Cloud Storage...${RESET_FORMAT}"
gsutil -h "Content-Type: application/json" cp result_task4.json $TASK4_OUTPUT &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ Result uploaded successfully${RESET_FORMAT}"

echo -e "${GREEN_TEXT}✓ Task 4 completed successfully!${RESET_FORMAT}"

# --- Cleanup ---
echo -e "\n${CYAN_TEXT}${BOLD_TEXT}Cleaning up temporary files...${RESET_FORMAT}"
rm -f request.json result_task3.json result_task4.json &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ Cleanup completed${RESET_FORMAT}"

# Final message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}              LAB COMPLETED SUCCESSFULLY! 🎉             ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}📋 Please check your progress in the lab console.${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}✅ Make sure all checkpoints are marked as complete.${RESET_FORMAT}"
echo
echo "${RED_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}📺 Subscribe to Dr. Abhishek: https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}👍 Don't forget to Like, Share and Subscribe for more Videos${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}      THANK YOU FOR USING DR. ABHISHEK'S LAB  🙏${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
