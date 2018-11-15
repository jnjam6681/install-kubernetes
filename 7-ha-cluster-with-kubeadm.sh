#!/bin/bash

###############################################################################
#                                                                             #
#  + install HA for 3 master                                                  #
#  + scp from root to root, please check your scp before run script.          #
#                                                                             #
###############################################################################

# set hostname
K8SHA_HOST1="k8s-master-1"
K8SHA_HOST2="k8s-master-2"
K8SHA_HOST3="k8s-master-3"

# set ip address
K8SHA_IP1="192.168.1.11"
K8SHA_IP2="192.168.1.12"
K8SHA_IP3="192.168.1.13"

# set username
K8SHA_USER1="root"
K8SHA_USER2="root"
K8SHA_USER3="root"

# set ip address load_balancer
K8SHA_LB_IP="192.168.1.11"

# port load_balancer
K8SHA_LB_PORT="6443"

# kubernetes CIDR pod subnet
K8SHA_CIDR="10.244.0.0/16"

# create folder config
mkdir -p ~/config/${K8SHA_HOST1}/
mkdir -p ~/config/${K8SHA_HOST2}/
mkdir -p ~/config/${K8SHA_HOST3}/

# create all kubeadm-config.yaml
echo "create all kubeadm-config.yaml"

cat << EOF > ~/config/${K8SHA_HOST1}/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1alpha3
kind: ClusterConfiguration
kubernetesVersion: stable
apiServerCertSANs:
- "${K8SHA_LB_IP}"
controlPlaneEndpoint: "${K8SHA_LB_IP}:${K8SHA_LB_PORT}"
etcd:
  local:
    extraArgs:
      listen-client-urls: "https://127.0.0.1:2379,https://${K8SHA_IP1}:2379"
      advertise-client-urls: "https://${K8SHA_IP1}:2379"
      listen-peer-urls: "https://${K8SHA_IP1}:2380"
      initial-advertise-peer-urls: "https://${K8SHA_IP1}:2380"
      initial-cluster: "${K8SHA_HOST1}=https://${K8SHA_IP1}:2380"
    serverCertSANs:
      - ${K8SHA_HOST1}
      - ${K8SHA_IP1}
    peerCertSANs:
      - ${K8SHA_HOST1}
      - ${K8SHA_IP1}
networking:
    podSubnet: "${K8SHA_CIDR}"
EOF
echo "create kubeadm-config.yaml for ${K8SHA_HOST1} success."
echo "-----------------------------------------------------"

cat << EOF > ~/config/${K8SHA_HOST2}/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1alpha3
kind: ClusterConfiguration
kubernetesVersion: stable
apiServerCertSANs:
- "${K8SHA_LB_IP}"
controlPlaneEndpoint: "${K8SHA_LB_IP}:${K8SHA_LB_PORT}"
etcd:
  local:
    extraArgs:
      listen-client-urls: "https://127.0.0.1:2379,https://${K8SHA_IP2}:2379"
      advertise-client-urls: "https://${K8SHA_IP2}:2379"
      listen-peer-urls: "https://${K8SHA_IP2}:2380"
      initial-advertise-peer-urls: "https://${K8SHA_IP2}:2380"
      initial-cluster: "${K8SHA_HOST1}=https://${K8SHA_IP1}:2380,${K8SHA_HOST2}=https://${K8SHA_IP2}:2380"
      initial-cluster-state: existing
    serverCertSANs:
      - ${K8SHA_HOST2}
      - ${K8SHA_IP2}
    peerCertSANs:
      - ${K8SHA_HOST2}
      - ${K8SHA_IP2}
networking:
    podSubnet: "${K8SHA_CIDR}"
EOF
echo "create kubeadm-config.yaml for ${K8SHA_HOST2} success."
echo "-----------------------------------------------------"

