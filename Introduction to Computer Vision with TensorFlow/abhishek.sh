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

# Function to display a centered welcome message
welcome_message() {
    clear
    echo "${BG_BLUE}${BOLD}${WHITE}"
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                    ║"
    echo "║        WELCOME TO Dr Abhishek Cloud Tutorials Do Like & SUB         ║"
    echo "║                                                                    ║"
    echo "║         Let's   prepare the  environment for the lab                ║"
    echo "║                                                                    ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo "${RESET}"
    echo
    echo "${GREEN}${BOLD}What this script will do:${RESET}"
    echo "  • Check Python version"
    echo "  • Install TensorFlow and required dependencies"
    echo "  • Download lab notebooks"
    echo "  • Clean up temporary files"
    echo
    echo "${YELLOW}${BOLD}Note:${RESET} This may take a few minutes to complete."
    echo
    echo "${CYAN}For more tutorials, visit: https://www.youtube.com/@drabhishek.5460${RESET}"
    echo
    read -p "${BOLD}Press Enter to begin the setup...${RESET}"
}

#----------------------------------------------------start--------------------------------------------------#

# Display welcome message
welcome_message

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"
echo

# Check Python version
echo "${BLUE}${BOLD}Checking Python version...${RESET}"
python --version
echo

# Install TensorFlow and dependencies
echo "${BLUE}${BOLD}Installing TensorFlow and dependencies...${RESET}"
pip3 install --upgrade pip
pip3 install tensorflow
pip install -U pylint --user
pip install -r requirements.txt
echo

# Download lab notebooks
echo "${BLUE}${BOLD}Downloading lab notebooks...${RESET}"
wget https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/refs/heads/main/Introduction%20to%20Computer%20Vision%20with%20TensorFlow/model.ipynb
wget https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/refs/heads/main/Introduction%20to%20Computer%20Vision%20with%20TensorFlow/callback_model.ipynb
wget https://raw.githubusercontent.com/abhishekmsm51w-star/gcpbyabhi/refs/heads/main/Introduction%20to%20Computer%20Vision%20with%20TensorFlow/updated_model.ipynb
echo

# Clean up
echo "${BLUE}${BOLD}Cleaning up...${RESET}"
rm abhishek.sh
echo

# Completion message
echo "${BG_GREEN}${BOLD}${BLACK}Setup completed successfully!${RESET}"
echo
echo "${YELLOW}${BOLD}NOW${RESET}" "${BLUE}${BOLD}FOLLOW${RESET}" "${GREEN}${BOLD}THE VIDEO INSTRUCTIONS${RESET}"
echo
echo "${CYAN}${BOLD}Happy learning with TensorFlow!${RESET}"
echo "${MAGENTA}For more tutorials, subscribe to: https://www.youtube.com/@drabhishek.5460${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
