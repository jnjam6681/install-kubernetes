#!/bin/bash

# set ip adddres load_balancer
LOAD_BALANCER_DNS="192.168.1.1"
LOAD_BALANCER_PORT="6443"

# create kubeadm-config.yaml
echo 'create kubeadm-config.yaml'
cat << EOF > ./kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: stable
controlPlaneEndpoint: "${LOAD_BALANCER_DNS}:${LOAD_BALANCER_PORT}"
networking:
  podSubnet: 10.244.0.0/16
EOF
echo 'create file success.'

# Initialize the control plane
echo 'kubeadm init'
sudo kubeadm init --config=kubeadm-config.yaml --experimental-upload-certs

# start cluster
echo 'start cluster'
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo 'success.'

# Initialize network
kubectl apply -f https://docs.projectcalico.org/v3.7/manifests/canal.yaml
# kubectl apply -f https://docs.projectcalico.org/v3.7/manifests/calico.yaml

# re-upload the certificates and generate a new decryption key
# sudo kubeadm init phase upload-certs --experimental-upload-certs
