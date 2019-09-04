#!/bin/env bash

#Installing Kubernetes Master

#Declaring the IpAddress and Hostname

MasterIpAddress=$1

#Setting the Kubernetes Master i.e. Control-Plane 

echo Setting the Kubernetes Master which is Control-Plane
kubeadm init --apiserver-advertise-address=$MasterIpAddress --pod-network-cidr=10.244.0.0/16

#Waiting for the configuration to complete
sleep 1m

#Configuring regular user to access kubectl environment

echo Configuring regular user to access kubectl environment
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Setting up the Pod network for the Kubernetes Cluster

echo Setting up the Pod network for the Kubernetes Cluster
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo Successfully installed control plane which is Kubernetes Master
echo Execute this command to verify if the pods are running "kubectl get pods -o wide --all-namespaces"
echo Execute this command to verify the state of the Master "kubectl get nodes"
