#!/bin/bash

set -e

# GitHub Configuration
GITHUB_OWNER="your-org"
GITHUB_REPO="your-repo"
RUNNER_TOKEN="YOUR_REGISTRATION_TOKEN"

RUNNER_NAME="$(hostname)"
RUNNER_LABELS="linux,self-hosted"

# Runner Configuration
RUNNER_VERSION="2.328.0"
RUNNER_FILE="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
DOWNLOAD_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_FILE}"

WORK_DIR="/home/adminuser/actions-runner"

echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y curl jq tar

echo "Creating runner directory..."
mkdir -p $WORK_DIR
cd $WORK_DIR

echo "Downloading GitHub Runner..."
curl -L -o $RUNNER_FILE $DOWNLOAD_URL
tar xzf $RUNNER_FILE

echo "Configuring runner..."
./config.sh \
  --url "https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}" \
  --token "$RUNNER_TOKEN" \
  --name "$RUNNER_NAME" \
  --labels "$RUNNER_LABELS" \
  --work "_work" \
  --unattended \
  --replace

echo "Installing service..."
sudo ./svc.sh install
sudo ./svc.sh start

echo "Done."