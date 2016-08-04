#!/bin/sh

set -e

SECRETS=$1
CF_DEPLOYMENT=$2
BOSH_CACERT=$3
BOSH_TARGET=$4
BOSH_USERNAME=$5
BOSH_PASSWORD=$6
DIEGO_MANIFEST=$7

SCRIPT_PATH=$(dirname $0)
SECRETS_PATH=$(dirname $SECRETS)

# Download the CF manifest
echo Downloading CF manifest...
bosh --ca-cert $BOSH_CACERT target $BOSH_TARGET <<EOF 1>/dev/null 2>&1
$BOSH_USERNAME
$BOSH_PASSWORD
EOF
bosh download manifest $CF_DEPLOYMENT $SCRIPT_PATH/${CF_DEPLOYMENT}.yml

# Call the standard manifest generation script
echo Generating diego manifest...
diego-release-repo/scripts/generate-deployment-manifest \
  -c $SCRIPT_PATH/${CF_DEPLOYMENT}.yml \
  -i $SECRETS \
  -p $SECRETS \
  -n $SCRIPT_PATH/instance-count-overrides.yml \
  -x > $SCRIPT_PATH/diego-intermediate.yml

# Merge in our local additions
echo Adding local releases and properties...
spiff merge \
  diego-release-repo/manifest-generation/misc-templates/bosh.yml \
  $SECRETS \
  $SCRIPT_PATH/diego-jobs.yml \
  $SCRIPT_PATH/diego-intermediate.yml > ${DIEGO_MANIFEST}
