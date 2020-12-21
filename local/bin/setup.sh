#!/usr/bin/env bash

## Minikube setup for local work
# This script is in progress and unfinished

# Create a namespace
kubectl apply -f .../namespace.yml

# Set namespace as default
NAMESPACE="smt-local"
kubectl config set-context --current --namespace=$NAMESPACE

# Enable Ingress on Kube
minikube addons enable ingress

# Check if Nginx Ingress has been enabled
kubectl get pods -n kube-system

# Set up Nginx Ingress Resource
kubectl apply -f ../services/ingress.yml

# Check if  Ingress Resource is up running
kubectl get ingress -n smt-local

# Build Persistent Volumes and Volume Claims
# You can comment out the ones you do not need
kubectl apply -f ../storage/code-pv-claim.yml
kubectl apply -f ../storage/nginx-pv-claim.yml
kubectl apply -f ../storage/mysql-pv-claim.yml
kubectl apply -f ../storage/redis-pv-claim.yml


# Set secret for MySQL
kubectl apply -f ../secret.yml

# Set up PHP Service
kubectl apply -f ../services/php.yml

# Set up Nginx Service
kubectl apply -f ../services/nginx.yml

# Set up Workspace Service
kubectl apply -f ../services/workspace.yml

# Deployments

kubectl apply -f ../deployments/php.yml

# Nginx Configuration file
kubectl apply -f configs/nginx_configMap.yaml

# Nginx Deployment
kubectl apply -f ../deployments/nginx.yml

# then we have the other deployments excluding the databases:

# PHP Worker not done yet
# kubectl apply -f local/deployments/php-worker.yml

# Workspace Deployment
kubectl apply -f ../deployments/workspace.yml

## Databases

# To run the MySQL database and Redis containers run
kubectl apply -f ../deployments/mysql.yml
kubectl apply -f ../deployments/redis.yml


# echo "All has been setup for local Minikube work with Laravel.";