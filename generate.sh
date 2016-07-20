#!/bin/sh

set -e -x

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
bosh --ca-cert $BOSH_CACERT target $BOSH_TARGET <<EOF 1>/dev/null 2>&1
$BOSH_USERNAME
$BOSH_PASSWORD
EOF
bosh download manifest $CF_DEPLOYMENT $SCRIPT_PATH/${CF_DEPLOYMENT}.yml

diego-release-repo/scripts/generate-deployment-manifest \
  -c $SCRIPT_PATH/${CF_DEPLOYMENT}.yml \
  -i $SECRETS \
  -p $SECRETS \
  -n $SCRIPT_PATH/diego-jobs.yml \
  -x > $DIEGO_MANIFEST
