# Custom VEP docker image

This repository contains **customized Dockerfile for the Ensembl Variant Effect Predictor (VEP) tool**. The image is based on the [official Ensembl VEP image](https://hub.docker.com/r/ensemblorg/ensembl-vep/tags) and includes the following modifications that allows to run the VEP with the loftee plugin:

- Addition of the sqllite3 and its perl wrapper along with the required dependencies
- Addition of the samtools
- Addition of the loftee.sql database

See [loftee source](https://github.com/konradjk/loftee) for more details.

## Usage

To build the image one need to run the following command:

```bash
make build-local
```

## Lifecycle

The lifecycle of the image is bound to the lifecycle of the official Ensembl VEP image. With the github actions we look over the latest version of the Ensembl VEP image and if there is a new version, it will automatically trigger the PR to this repository. This behavior is designed in the `pr.yaml`.

When the PR is merged, the new image build will be triggered in the `artifact.yaml`.

> [!NOTE]
> The default image is hosted on opentargets google cloud.

## Updating VEP Cache files

As each Ensembl release has its own VEP release, the underlying cache data needs to be updated as well.

```bash
#!/usr/bin/env bash

CACHE_DIR='path to local folder'
ENSEMBL_RELEASE='114'

mkdir -p ${CACHE_DIR}
cd $_

# Clone VEP plugins, check out release:
git clone https://github.com/Ensembl/VEP_plugins 
cd VEP_plugins
git checkout ${ENSEMBL_RELEASE}
cd ..

# Download cache: 
wget "https://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}/variation/indexed_vep_cache/homo_sapiens_vep_${ENSEMBL_RELEASE}_GRCh38.tar.gz" -P ${CACHE_DIR}/

# Extract tar:
tar xzf homo_sapiens_vep_${ENSEMBL_RELEASE}_GRCh38.tar.gz

# Some fo the plugins/offline options require the access to fasta file:
wget https://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz -P ${CACHE_DIR}/
gzip -d Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
bgzip Homo_sapiens.GRCh38.dna.primary_assembly.fa

# For GERP conservation scores the relevant bw file is needed:
wget https://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}/compara/conservation_scores/91_mammals.gerp_conservation_score/gerp_conservation_scores.homo_sapiens.GRCh38.bw -P ${CACHE_DIR}/


# Move datasets to GCP:
gsutil -m cp -r ${CACHE_DIR}/VEP_plugins ${CACHE_TARGET_GCP}/
gsutil -m cp -r ${CACHE_DIR}/homo_sapiens ${CACHE_TARGET_GCP}/
gsutil -m cp ${CACHE_DIR}/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz ${CACHE_TARGET_GCP}/
gsutil -m cp ${CACHE_DIR}/gerp_conservation_scores.homo_sapiens.GRCh38.bw ${CACHE_TARGET_GCP}/
```
