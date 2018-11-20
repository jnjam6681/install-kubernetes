# install-kubernetes-kubeadm
install kubernetes, docker, docker-compose, helm

# Configure SSH
  ```
  eval $(ssh-agent)
  ssh-add ~/.ssh/path_to_private_key
  ssh -A ip_address
  ```
  or
  ```
  ssh-keygen -t rsa -P ''
  ssh-copy-id user@ip_addres
  ```
# Run script with SSH
  ```
  ssh user@$ip_address "bash -s" < ./1-install-docker.sh
  ```
 
