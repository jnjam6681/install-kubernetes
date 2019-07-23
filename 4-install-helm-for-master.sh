#!/bin/bash
HELM_VERSION="v2.14.2"
# install helm
echo 'install helm'
wget https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz
tar -zxvf helm-${HELM_VERSION}-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
rm -rf helm-${HELM_VERSION}-linux-amd64.tar.gz
rm -rf linux-amd64
echo 'install helm finish !!'
