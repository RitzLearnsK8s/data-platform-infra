# Guestbook Application

Kubernetes Guestbook application for testing Phase 2 add-ons.

## What It Does

- **Frontend**: Web UI for guestbook entries (3 replicas)
- **Backend**: Redis master (StatefulSet with persistent storage)
- **Backend**: Redis replicas (2 replicas for read scaling)
- **Ingress**: ALB Ingress for external access

## Why We Use It

This app tests all Phase 2 add-ons:
- ✅ **EBS CSI Driver**: Redis master uses PVC (persistent storage)
- ✅ **AWS Load Balancer Controller**: Ingress creates ALB
- ✅ **metrics-server**: Pod metrics collection
- ✅ **Karpenter**: Auto-provisions nodes for pods

## Architecture

```
Internet → ALB → Frontend (3 pods) → Redis Master (1 pod) + Redis Replicas (2 pods)
                                    ↓
                              Persistent Volume (EBS)
```

## Installation

This is managed via ArgoCD. The application will:
1. Deploy frontend, redis-master, and redis-replica
2. Create PVC for Redis master (tests EBS CSI)
3. Create Ingress (tests ALB Controller)
4. Karpenter provisions nodes if needed

## Verify Installation

```bash
# Check all pods are running
kubectl get pods -n team-a

# Check PVC is bound (EBS CSI test)
kubectl get pvc -n team-a

# Check Ingress shows ALB address (ALB Controller test)
kubectl get ingress -n team-a

# Get ALB address
ALB_ADDRESS=$(kubectl get ingress guestbook-ingress -n team-a -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Access the app at: http://$ALB_ADDRESS"
```

## Test the App

1. Get ALB address from Ingress
2. Open in browser: `http://<ALB-ADDRESS>`
3. Add guestbook entries
4. Verify entries persist (Redis master with EBS storage)

## Cleanup

To remove the app:
```bash
kubectl delete application guestbook -n argocd
```

Or delete via ArgoCD UI.

