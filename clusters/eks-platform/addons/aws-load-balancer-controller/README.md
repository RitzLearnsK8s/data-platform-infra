# AWS Load Balancer Controller

Kubernetes controller that manages AWS Application Load Balancers (ALB) and Network Load Balancers (NLB).

## What It Does

- Translates Kubernetes Ingress and Service resources into AWS ALBs/NLBs
- Handles routing, SSL termination, and health checks
- Exposes services to the internet

## Why We Need It

**Without it:**
- Services are only accessible inside the cluster
- Can't expose web applications to users
- No automatic load balancing

**With it:**
- Expose services to the internet via ALB/NLB
- HTTPS/TLS termination
- Path-based routing
- Cost-effective (one ALB can handle multiple services)

## Example Usage

```yaml
# Ingress resource
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-app-service
                port:
                  number: 80
```

AWS Load Balancer Controller automatically:
1. Creates an ALB in AWS
2. Configures listeners and target groups
3. Routes traffic to your pods
4. Handles SSL termination

## Installation

This is managed via ArgoCD. The application will:
1. Install AWS Load Balancer Controller using Helm chart from AWS EKS charts
2. Deploy to `kube-system` namespace
3. Use existing IRSA service account (`aws-load-balancer-controller`)
4. Run on system nodes (with tolerations)

## Prerequisites

✅ IRSA service account already configured in cluster config:
- Service account: `aws-load-balancer-controller`
- IAM role with AWS Load Balancer Controller permissions

## Verify Installation

```bash
# Check if ALB Controller pods are running
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Check controller logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

## Troubleshooting

If Ingress resources don't create ALBs:
1. Check pod status: `kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller`
2. Check pod logs: `kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller`
3. Verify IRSA: `kubectl describe sa aws-load-balancer-controller -n kube-system`
4. Check IAM permissions: Ensure service account has ALB/NLB permissions

