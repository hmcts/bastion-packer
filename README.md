## Overview 

This repository contains Packer HCL to build and publish an Ubuntu 24.04 machine image to an Azure Shared Image Gallery.

## Adding new packages

If you want to add new software packages to the image, update the provision-bastion.sh script to add the required package:

```
apt install -y apt-transport-https azure-cli ca-certificates curl gnupg jq lsb-release nmap openjdk-11-jre-headless openjdk-17-jre-headless postgresql tcpdump parallel redis-server
```

Also add the package name to the checker. When the pipeline runs to create the image, the build will exit if any of the required packages are missing:

```
packages=(az gpg java jq nmap psql tcpdump)
```

## Deploying updated bastions

When this pipeline runs, a new image version will be created in the Shared Image Gallery.

To redeploy the bastions based on the updated image version, update the image_version for each environment in the hmcts/bastion repo.

## Adding new packages to be updated by renovate

If you add a new package to the [provisioning script](./provision-bastion.sh) that can't be installed via package manager and should be updated regularly, add it to the block in the [provisioning script](https://github.com/hmcts/bastion-packer/blob/master/provision-bastion.sh#L4).

You will need to add a comment to inform renovate where to search for available versions e.g. on github with `#renovate: datasource=github-tags depName=kubernetes/kubectl`

See [renovate datasources](https://docs.renovatebot.com/modules/datasource/) for a list of available sources.

By default, renovate will search for versions using `semver` but if your package uses another format, you will have to indicate what versioning to use e.g. `versioning=regex`

See [renovate versioning](https://docs.renovatebot.com/modules/versioning/) for a list of available versioning schemes.

Because a lot of github releases use `v` prefixes, we have an `echo` statement paired with the `tr` command to remove these in our script when setting the version to be used e.g. `export KUBECTL_VERSION=$(echo v1.26.0 | tr -d 'v')`.

## Pipeline authentication and validation

Azure tasks use `DTS-MANAGEMENT-PROD-INTSVC-WIF`. Packer authenticates through
that task's Azure CLI session with `use_azure_cli_auth`; client secrets are not
passed to Packer.

Pull requests and non-master branch runs perform image-version lookup, Packer
initialization and validation only. They do not build images or run Azure
cleanup commands. To opt into an actual image build on a non-master branch,
run the pipeline manually with `buildImage: true`. These builds create temporary
Azure resources and publish a test image version named `<Build.BuildId>.0.0`,
which is deleted after the build.

Master and scheduled master runs retain their existing image-build and release
behavior, including resource cleanup. Do not merge merely to test validation:
merging triggers a real image build.
