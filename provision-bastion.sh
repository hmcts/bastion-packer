#!/bin/bash -xe

export DEBIAN_FRONTEND=noninteractive
#renovate: datasource=github-tags depName=kubernetes/kubectl
export KUBECTL_VERSION=$(echo v1.26.0 | tr -d 'v')

apt autoremove -y

apt update

apt install -y \
  ca-certificates \
  curl \
  gnupg \
  gnupg2 \
  lsb-release

install -m 0755 -d /etc/apt/keyrings

curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main | tee /etc/apt/sources.list.d/azure-cli.list

echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/keyrings/pgdg.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list > /dev/null

# Download kubectl binary and verify its checksum
curl -LO https://dl.k8s.io/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl
curl -LO https://dl.k8s.io/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl.sha256
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

apt update

apt install -y apt-transport-https azure-cli ca-certificates curl gnupg jq lsb-release nmap openjdk-11-jre-headless openjdk-17-jre-headless postgresql tcpdump parallel redis-server


packages=(az gpg java jq nmap psql tcpdump redis-server)

for i in ${packages[@]}

do
  if command -v ${i}; then
     echo -n ${i} is installed. Version is ; ${i} --version
  else
     echo ${i} is missing!
     exit 1
  fi
done
