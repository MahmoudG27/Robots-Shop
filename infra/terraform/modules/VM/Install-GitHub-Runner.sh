#!/bin/bash

set -e

# GitHub Configuration
GITHUB_OWNER="MahmoudG27"
GITHUB_REPO="Robots-Shop"
RUNNER_TOKEN="YOUR_REGISTRATION_TOKEN"

RUNNER_NAME="$(hostname)"
RUNNER_LABELS="linux,self-hosted"

# Runner Configuration
RUNNER_VERSION="2.334.0"
RUNNER_FILE="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
DOWNLOAD_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_FILE}"

WORK_DIR="$HOME/actions-runner"

echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y curl jq tar

echo "Creating runner directory..."
mkdir -p $WORK_DIR
cd $WORK_DIR

echo "Downloading GitHub Runner..."
curl -o $RUNNER_FILE -L $DOWNLOAD_URL
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