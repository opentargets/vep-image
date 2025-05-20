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
