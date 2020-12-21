#!/usr/bin/env bash

## Minikube setup for local work
# This script is in progress and unfinished

# In Zsh use bash path/to/setup.sh
# Script must be run from directory script is located at

#  Ansi color code variables
# Thanks to https://stackoverflow.com/a/5947802/460885
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create a namespace
kubectl apply -f namespace.yml

# Set namespace as default
NAMESPACE="smt-local"
kubectl config set-context --current --namespace=$NAMESPACE

# Enable Ingress on Kube
minikube addons enable ingress

# Check if Nginx Ingress has been enabled
echo -e "${BLUE}Check if Ingress Nginx has been enabled and is up and running${NC}";
kubectl get pods -n kube-system

# Set up Nginx Ingress Resource
kubectl apply -f services/ingress.yml

# Check if  Ingress Resource is up running
echo -e "${BLUE}Check Ingress details including ip address${NC}";
kubectl get ingress

# Build Persistent Volumes and Volume Claims
# You can comment out the ones you do not need
kubectl apply -f storage/code-pv-claim.yml
kubectl apply -f storage/nginx-pv-claim.yml
kubectl apply -f storage/mysql-pv-claim.yml
kubectl apply -f storage/redis-pv-claim.yml

echo -e  "${BLUE}Sleeping for 3 seconds…${NC}"
sleep 3
echo -e "${BLUE}Completed${NC}"

# Check all Pvs are up and running
echo -e "${BLUE}Show all added volumes with storage capacity, status, claim and storage class${NC}";
kubectl get pv

# Set secret for MySQL
echo -e "${BLUE}Start or update all Services we need${NC}";
kubectl apply -f secret.yml

# Set up PHP Service
kubectl apply -f services/php.yml

# Set up Nginx Service
kubectl apply -f services/nginx.yml

# Set up Workspace Service
kubectl apply -f services/workspace.yml

echo -e "${BLUE}Sleeping for 3 seconds…${NC}"
sleep 3
echo -e "${BLUE}Completed${NC}"

# Show all Services
echo -e "${BLUE}Show all Services currently running in our chosen namespace${NC}";
kubectl get services

# Deployments
echo -e "${BLUE}Start or update all Deployments we need${NC}";
kubectl apply -f deployments/php.yml

# Nginx Configuration file
kubectl apply -f ../configs/nginx_configMap.yaml

# Nginx Deployment
kubectl apply -f deployments/nginx.yml

# then we have the other deployments excluding the databases:

# PHP Worker not done yet
# kubectl apply -f local/deployments/php-worker.yml

# Workspace Deployment
kubectl apply -f deployments/workspace.yml

## Databases
# To run the MySQL database and Redis containers run
kubectl apply -f deployments/mysql.yml

# Redis not done yet
# kubectl apply -f deployments/redis.yml


echo -e "${BLUE}Sleeping for 3 seconds…${NC}"
sleep 3
echo -e "${BLUE}Completed${NC}"

# Get All Deployments
echo -e "${BLUE}Display all current deployments${NC}";
kubectl get deployments

echo -e "${BLUE}All has been setup for local Minikube work with Laravel.${NC}";
echo -e "${BLUE}Here a quick overview${NC}";
kubectl get all