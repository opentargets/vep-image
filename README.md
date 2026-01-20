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
ENSEMBL_RELEASE='115'
CACHE_TARGET_GCP=""

mkdir -p ${CACHE_DIR}
cd ${CACHE_DIR}

# Clone VEP plugins, check out release:
git clone https://github.com/Ensembl/VEP_plugins 
cd VEP_plugins
git checkout "release/${ENSEMBL_RELEASE}"
cd ${CACHE_DIR}

# Download cache: 
wget "https://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}/variation/indexed_vep_cache/homo_sapiens_vep_${ENSEMBL_RELEASE}_GRCh38.tar.gz" -P ${CACHE_DIR}/

# Extract tar:
tar xzf homo_sapiens_vep_${ENSEMBL_RELEASE}_GRCh38.tar.gz

# Some of the plugins/offline options require the access to fasta file:
wget https://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz -P ${CACHE_DIR}/
gzip -d Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
bgzip Homo_sapiens.GRCh38.dna.primary_assembly.fa
samtools faidx Homo_sapiens.GRCh38.dna.primary_assembly.fa

# For GERP conservation scores the relevant bw file is needed:
wget https://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}/compara/conservation_scores/92_mammals.gerp_conservation_score/gerp_conservation_scores.homo_sapiens.GRCh38.bw -P ${CACHE_DIR}/

# For the contig index
samtools faidx Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
echo -e "id\tstart\tend\tcanonical\tdatasourceId" > grch38.primary.chrom.bed
awk '{print $1"\t0\t"$2}' Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz.fai >> grch38.primary.chrom.bed

# Move datasets to GCP:
gcloud storage cp -r ${CACHE_DIR}/VEP_plugins ${CACHE_TARGET_GCP}/
gcloud storage cp -r ${CACHE_DIR}/homo_sapiens ${CACHE_TARGET_GCP}/
gcloud storage cp ${CACHE_DIR}/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz ${CACHE_TARGET_GCP}/
gcloud storage cp ${CACHE_DIR}/gerp_conservation_scores.homo_sapiens.GRCh38.bw ${CACHE_TARGET_GCP}/
gcloud storage cp ${CACHE_DIR}/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz.fai ${CACHE_TARGET_GCP}/
gcloud storage cp ${CACHE_DIR}/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz.gzi ${CACHE_TARGET_GCP}/
gcloud storage cp ${CACHE_DIR}/grch38.primary.chrom.bed ${CACHE_TARGET_GCP}/
```

## SO terms with VEP ranking

To ensure the compatibility of SO terms used by gentropy to annotate the consequence score we need to use the same scoring as one introduced by [ensembl-vep](https://github.com/Ensembl/ensembl-vep). The ranking of SO terms is derived from the [Constants.pm ensembl-variation module](https://github.com/Ensembl/ensembl-variation/blob/release/114/modules/Bio/EnsEMBL/Variation/Utils/Constants.pm).

### Score from ranking

The score for the $ith$ SO term is based on the VEP ranking with following formula:

$$ score_{i} = 1 - (rank_{i} / rank_{max}) $$

The score is an inverse of the ranking to make sure, that high scores are linked to most severe consquences.

To calculate the table with *SO_terms* one must pre-install per5 and the latest [ensembl-variation](https://www.ensembl.org/info/docs/api/api_installation.html) module.

Run the following script to obtain the `so_terms.tsv`

```{bash}
make extract-so-terms
# the output is saved to the `so_terms.tsv` file
```