cat << EOF > ~/config/${K8SHA_HOST3}/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1alpha3
kind: ClusterConfiguration
kubernetesVersion: stable
apiServerCertSANs:
- "${K8SHA_LB_IP}"
controlPlaneEndpoint: "${K8SHA_LB_IP}:${K8SHA_LB_PORT}"
etcd:
  local:
    extraArgs:
      listen-client-urls: "https://127.0.0.1:2379,https://${K8SHA_IP3}:2379"
      advertise-client-urls: "https://${K8SHA_IP3}:2379"
      listen-peer-urls: "https://${K8SHA_IP3}:2380"
      initial-advertise-peer-urls: "https://${K8SHA_IP3}:2380"
      initial-cluster: "${K8SHA_HOST1}=https://${K8SHA_IP1}:2380,${K8SHA_HOST2}=https://${K8SHA_IP2}:2380,${K8SHA_HOST3}=https://${K8SHA_IP3}:2380"
      initial-cluster-state: existing
    serverCertSANs:
      - ${K8SHA_HOST3}
      - ${K8SHA_IP3}
    peerCertSANs:
      - ${K8SHA_HOST3}
      - ${K8SHA_IP3}
networking:
    podSubnet: "${K8SHA_CIDR}"
EOF
echo "create kubeadm-config.yaml for ${K8SHA_HOST3} success."
echo "-----------------------------------------------------"
echo "run kubeadm-config.yaml"
cd ~/config/${K8SHA_HOST1}/
kubeadm init --config kubeadm-config.yaml

echo "start cluster"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/canal/rbac.yaml
kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/canal/canal.yaml
echo "start cluster success."

# copy certificates to other control plane nodes
echo "copy certificates to ~/config/${K8SHA_HOST2}/"
cp /etc/kubernetes/pki/ca.crt ~/config/${K8SHA_HOST2}/
cp /etc/kubernetes/pki/ca.key ~/config/${K8SHA_HOST2}/
cp /etc/kubernetes/pki/sa.key ~/config/${K8SHA_HOST2}/
cp /etc/kubernetes/pki/sa.pub ~/config/${K8SHA_HOST2}/
cp /etc/kubernetes/pki/front-proxy-ca.crt ~/config/${K8SHA_HOST2}/
cp /etc/kubernetes/pki/front-proxy-ca.key ~/config/${K8SHA_HOST2}/
cp /etc/kubernetes/pki/etcd/ca.crt ~/config/${K8SHA_HOST2}/etcd-ca.crt
cp /etc/kubernetes/pki/etcd/ca.key ~/config/${K8SHA_HOST2}/etcd-ca.key
cp /etc/kubernetes/admin.conf ~/config/${K8SHA_HOST2}/
echo "copy success."

echo "copy certificates to ~/config/${K8SHA_HOST3}/"
cp /etc/kubernetes/pki/ca.crt ~/config/${K8SHA_HOST3}/
cp /etc/kubernetes/pki/ca.key ~/config/${K8SHA_HOST3}/
cp /etc/kubernetes/pki/sa.key ~/config/${K8SHA_HOST3}/
cp /etc/kubernetes/pki/sa.pub ~/config/${K8SHA_HOST3}/
cp /etc/kubernetes/pki/front-proxy-ca.crt ~/config/${K8SHA_HOST3}/
cp /etc/kubernetes/pki/front-proxy-ca.key ~/config/${K8SHA_HOST3}/
cp /etc/kubernetes/pki/etcd/ca.crt ~/config/${K8SHA_HOST3}/etcd-ca.crt
cp /etc/kubernetes/pki/etcd/ca.key ~/config/${K8SHA_HOST3}/etcd-ca.key
cp /etc/kubernetes/admin.conf ~/config/${K8SHA_HOST3}/
echo "copy success."
echo "-----------------------------------------------------"

echo "create deploy file"
cat << EOF > ~/config/${K8SHA_HOST2}/1-kubeadm-phase.sh
K8SHA_CONFIG="/etc/kubernetes/admin.conf"

mkdir -p /etc/kubernetes/pki/etcd
mv ~/config/${K8SHA_HOST2}/ca.crt /etc/kubernetes/pki/
mv ~/config/${K8SHA_HOST2}/ca.key /etc/kubernetes/pki/
mv ~/config/${K8SHA_HOST2}/sa.pub /etc/kubernetes/pki/
mv ~/config/${K8SHA_HOST2}/sa.key /etc/kubernetes/pki/
mv ~/config/${K8SHA_HOST2}/front-proxy-ca.crt /etc/kubernetes/pki/
mv ~/config/${K8SHA_HOST2}/front-proxy-ca.key /etc/kubernetes/pki/
mv ~/config/${K8SHA_HOST2}/etcd-ca.crt /etc/kubernetes/pki/etcd/ca.crt
mv ~/config/${K8SHA_HOST2}/etcd-ca.key /etc/kubernetes/pki/etcd/ca.key
mv ~/config/${K8SHA_HOST2}/admin.conf /etc/kubernetes/admin.conf

