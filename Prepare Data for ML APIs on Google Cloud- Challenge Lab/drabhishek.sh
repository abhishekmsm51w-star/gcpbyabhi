#!/bin/bash

# Color Definitions
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

clear

# Welcome message
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}     Subscribe to Dr. Abhishek: https://www.youtube.com/@drabhishek.5460/videos     ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo

echo -e "${CYAN_TEXT}${BOLD_TEXT}--- GCP LAB CONFIGURATION ---${RESET_FORMAT}"
export PROJECT_ID=$(gcloud config get-value project)

read -p "$(echo -e ${YELLOW_TEXT}"Enter REGION Name: "${RESET_FORMAT})" REGION
read -p "$(echo -e ${YELLOW_TEXT}"Enter BigQuery DATASET Name: "${RESET_FORMAT})" DATASET
read -p "$(echo -e ${YELLOW_TEXT}"Enter BigQuery TABLE Name: "${RESET_FORMAT})" TABLE
read -p "$(echo -e ${MAGENTA_TEXT}"Enter Task 3 Output URI (gs://bucket/path/result.json): "${RESET_FORMAT})" TASK3_OUTPUT
read -p "$(echo -e ${MAGENTA_TEXT}"Enter Task 4 Output URI (gs://bucket/path/result.json): "${RESET_FORMAT})" TASK4_OUTPUT

export BUCKET="${PROJECT_ID}-marking"
export TEMP_LOCATION="gs://${BUCKET}/temp"
export BQ_TEMP="gs://${BUCKET}/bigquery_temp"

echo -e "\n${GREEN_TEXT}${BOLD_TEXT}Configuration complete. Starting execution...${RESET_FORMAT}\n"

# --- TASK 1: Dataflow ---
echo -e "\n${YELLOW_TEXT}${BOLD_TEXT}Starting Task 1: Dataflow...${RESET_FORMAT}"

# Create resources
echo "${BLUE_TEXT}Creating BigQuery dataset and Cloud Storage bucket...${RESET_FORMAT}"
bq mk $DATASET 2>/dev/null || echo "Dataset already exists"
gsutil mb -l $REGION gs://$BUCKET 2>/dev/null || echo "Bucket already exists"

# Create the BigQuery table with schema
echo "${BLUE_TEXT}Creating BigQuery table with schema...${RESET_FORMAT}"
bq mk --table $DATASET.$TABLE \
'[
    {"type":"STRING","name":"guid"},
    {"type":"BOOLEAN","name":"isActive"},
    {"type":"STRING","name":"firstname"},
    {"type":"STRING","name":"surname"},
    {"type":"STRING","name":"company"},
    {"type":"STRING","name":"email"},
    {"type":"STRING","name":"phone"},
    {"type":"STRING","name":"address"},
    {"type":"STRING","name":"about"},
    {"type":"TIMESTAMP","name":"registered"},
    {"type":"FLOAT","name":"latitude"},
    {"type":"FLOAT","name":"longitude"}
]' 2>/dev/null || echo "Table already exists"

# Run Dataflow job
echo "${BLUE_TEXT}Running Dataflow job...${RESET_FORMAT}"
gcloud dataflow jobs run batch-job-task1 \
  --gcs-location gs://dataflow-templates-$REGION/latest/GCS_Text_to_BigQuery \
  --region $REGION \
  --worker-machine-type e2-standard-2 \
  --staging-location $TEMP_LOCATION \
  --parameters \
    javascriptTextTransformFunctionName=transform,\
    JSONPath=gs://spls/gsp323/lab.schema,\
    javascriptTextTransformGcsPath=gs://spls/gsp323/lab.js,\
    inputFilePattern=gs://spls/gsp323/lab.csv,\
    outputTable=$PROJECT_ID:$DATASET.$TABLE,\
    bigQueryLoadingTemporaryDirectory=$BQ_TEMP

echo "${GREEN_TEXT}Task 1: Dataflow job submitted successfully!${RESET_FORMAT}"

# --- TASK 2: Dataproc ---
echo -e "\n${MAGENTA_TEXT}${BOLD_TEXT}Starting Task 2: Dataproc Cluster Creation...${RESET_FORMAT}"
sleep 10

# Create Dataproc cluster
echo "${BLUE_TEXT}Creating Dataproc cluster...${RESET_FORMAT}"
gcloud dataproc clusters create cluster-task2 \
    --region=$REGION \
    --num-workers 2 \
    --master-machine-type e2-standard-2 \
    --master-boot-disk-type pd-balanced \
    --master-boot-disk-size 100 \
    --worker-machine-type e2-standard-2 \
    --worker-boot-disk-type pd-balanced \
    --worker-boot-disk-size 100 \
    --image-version 2.0-debian10 \
    --project $PROJECT_ID

echo "${GREEN_TEXT}Dataproc cluster created successfully!${RESET_FORMAT}"
sleep 10

# Automatically find the VM Name and the Zone
export MASTER_NODE=$(gcloud compute instances list --filter="name ~ cluster-task2-m" --format="value(name)")
export MASTER_ZONE=$(gcloud compute instances list --filter="name ~ cluster-task2-m" --format="value(zone)")

echo -e "${BLUE_TEXT}Targeting VM: $MASTER_NODE in Zone: $MASTER_ZONE${RESET_FORMAT}"

# SSH and move data
echo "${BLUE_TEXT}Copying data to HDFS...${RESET_FORMAT}"
gcloud compute ssh $MASTER_NODE --zone=$MASTER_ZONE --quiet --command="gsutil cp gs://spls/gsp323/data.txt . && hdfs dfs -put data.txt /data.txt"

# Submit Spark Job
echo "${BLUE_TEXT}Submitting Spark Job...${RESET_FORMAT}"
gcloud dataproc jobs submit spark \
    --cluster=cluster-task2 \
    --region=$REGION \
    --class=org.apache.spark.examples.SparkPageRank \
    --jars=file:///usr/lib/spark/examples/jars/spark-examples.jar \
    --max-failures-per-hour=1 \
    -- /data.txt

echo "${GREEN_TEXT}Task 2: Spark job submitted successfully!${RESET_FORMAT}"

# --- TASK 3: Speech-to-Text API with API Restriction ---
echo -e "\n${YELLOW_TEXT}${BOLD_TEXT}Starting Task 3: Speech-to-Text...${RESET_FORMAT}"

# Enable required APIs
echo "${BLUE_TEXT}Enabling required APIs...${RESET_FORMAT}"
gcloud services enable apikeys.googleapis.com
gcloud services enable speech.googleapis.com

# Create API key with mandatory target restriction for Speech-to-Text
echo "${BLUE_TEXT}Creating API key with Speech-to-Text restriction...${RESET_FORMAT}"
gcloud alpha services api-keys create --display-name="ml-api-key" \
    --api-target=service=speech.googleapis.com

echo -e "${CYAN_TEXT}Waiting for API Key propagation...${RESET_FORMAT}"
sleep 30

# Find and get the API Key using correct uppercase displayName filter
KEY_NAME=$(gcloud alpha services api-keys list \
    --format="value(name)" \
    --filter="displayName=ml-api-key" \
    --limit=1)

API_KEY=$(gcloud alpha services api-keys get-key-string "$KEY_NAME" \
    --format="value(keyString)")

# Create request JSON
echo "${BLUE_TEXT}Creating Speech-to-Text request...${RESET_FORMAT}"
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
echo "${BLUE_TEXT}Calling Speech-to-Text API...${RESET_FORMAT}"
curl -s -X POST -H "Content-Type: application/json" \
    --data-binary @request.json \
    "https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" \
    > result_task3.json

# Upload result with correct content-type using modern gcloud storage syntax
echo "${BLUE_TEXT}Uploading result to Cloud Storage...${RESET_FORMAT}"
gcloud storage cp --content-type="application/json" result_task3.json $TASK3_OUTPUT

echo "${GREEN_TEXT}Task 3: Speech-to-Text completed successfully!${RESET_FORMAT}"

# --- TASK 4: Natural Language API ---
echo -e "\n${YELLOW_TEXT}${BOLD_TEXT}Starting Task 4: Natural Language...${RESET_FORMAT}"

# Call Natural Language API
echo "${BLUE_TEXT}Analyzing entities with Natural Language API...${RESET_FORMAT}"
gcloud ml language analyze-entities --content="Old Norse texts portray Odin as one-eyed and long-bearded, frequently wielding a spear named Gungnir and wearing a cloak and a broad hat." > result_task4.json

# Upload result
echo "${BLUE_TEXT}Uploading result to Cloud Storage...${RESET_FORMAT}"
gcloud storage cp --content-type="application/json" result_task4.json $TASK4_OUTPUT

echo "${GREEN_TEXT}Task 4: Natural Language completed successfully!${RESET_FORMAT}"

# --- Completion Message ---
echo
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}               LAB COMPLETED SUCCESSFULLY!                       ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Subscribe to Dr. Abhishek: https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}Don't forget to Like, Share and Subscribe for more videos!${RESET_FORMAT}"
echo
