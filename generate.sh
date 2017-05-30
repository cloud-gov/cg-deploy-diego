#!/bin/sh

set -e

SECRETS=$1
CF_DEPLOYMENT=$2
BOSH_CACERT=$3
BOSH_TARGET=$4
BOSH_USERNAME=$5
BOSH_PASSWORD=$6
INSTANCE_COUNT_OVERRIDES=$7
DIEGO_MANIFEST=$8

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
  -s $SECRETS \
  -v $SCRIPT_PATH/release-versions.yml \
  -n $SCRIPT_PATH/$INSTANCE_COUNT_OVERRIDES \
  -x > $SCRIPT_PATH/diego-intermediate.yml

# Merge in our local additions
echo Adding local releases and properties...
spiff merge \
  diego-release-repo/manifest-generation/misc-templates/bosh.yml \
  $SECRETS \
  $SCRIPT_PATH/diego-jobs.yml \
  $SCRIPT_PATH/diego-intermediate.yml \
  $SCRIPT_PATH/diego-final.yml > ${DIEGO_MANIFEST}
