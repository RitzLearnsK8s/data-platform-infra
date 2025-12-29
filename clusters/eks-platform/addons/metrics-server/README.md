# metrics-server

Kubernetes metrics-server for resource usage metrics.

## What It Does

- Collects CPU and memory usage from nodes and pods
- Provides metrics API for Kubernetes
- Enables `kubectl top` commands
- Required for Horizontal Pod Autoscaler (HPA)

## Installation

This is managed via ArgoCD. The application will:
1. Install metrics-server using Helm chart from official repo
2. Deploy to `kube-system` namespace
3. Run on system nodes (with tolerations)
4. Uses inline values in the ArgoCD Application (no separate values.yaml needed)

## Verify Installation

```bash
# Check if metrics-server pod is running
kubectl get pods -n kube-system -l k8s-app=metrics-server

# Test metrics API
kubectl top nodes
kubectl top pods --all-namespaces
```

## Troubleshooting

If `kubectl top` doesn't work:
1. Check pod status: `kubectl get pods -n kube-system -l k8s-app=metrics-server`
2. Check pod logs: `kubectl logs -n kube-system -l k8s-app=metrics-server`
3. Verify metrics API: `kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes`

