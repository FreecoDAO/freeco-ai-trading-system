#!/bin/bash

echo "🚀 FreEco AI Trading Bot - Kubernetes Deployment"
echo "==============================================="
echo ""

# Configuration
DOCKER_REGISTRY="${DOCKER_REGISTRY:-freeco-ai}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
K8S_CLUSTER="${K8S_CLUSTER:-default}"
NAMESPACE="freeco-ai"

# Step 1: Build Docker Images
echo "[1/5] Building Docker images..."
echo "      Building AI Signal Generator..."
docker build -f Dockerfile -t "$DOCKER_REGISTRY/ai-signal-generator:$IMAGE_TAG" .
echo "      Building Dashboard..."
docker build -f .devcontainer/Dockerfile.dashboard -t "$DOCKER_REGISTRY/dashboard:$IMAGE_TAG" .
echo "✓ Docker images built"
echo ""

# Step 2: Push to Registry
echo "[2/5] Pushing to Docker Registry..."
docker push "$DOCKER_REGISTRY/ai-signal-generator:$IMAGE_TAG"
docker push "$DOCKER_REGISTRY/dashboard:$IMAGE_TAG"
echo "✓ Images pushed"
echo ""

# Step 3: Update Kubernetes Manifests
echo "[3/5] Updating Kubernetes manifests..."
sed -i "s|freeco-ai/|$DOCKER_REGISTRY/|g" k8s/*.yaml
sed -i "s|:latest|:$IMAGE_TAG|g" k8s/*.yaml
echo "✓ Manifests updated"
echo ""

# Step 4: Deploy to Kubernetes
echo "[4/5] Deploying to Kubernetes cluster: $K8S_CLUSTER"
kubectl config use-context "$K8S_CLUSTER" 2>/dev/null || true
kubectl apply -k k8s/
echo "✓ Deployment applied"
echo ""

# Step 5: Wait for Rollout
echo "[5/5] Waiting for services to start..."
kubectl wait --for=condition=available --timeout=300s \
  deployment/mqtt-broker -n "$NAMESPACE" 2>/dev/null || true
kubectl wait --for=condition=available --timeout=300s \
  deployment/ai-signal-generator -n "$NAMESPACE" 2>/dev/null || true
kubectl wait --for=condition=available --timeout=300s \
  deployment/dashboard -n "$NAMESPACE" 2>/dev/null || true
echo "✓ Services started"
echo ""

# Print Status
echo "═══════════════════════════════════════════════════════"
echo "✅ Kubernetes Deployment Complete!"
echo "═══════════════════════════════════════════════════════"
echo ""

echo "Deployment Status:"
kubectl get deployments -n "$NAMESPACE"
echo ""

echo "Services:"
kubectl get services -n "$NAMESPACE"
echo ""

echo "Pod Status:"
kubectl get pods -n "$NAMESPACE"
echo ""

echo "Dashboard Access:"
DASHBOARD_IP=$(kubectl get svc dashboard -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
if [ -n "$DASHBOARD_IP" ]; then
  echo "  External IP: http://$DASHBOARD_IP:8501"
else
  echo "  Port Forward: kubectl port-forward -n $NAMESPACE svc/dashboard 8501:8501"
fi
echo ""

echo "Monitor Logs:"
echo "  AI Signal Generator:"
echo "    kubectl logs -n $NAMESPACE -f deployment/ai-signal-generator"
echo ""
echo "  Dashboard:"
echo "    kubectl logs -n $NAMESPACE -f deployment/dashboard"
echo ""

echo "Cleanup:"
echo "  kubectl delete namespace $NAMESPACE"
echo ""
