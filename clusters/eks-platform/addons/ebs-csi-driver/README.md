# EBS CSI Driver

Amazon EBS Container Storage Interface (CSI) driver for Kubernetes.

## What It Does

- Allows Kubernetes to dynamically provision and manage EBS volumes
- Required for PersistentVolumes (PVs) and PersistentVolumeClaims (PVCs)
- Enables stateful applications (databases, file storage, etc.)

## Why We Need It

**Without it:**
- Can't create PVCs - pods that need storage will fail
- No persistent storage for databases
- Can't run stateful workloads

**With it:**
- Pods can request storage via PVCs
- EBS volumes are automatically created and attached
- Supports dynamic volume provisioning

## Example Usage

```yaml
# Pod requests storage
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-storage
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp3  # ← EBS CSI Driver handles this
  resources:
    requests:
      storage: 10Gi
```

EBS CSI Driver automatically:
1. Creates an EBS volume in AWS
2. Attaches it to the node
3. Makes it available to the pod

## Installation

This is managed via ArgoCD. The application will:
1. Install EBS CSI Driver using Helm chart from official repo
2. Deploy to `kube-system` namespace
3. Use existing IRSA service account (`ebs-csi-controller-sa`)
4. Run on system nodes (with tolerations)

## Prerequisites

✅ IRSA service account already configured in cluster config:
- Service account: `ebs-csi-controller-sa`
- IAM role: `arn:aws:iam::189562476119:role/eksctl-eks-platform-addon-iamserviceaccount-k-Role1-Btjhk93qKw3v`

## Verify Installation

```bash
# Check if EBS CSI Driver pods are running
kubectl get pods -n kube-system -l app=ebs-csi-controller

# Check StorageClass
kubectl get storageclass

# Should see gp3, gp2, or similar EBS storage classes
```

## Troubleshooting

If PVCs are stuck in "Pending":
1. Check pod status: `kubectl get pods -n kube-system -l app=ebs-csi-controller`
2. Check pod logs: `kubectl logs -n kube-system -l app=ebs-csi-controller`
3. Verify IRSA: `kubectl describe sa ebs-csi-controller-sa -n kube-system`
4. Check events: `kubectl get events -n kube-system --sort-by='.lastTimestamp'`

