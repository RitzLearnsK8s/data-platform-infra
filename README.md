# Data Platform Infrastructure

GitOps repository for managing the EKS platform infrastructure.

## Repository Structure

```
data-platform-infra/
└── clusters/
    └── eks-platform/
        ├── bootstrap/              # Bootstrap resources (namespaces, quotas, network policies)
        │   ├── namespaces.yaml
        │   ├── quotas/
        │   ├── limit-ranges/
        │   └── network-policies/
        ├── addons/                 # Core add-ons (to be added)
        ├── karpenter/              # Karpenter configuration (to be added)
        ├── jenkins/                # Jenkins setup (to be added)
        └── bootstrap-app.yaml      # ArgoCD Application for bootstrap
```

## Setup Instructions

### 1. Create GitHub Repository

1. Go to https://github.com/RitzLearnsK8s
2. Create a new repository named `data-platform-infra`
3. Make it public (or private if preferred)

### 2. Initialize and Push

```bash
cd data-platform-infra
git init
git add .
git commit -m "Initial GitOps structure with bootstrap resources"
git branch -M main
git remote add origin https://github.com/RitzLearnsK8s/data-platform-infra.git
git push -u origin main
```

### 3. Add Repository to ArgoCD

#### Via ArgoCD UI:
1. Go to ArgoCD UI → Settings → Repositories
2. Click "Connect Repo"
3. Add: `https://github.com/RitzLearnsK8s/data-platform-infra.git`
4. For public repo: No authentication needed
5. Click "Connect"

#### Via CLI:
```bash
argocd repo add https://github.com/RitzLearnsK8s/data-platform-infra.git
```

### 4. Create Bootstrap Application

```bash
docker run --rm \
  -v ~/.aws:/root/.aws \
  -v ~/.kube:/root/.kube \
  -v $(pwd):/workspace \
  eks-toolbox:latest \
  kubectl apply -f /workspace/clusters/eks-platform/bootstrap-app.yaml
```

### 5. Sync in ArgoCD

- Go to ArgoCD UI
- Find the "bootstrap" application
- Click "Sync" (or wait for auto-sync if enabled)

## What Gets Deployed

The bootstrap application deploys:
- **Namespaces**: team-a, team-b, data, ml, cicd, platform, monitoring
- **Resource Quotas**: CPU and memory limits per namespace
- **Limit Ranges**: Default resource requests/limits
- **Network Policies**: Default deny-all policies

## GitOps Workflow

1. Make changes to YAML files in this repository
2. Commit and push to GitHub
3. ArgoCD automatically syncs changes to the cluster
4. Manual changes in the cluster are automatically reverted (self-healing)

## Next Steps

- Add core add-ons (ALB Controller, EBS CSI, cert-manager, metrics-server)
- Set up Karpenter for autoscaling
- Configure Jenkins for CI/CD
- Add application deployments

## References

- ArgoCD Documentation: https://argo-cd.readthedocs.io/
- EKS Best Practices: https://aws.github.io/aws-eks-best-practices/

