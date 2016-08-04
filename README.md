## 18F Diego Deployment Manifests and Concourse pipeline

This repo contains the source for the Bosh deployment manifest and deployment pipeline for the 18F Diego deployment.

### How to generate the final manifest:

1. Install `spiff`
1. Copy the secrets example:
`cp secrets.example.yml diego-secrets.yml`
1. Change all the variables in CAPS in `diego-secrets.yml` to proper values and add certificates and keys
1. Run `./generate.sh`

### How to deploy the manifest:

Wherever you have your bosh installation run:

1. `bosh deployment manifest.yml`
1. `bosh deploy`
