#!/bin/bash

# Must variables be set before running the script
AZDO_URL="https://dev.azure.com/MahmoudG"    # Add your Azure DevOps organization URL
AZDO_POOL="PrivateAgents"                    # The name of the agent pool
AZDO_PAT="Put your PAT token here"           # Ensure you replace 'your_pat_token_here' with your actual PAT token.

AGENT_NAME="private-vnet-agent"              # Name of the agent
WORK_DIR="/home/adminuser/azureagent"        # Working directory for the agent
AGENT_VERSION="4.266.2"                      # Check latest version for agent
AGENT_FILE="vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz"                                   # Name of the agent file to download
DOWNLOAD_URL="https://download.agent.dev.azure.com/agent/${AGENT_VERSION}/${AGENT_FILE}"    # Download URL for the agent file


echo "Install dependencies"
sudo apt update
sudo apt install -y curl tar jq

echo "Create working directory: $WORK_DIR"
sudo mkdir -p $WORK_DIR && cd $WORK_DIR

echo "Download Azure DevOps Agent"
sudo curl -O $DOWNLOAD_URL
sudo tar zxvf $AGENT_FILE

echo "Configure Agent to connect to Azure DevOps"
./config.sh --unattended \
  --url "$AZDO_URL" \
  --auth pat \
  --token "$AZDO_PAT" \
  --pool "$AZDO_POOL" \
  --agent "$AGENT_NAME" \
  --acceptTeeEula \
  --work _work

echo "Install Agent as a service. This will run the agent in the background."
sudo ./svc.sh install
sudo ./svc.sh start

echo "Agent is installed and running."

# # Optionally run the agent interactively If you didn't run as a service above:
# ./run.sh