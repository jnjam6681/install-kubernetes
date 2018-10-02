#!/bin/bash
# install repo coreos
# https://github.com/coreos/prometheus-operator/tree/master/helm
echo 'install coreos'
helm repo add coreos https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/
echo 'install finish !!'

echo 'install prometheus-operator'
helm install coreos/prometheus-operator --name prometheus --namespace monitoring
echo 'install finish !!'

echo 'install kube-prometheu'
helm install coreos/kube-prometheus --name kube-prometheus --set global.rbacEnable=true --namespace monitoring
echo 'install finish !!'

echo 'install custom grafana'
helm install coreos/grafana --namespace monitoring --set service.type=LoadBalancer --set auth.anonymous.enabled=false --set adminUser=admin --set adminPassword=admin
echo 'install finish !!'
