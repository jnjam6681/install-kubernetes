# install-kubernetes-kubeadm
install kubernetes, docker, docker-compose, helm

# 7-ha
After setup master 2 and 3 success. 
please run command on master 2 and 3
   ```
   mkdir -p $HOME/.kube                                    
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
   ```
