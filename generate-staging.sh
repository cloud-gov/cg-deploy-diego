#!/bin/sh

set -e -x

SECRETS=$1
CF_MANIFEST=$2
DIEGO_MANIFEST=$3

SCRIPT_PATH=$(dirname $0)
SECRETS_PATH=$(dirname $SECRETS)
CF_MANIFEST_PATH=$(dirname $CF_MANIFEST)

spiff merge \
  $CF_MANIFEST_PATH/cf-deployment.yml \
  $CF_MANIFEST_PATH/cf-resource-pools.yml \
  $CF_MANIFEST_PATH/cf-jobs.yml \
  $CF_MANIFEST_PATH/cf-properties.yml \
  $CF_MANIFEST_PATH/cf-infrastructure-aws-staging.yml \
  $SECRETS \
  > $CF_MANIFEST

sed -i -- 's/10.10/10.9/g' $CF_MANIFEST

spiff merge \
  diego-release-repo/manifest-generation/config-from-cf.yml \
  diego-release-repo/manifest-generation/config-from-cf-internal.yml \
  $CF_MANIFEST \
  > $SCRIPT_PATH/cf-conf-staging.yml

spiff merge \
  diego-release-repo/manifest-generation/diego.yml \
  diego-release-repo/examples/aws/templates/diego/property-overrides.yml \
  diego-release-repo/manifest-generation/misc-templates/aws-iaas-settings.yml \
  $SCRIPT_PATH/diego-jobs.yml \
  $SCRIPT_PATH/cf-conf-staging.yml \
  > ${DIEGO_MANIFEST}.intermediate

spiff merge \
  diego-release-repo/manifest-generation/misc-templates/bosh.yml \
  ${DIEGO_MANIFEST}.intermediate \
  > $DIEGO_MANIFEST
