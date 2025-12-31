# Karpenter

Karpenter is a Kubernetes node autoscaler that automatically provisions nodes based on pod requirements.

## What It Does

- Automatically provisions EC2 instances when pods can't be scheduled
- Right-sizes nodes based on pod resource requests
- Consolidates nodes when underutilized
- Supports both on-demand and spot instances

## Why We Need It

**Without it:**
- Manual node group management
- Over-provisioning (wasted costs)
- Under-provisioning (pods pending)
- Slow scaling

**With it:**
- Automatic node provisioning
- Cost-optimized (right-sized nodes)
- Fast scaling (seconds, not minutes)
- Consolidation (removes unused nodes)

## Installation

This is managed via ArgoCD. The application will:
1. Install Karpenter using Helm chart from ECR
2. Deploy to `karpenter` namespace
3. Use IRSA service account (`KarpenterControllerRole-eks-platform`)
4. Run on system nodes (with tolerations)

## Prerequisites

✅ IAM roles created:
- Controller role: `KarpenterControllerRole-eks-platform`
- Node instance profile: `KarpenterNodeInstanceProfile-eks-platform`
- Node role: `KarpenterNodeRole-eks-platform`

✅ Subnets tagged:
- All subnets tagged with `karpenter.sh/discovery=eks-platform`

## NodePool Configuration

The `provisioner.yaml` defines:
- **Instance types**: t3.small, t3.medium, t3.large, t3.xlarge
- **Capacity type**: On-demand (can add spot later)
- **Limits**: Max 1000 CPU cores, 1000 GiB memory
- **Consolidation**: Removes empty nodes after 30s

## EC2NodeClass Configuration

The `EC2NodeClass` defines:
- **AMI**: Amazon Linux 2 (EKS optimized)
- **Subnets**: Uses tagged subnets
- **Security groups**: Cluster security groups
- **Instance profile**: For nodes Karpenter creates
- **Storage**: 20Gi gp3 volumes

## Verify Installation

```bash
# Check Karpenter pods
kubectl get pods -n karpenter

# Check NodePool
kubectl get nodepool default

# Check EC2NodeClass
kubectl get ec2nodeclass default

# Check Karpenter logs
kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter
```

## Testing

Deploy a test pod with resource requests:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-karpenter
spec:
  containers:
  - name: test
    image: nginx
    resources:
      requests:
        cpu: 1
        memory: 1Gi
```

Karpenter should automatically provision a node for this pod.

## Troubleshooting

If nodes aren't being provisioned:
1. Check Karpenter logs: `kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter`
2. Verify IAM permissions: Check controller role has required policies
3. Check subnet tags: `aws ec2 describe-subnets --filters "Name=tag:karpenter.sh/discovery,Values=eks-platform"`
4. Verify NodePool: `kubectl describe nodepool default`
5. Check pod events: `kubectl describe pod <pod-name>`


