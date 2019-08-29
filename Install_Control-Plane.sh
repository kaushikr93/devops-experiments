#!/bin/bash -eux

#Installing Kubernetes Master

#Declaring the IpAddress and Hostname

MasterIpAddress=$1
#MasterHostname=$2

#Pre-requisites to be configured before kubernets installation

#Update the repo

echo Udpating yum repo
yum update -y

#Disable Swap space

echo Disabling swap
swapoff -a
sed -i 's/\(.*swap.*\)/#\1/g'  /etc/fstab

#Set Selinux to Permissive

echo Setting Selinux to Permissive
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config

#Configuring the iptables

echo configuring the iptables
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F

#Install the docker and Start docker service 

echo Installing docker 
yum install docker -y
echo Enabling and starting the docker service
systemctl enable docker && systemctl start docker

#Setting up the repo to download kube bins

echo Adding kubernetes repo to pull bins
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

#Installing kubernetes 

echo Installing kubelet kubectl kubeadm
yum install kubelet kubectl kubeadm -y

#Configuring k8s.conf file under sysctl

echo Configuring k8s.conf file under sysctl
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

echo Running the sysctl command to apply the changes
sysctl --system

echo Enabing the ip forwarding for IPV4
echo 1 > /proc/sys/net/ipv4/ip_forward

#Congfiguring the 10-kubeadm.conf 

echo Configuring the 10-kubeadm.conf 
sed '/Environment/ i Environment=”cgroup-driver=systemd/cgroup-driver=cgroupfs”' /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf

#Setting the Kubernetes Master i.e. Control-Plane 

echo Setting the Kubernetes Master which is Control-Plane
kubeadm init --apiserver-advertise-address=$MasterIpAddress --pod-network-cidr=10.244.0.0/16

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

