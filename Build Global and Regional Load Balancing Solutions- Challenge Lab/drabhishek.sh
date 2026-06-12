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
TEAL=$'\033[38;5;50m'
ORANGE_TEXT=$'\033[38;5;208m'

# Define text formatting variables
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'
BLINK_TEXT=$'\033[5m'
NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
REVERSE_TEXT=$'\033[7m'

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

# Function to run command with spinner
run_with_spinner() {
    local message="$1"
    shift
    echo -n "${YELLOW_TEXT}${BOLD_TEXT}$message${RESET_FORMAT}"
    "$@" > /dev/null 2>&1 &
    local pid=$!
    spinner $pid
    wait $pid
    if [ $? -eq 0 ]; then
        echo -e "${GREEN_TEXT} ✓ Done${RESET_FORMAT}"
    else
        echo -e "${RED_TEXT} ✗ Failed${RESET_FORMAT}"
    fi
}

# Function to run command with output
run_with_output() {
    local message="$1"
    shift
    echo -e "${ORANGE_TEXT}${BOLD_TEXT}$message${RESET_FORMAT}"
    "$@"
}

clear

# Welcome message
echo "${ORANGE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}           WELCOME TO DR. ABHISHEK GUIDE${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}                SUBSCRIBE n LIKE THE VIDEO JI${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo

read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter REGION_A: ${RESET_FORMAT}" REGION_A
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter REGION_B: ${RESET_FORMAT}" REGION_B

echo "export REGION_A=$REGION_A" >> ~/.bashrc
echo "export REGION_B=$REGION_B" >> ~/.bashrc
source ~/.bashrc

echo -e "${GREEN_TEXT}REGION_A=$REGION_A${RESET_FORMAT}"
echo -e "${GREEN_TEXT}REGION_B=$REGION_B${RESET_FORMAT}"

# Create MIG A
run_with_output "\nCreating MIG A..." \
    gcloud compute instance-groups managed create mig-alb-api-a \
    --template=template-alb-api \
    --size=1 \
    --region=$REGION_A

run_with_spinner "Setting named ports for MIG A..." \
    gcloud compute instance-groups managed set-named-ports mig-alb-api-a \
    --named-ports=http80:80 \
    --region=$REGION_A

# Create MIG B
run_with_output "Creating MIG B..." \
    gcloud compute instance-groups managed create mig-alb-api-b \
    --template=template-alb-api \
    --size=1 \
    --region=$REGION_B

run_with_spinner "Setting named ports for MIG B..." \
    gcloud compute instance-groups managed set-named-ports mig-alb-api-b \
    --named-ports=http80:80 \
    --region=$REGION_B

# Wait for MIGs to initialize
echo -e "${YELLOW_TEXT}${BOLD_TEXT}Waiting for MIGs to initialize...${RESET_FORMAT}"
sleep 120

# Create Firewall Rule
run_with_output "\nCreating Firewall Rule..." \
    gcloud compute firewall-rules create fw-allow-health-check-and-proxy \
    --network=default \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=tag-alb-api

# Create Health Check
run_with_output "Creating Health Check..." \
    gcloud compute health-checks create http http-check-alb \
    --global \
    --port=80

# Create Backend Service
run_with_output "Creating Backend Service..." \
    gcloud compute backend-services create service-alb-global \
    --global \
    --protocol=HTTP \
    --health-checks=http-check-alb \
    --port-name=http80

# Adding Backends
run_with_output "Adding Backends..." \
    gcloud compute backend-services add-backend service-alb-global \
    --global \
    --instance-group=mig-alb-api-a \
    --instance-group-region=$REGION_A \
    --balancing-mode=RATE \
    --max-rate-per-instance=1

run_with_spinner "Adding backend for region B..." \
    gcloud compute backend-services add-backend service-alb-global \
    --global \
    --instance-group=mig-alb-api-b \
    --instance-group-region=$REGION_B \
    --balancing-mode=RATE \
    --max-rate-per-instance=1

echo -e "${YELLOW_TEXT}${BOLD_TEXT}Waiting for backend initialization...${RESET_FORMAT}"
sleep 60

# Generate SSL Certificate
run_with_output "\nGenerating SSL Certificate..." \
    openssl genrsa -out key.pem 2048

openssl req -new -x509 \
    -key key.pem \
    -out cert.pem \
    -days 1 \
    -subj "/CN=example.com"

run_with_spinner "Creating SSL certificate..." \
    gcloud compute ssl-certificates create cert-self-signed \
    --certificate=cert.pem \
    --private-key=key.pem \
    --global

# Create Global IP
run_with_output "Creating Global IP..." \
    gcloud compute addresses create ip-alb-global \
    --global

# Create URL Map
run_with_output "Creating URL Map..." \
    gcloud compute url-maps create url-map-alb \
    --default-service=service-alb-global

# Create HTTPS Proxy
run_with_output "Creating HTTPS Proxy..." \
    gcloud compute target-https-proxies create https-proxy-alb \
    --url-map=url-map-alb \
    --ssl-certificates=cert-self-signed

# Create Forwarding Rule
run_with_output "Creating Forwarding Rule..." \
    gcloud compute forwarding-rules create https-forwarding-rule \
    --global \
    --target-https-proxy=https-proxy-alb \
    --ports=443 \
    --address=ip-alb-global

# Check Backend Health
echo -e "${MAGENTA_TEXT}${BOLD_TEXT}Checking Backend Health...${RESET_FORMAT}"
echo -e "${YELLOW_TEXT}${BOLD_TEXT}Waiting 120 seconds for health checks...${RESET_FORMAT}"
sleep 120

run_with_output "" \
    gcloud compute backend-services get-health service-alb-global --global

# Check Port Name
echo -e "${MAGENTA_TEXT}${BOLD_TEXT}Checking Port Name...${RESET_FORMAT}"
mkdir -p ~/.ssh
ssh-keygen -t rsa -f ~/.ssh/google_compute_engine -N "" -q <<< y >/dev/null 2>&1 || true

LB_IP=$(gcloud compute addresses describe ip-alb-global \
  --global \
  --quiet \
  --format="get(address)")

INSTANCE=$(gcloud compute instances list \
  --filter="name~'^mig-alb-api-a'" \
  --format="value(name)" | head -1)

ZONE=$(gcloud compute instances list \
  --filter="name=$INSTANCE" \
  --format="value(zone.basename())")

# Stop nginx in background
(
  sleep 10
  gcloud compute ssh "$INSTANCE" \
    --zone="$ZONE" \
    --quiet \
    --command="sudo systemctl stop nginx" > /dev/null 2>&1
  echo ""
  echo "${GREEN_TEXT}===== Nginx stopped on $INSTANCE =====${RESET_FORMAT}"
) &

# Test the load balancer
echo -e "${CYAN_TEXT}${BOLD_TEXT}Testing Load Balancer...${RESET_FORMAT}"
timeout 40 bash -c '
while true; do
  curl -k -s https://'"$LB_IP"' 2>/dev/null | grep -i "Hello from"
  if [ $? -eq 0 ]; then
    echo -e "'"${GREEN_TEXT}"'✓ Request successful'"${RESET_FORMAT}"'
  fi
  sleep 0.5
done
' 2>/dev/null

echo
echo "${ORANGE_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}              LAB COMPLETED SUCCESSFULLY!              ${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo
echo "${RED_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}Please subscribe to the channel for more videos and updates!${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}Don't forget to Like, Share and Subscribe!${RESET_FORMAT}"
echo