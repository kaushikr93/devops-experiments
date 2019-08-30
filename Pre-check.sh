#!/bin/env bash

#Minimum Requirements of CPU and Memory to be available on the machine

#Master         2 vCPU(s) 2GB RAM
#Worker/Node    2 vCPU(s) 1GB RAM

MinimumMemory=2
MinimumCPU=2

#To check the Memory

Memory=`free -g | grep Mem: | awk '{print $2}'`

echo RAM is $Memory GB

#To check the CPU

CPU=`cat /proc/cpuinfo | grep processor | wc -l`

echo CPU is $CPU cores

if (( $Memory >= $MinimumMemory == 1 && $CPU >= $MinimumCPU == 1 )); then
        echo Memory $Memory GB and CPU cores $CPU is good to go
        exit 0
else
        echo Either Memory $Memory GB or CPU $CPU cores has to be scaled up to proceed
        exit 1
fi
