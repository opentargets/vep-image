# Custom VEP docker image

This repository contains **customized Dockerfile for the Ensembl Variant Effect Predictor (VEP) tool**. The image is based on the [official Ensembl VEP image](https://hub.docker.com/r/ensemblorg/ensembl-vep/tags) and includes the following modifications that allows to run the VEP with the loftee plugin:

- Addition of the sqllite3 and its perl wrapper along with the required dependencies
- Addition of the samtools
- Addition of the loftee.sql database

See [loftee source](https://github.com/konradjk/loftee) for more details.
