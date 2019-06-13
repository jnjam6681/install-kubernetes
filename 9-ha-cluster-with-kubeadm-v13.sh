#!/bin/bash

###############################################################################
#                                                                             #
#  + install HA for 3 master                                                  #
#  + scp from root to root, please check your scp before run script.          #
#                                                                             #
###############################################################################
###############################################################################
#                                                                             #
#  + After setup master 2 and 3 success.                                      #
#  + please run command on master 2 and 3                                     #
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config
#
###############################################################################

# set ip adddres load_balancer
LOAD_BALANCER_DNS="192.168.1.1"
LOAD_BALANCER_PORT="6443"

# set ip address for all master node
USER=root
CONTROL_PLANE_IPS="10.0.0.7 10.0.0.8"

# create kubeadm-config.yaml
echo 'create kubeadm-config.yaml'
cat << EOF > ./kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: stable
apiServer:
  certSANs:
  - "${LOAD_BALANCER_DNS}"
controlPlaneEndpoint: "${LOAD_BALANCER_DNS}:${LOAD_BALANCER_PORT}"
networking:
  podSubnet: 10.244.0.0/16
EOF
echo 'create file success.'

# Initialize cluster
echo 'Initialize cluster'
sudo kubeadm init --config=kubeadm-config.yaml
echo 'success.'

# start cluster
echo 'start cluster'
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo 'success.'

# Initialize network
echo 'Initialize network'
kubectl apply -f https://docs.projectcalico.org/v3.7/manifests/canal.yaml
echo 'success.'

# create folder kubernetes
echo 'create folder kubernetes'
mkdir -p ./etc/kubernetes/pki/etcd
echo 'success.'

# copy file
echo 'copy file to kubernetes'
cp /etc/kubernetes/pki/ca.crt ./etc/kubernetes/pki/
cp /etc/kubernetes/pki/ca.key ./etc/kubernetes/pki/
cp /etc/kubernetes/pki/sa.key ./etc/kubernetes/pki/
cp /etc/kubernetes/pki/sa.pub ./etc/kubernetes/pki/
cp /etc/kubernetes/pki/front-proxy-ca.crt ./etc/kubernetes/pki/
cp /etc/kubernetes/pki/front-proxy-ca.key ./etc/kubernetes/pki/
cp /etc/kubernetes/pki/etcd/ca.crt ./etc/kubernetes/pki/etcd/ca.crt
cp /etc/kubernetes/pki/etcd/ca.key ./etc/kubernetes/pki/etcd/ca.key
# cp /etc/kubernetes/admin.conf ./etc/kubernetes/admin.conf
echo 'success.'

# scp file to master nodes
echo 'scp file to master nodes'
for host in ${CONTROL_PLANE_IPS}; do
  scp -r ./etc/kubernetes/pki/ "${USER}"@$host:/etc/kubernetes/
  scp /etc/kubernetes/admin.conf "${USER}"@$host:/etc/kubernetes/admin.conf
done
echo 'success.'
