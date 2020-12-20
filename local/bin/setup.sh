#!/usr/bin/env bash

## Minikube setup 
# This script is in progress and unfinished

# Create a namespace
kubectl apply -f local/namespace.yml

# Set namespace as default
NAMESPACE="smt-local"
kubectl config set-context --current --namespace=$NAMESPACE

# Enable Ingress on Kube
minikube addons enable ingress

# Check if Nginx Ingress has been enabled
kubectl get pods -n kube-system

# Set up Nginx Ingress Resource
kubectl apply -f local/services/ingress.yml

# Check if  Ingress Resource is up running
kubectl get ingress -n smt-local

# Build Persistent Volumes and Volume Claims
# You can comment out the ones you do not need
kubectl apply -f local/storage/code-pv-claim.yml
kubectl apply -f local/storage/nginx-pv-claim.yml
kubectl apply -f local/storage/mysql-pv-claim.yml
kubectl apply -f local/storage/redis-pv-claim.yml


# echo "All has been setup for local Minikube work with Laravel.";