#!/bin/bash
#
# Wrapping a few CLI command in bash always seems like a good idea at the start.
# It's not. Don't do it. Use python to wrap & possible call API's directly.

# Exit immediately if a command exits with a non-zero status
set -e

# debug - expand all commands
# set -x

# load our helper functions
source scripts/common.sh

# check that the tools we require are present
package_check

#
# base.sh DIR TARGET [BASE_NAME]
DIR="$1"
NAME="$2"
BASE_NAME="$3"
if [[ -z "$DIR" ]]; then
    echo "please specify the directory as first runtime argument"
    exit 1
fi
if [[ -z "$NAME" ]]; then
    echo "please specify the name as second runtime argument"
    exit 1
fi

export SHA=$(git ls-tree HEAD "$DIR" | cut -d" " -f3 | cut -f1)
AMI_ID=$(ami_from_sha $SHA)

if [ -z "${AMI_ID}" ]; then
    echo "No AMI found for ${NAME} (SHA: ${SHA})."
else
    echo "AMI found for ${NAME} (SHA: ${SHA}), de-registering..."
    aws ec2 deregister-image --image-id "${AMI_ID}"
fi

if [ -f "manifest-${NAME}.json" ]; then
  AMI_IDS=$(cat manifest-${NAME}.json | jq '.builds[].artifact_id' | perl -n -e'/us-east-1:(ami-[a-z0-9]+)/ && print "$1\n"')
  for AMI_ID in ${AMI_IDS}; do
    echo "de-registering ${AMI_ID} found in manifest-${NAME}.json"
    aws ec2 deregister-image --image-id "${AMI_ID}" || true
  done
fi
rm -f manifest-${NAME}.json