kubeadm alpha phase certs all --config kubeadm-config.yaml
kubeadm alpha phase kubelet config write-to-disk --config kubeadm-config.yaml
kubeadm alpha phase kubelet write-env-file --config kubeadm-config.yaml
kubeadm alpha phase kubeconfig kubelet --config kubeadm-config.yaml
systemctl start kubelet

kubectl exec -n kube-system etcd-${K8SHA_HOST1} -- etcdctl --ca-file /etc/kubernetes/pki/etcd/ca.crt --cert-file /etc/kubernetes/pki/etcd/peer.crt --key-file /etc/kubernetes/pki/etcd/peer.key --endpoints=https://${K8SHA_IP1}:2379 member add ${K8SHA_HOST2} https://${K8SHA_IP2}:2380
kubeadm alpha phase etcd local --config kubeadm-config.yaml

kubeadm alpha phase kubeconfig all --config kubeadm-config.yaml
kubeadm alpha phase controlplane all --config kubeadm-config.yaml
kubeadm alpha phase kubelet config annotate-cri --config kubeadm-config.yaml
kubeadm alpha phase mark-master --config kubeadm-config.yaml
EOF
echo "create success."
echo "-----------------------------------------------------"

echo "create deploy file"
cat << EOF > ~/config/${K8SHA_HOST3}/1-kubeadm-phase.sh
K8SHA_CONFIG="/etc/kubernetes/admin.conf"

mkdir -p /etc/kubernetes/pki/etcd
mv ~/config/${K8SHA_HOST3}/ca.crt /etc/kubernetes/pki/
mv ~/config/${K8SHA_HOST3}/ca.key /etc/kubernetes/pki/
mv ~/config/${K8SHA_HOST3}/sa.pub /etc/kubernetes/pki/
mv ~/config/${K8SHA_HOST3}/sa.key /etc/kubernetes/pki/
mv ~/config/${K8SHA_HOST3}/front-proxy-ca.crt /etc/kubernetes/pki/
mv ~/config/${K8SHA_HOST3}/front-proxy-ca.key /etc/kubernetes/pki/
mv ~/config/${K8SHA_HOST3}/etcd-ca.crt /etc/kubernetes/pki/etcd/ca.crt
mv ~/config/${K8SHA_HOST3}/etcd-ca.key /etc/kubernetes/pki/etcd/ca.key
mv ~/config/${K8SHA_HOST3}/admin.conf /etc/kubernetes/admin.conf

kubeadm alpha phase certs all --config kubeadm-config.yaml
kubeadm alpha phase kubelet config write-to-disk --config kubeadm-config.yaml
kubeadm alpha phase kubelet write-env-file --config kubeadm-config.yaml
kubeadm alpha phase kubeconfig kubelet --config kubeadm-config.yaml
systemctl start kubelet

kubectl exec -n kube-system etcd-${K8SHA_HOST1} -- etcdctl --ca-file /etc/kubernetes/pki/etcd/ca.crt --cert-file /etc/kubernetes/pki/etcd/peer.crt --key-file /etc/kubernetes/pki/etcd/peer.key --endpoints=https://${K8SHA_IP1}:2379 member add ${K8SHA_HOST3} https://${K8SHA_IP3}:2380
kubeadm alpha phase etcd local --config kubeadm-config.yaml

kubeadm alpha phase kubeconfig all --config kubeadm-config.yaml
kubeadm alpha phase controlplane all --config kubeadm-config.yaml
kubeadm alpha phase kubelet config annotate-cri --config kubeadm-config.yaml
kubeadm alpha phase mark-master --config kubeadm-config.yaml
EOF
echo "create success."
echo "-----------------------------------------------------"

# copy folder config to other control plane nodes
echo "copy folder config"
scp -r ~/config/${K8SHA_HOST2}/ ${K8SHA_USER2}@${K8SHA_IP2}:
scp -r ~/config/${K8SHA_HOST3}/ ${K8SHA_USER3}@${K8SHA_IP3}:
echo "copy folder success."
echo "-----------------------------------------------------"
echo "finish!!"
