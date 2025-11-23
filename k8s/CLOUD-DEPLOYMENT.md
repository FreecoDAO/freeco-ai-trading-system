# Kubernetes Cloud Deployment Guide

## ☁️ Supported Cloud Platforms

- **AWS EKS** (Elastic Kubernetes Service)
- **Google GKE** (Google Kubernetes Engine)
- **Azure AKS** (Azure Kubernetes Service)
- **DigitalOcean Kubernetes**
- **Linode Kubernetes Engine**

## 🚀 Quick Deploy (Any Cloud)

### Prerequisites

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Install helm (optional, for package management)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Configure kubeconfig
# AWS: aws eks update-kubeconfig --name <cluster-name> --region <region>
# GCP: gcloud container clusters get-credentials <cluster-name>
# Azure: az aks get-credentials -g <resource-group> -n <cluster-name>
```

### Deploy

```bash
# 1. Configure secrets
kubectl create secret generic freeco-secrets \
  --from-literal=NOVITA_API_KEY=your-key \
  --from-literal=MASTER_WALLET_PRIVATE_KEY=your-key \
  -n freeco-ai

# 2. Deploy using kustomization
kubectl apply -k k8s/

# 3. Get dashboard URL
kubectl get svc dashboard -n freeco-ai
```

## AWS EKS Deployment

```bash
# Create EKS cluster
eksctl create cluster --name freeco-ai --region us-east-1 --nodes 3

# Get kubeconfig
aws eks update-kubeconfig --name freeco-ai --region us-east-1

# Deploy
kubectl apply -k k8s/

# Get LoadBalancer IP
kubectl get svc dashboard -n freeco-ai -w
```

## Google GKE Deployment

```bash
# Create GKE cluster
gcloud container clusters create freeco-ai --zone us-central1-a --num-nodes 3

# Get kubeconfig
gcloud container clusters get-credentials freeco-ai --zone us-central1-a

# Deploy
kubectl apply -k k8s/

# Access dashboard
kubectl port-forward -n freeco-ai svc/dashboard 8501:8501
```

## Azure AKS Deployment

```bash
# Create AKS cluster
az aks create -g freeco-ai -n freeco-ai-cluster --node-count 3

# Get kubeconfig
az aks get-credentials -g freeco-ai -n freeco-ai-cluster

# Deploy
kubectl apply -k k8s/

# Get service IP
kubectl get svc dashboard -n freeco-ai
```

## 📊 Monitoring

```bash
# Watch deployments
kubectl get deployments -n freeco-ai -w

# Check pod status
kubectl get pods -n freeco-ai

# View logs
kubectl logs -f -n freeco-ai deployment/ai-signal-generator

# Access dashboard shell
kubectl exec -it -n freeco-ai deployment/dashboard -- /bin/bash

# Port forward
kubectl port-forward -n freeco-ai svc/dashboard 8501:8501
```

## 🔄 Scaling

```bash
# Scale AI Signal Generator
kubectl scale deployment ai-signal-generator --replicas=5 -n freeco-ai

# Scale Dashboard
kubectl scale deployment dashboard --replicas=3 -n freeco-ai

# Auto-scaling (requires metrics server)
kubectl autoscale deployment ai-signal-generator --min=2 --max=10 -n freeco-ai
```

## 🔐 Secrets Management

```bash
# Using AWS Secrets Manager
kubectl create secret generic freeco-secrets \
  --from-file=NOVITA_API_KEY=/path/to/api-key \
  -n freeco-ai

# Using Azure Key Vault
az keyvault secret set --vault-name MyKeyVault --name NOVITA-API-KEY --value <key>

# Using Google Secret Manager
gcloud secrets create novita-api-key --data-file=- <<< "your-key"
```

## 📈 Cost Optimization

- Use spot instances for AI Signal Generator
- Set resource limits appropriately
- Use horizontal pod autoscaling
- Consider reserved instances for stable workloads

## 🆘 Troubleshooting

```bash
# Check cluster status
kubectl cluster-info

# Describe pod for errors
kubectl describe pod <pod-name> -n freeco-ai

# Check events
kubectl get events -n freeco-ai

# Debug pod
kubectl run -it --image=busybox --restart=Never debug -n freeco-ai -- sh
```

## 🗑️ Cleanup

```bash
# Delete deployment
kubectl delete namespace freeco-ai

# Delete EKS cluster
eksctl delete cluster --name freeco-ai --region us-east-1

# Delete GKE cluster
gcloud container clusters delete freeco-ai --zone us-central1-a

# Delete AKS cluster
az aks delete -g freeco-ai -n freeco-ai-cluster
```
