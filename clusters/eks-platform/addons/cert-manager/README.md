# cert-manager

Automatic certificate management for Kubernetes.

## What It Does

- Automatically provisions and renews SSL/TLS certificates
- Integrates with Let's Encrypt (free certificates)
- Stores certificates as Kubernetes secrets
- Works with AWS Load Balancer Controller for HTTPS

## Why We Need It

**Without it:**
- Manual certificate creation
- Manual renewal (certificates expire every 90 days)
- Security risks from expired certificates
- No automatic HTTPS

**With it:**
- Automatic certificate provisioning
- Automatic renewal before expiration
- Secure HTTPS by default
- Works seamlessly with Ingress resources

## Example Usage

```yaml
# ClusterIssuer (Let's Encrypt)
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
      - http01:
          ingress:
            class: alb

# Ingress with TLS
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    alb.ingress.kubernetes.io/scheme: internet-facing
spec:
  tls:
    - hosts:
        - myapp.example.com
      secretName: my-app-tls
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

cert-manager automatically:
1. Creates a certificate request
2. Gets certificate from Let's Encrypt
3. Stores in Kubernetes secret
4. Automatically renews before expiration

## Installation

This is managed via ArgoCD. The application will:
1. Install cert-manager using Helm chart from Jetstack
2. Deploy to `cert-manager` namespace
3. Install CRDs automatically
4. Run on system nodes (with tolerations)

## Verify Installation

```bash
# Check if cert-manager pods are running
kubectl get pods -n cert-manager

# Should see:
# - cert-manager (controller)
# - cert-manager-cainjector
# - cert-manager-webhook

# Check CRDs
kubectl get crd | grep cert-manager

# Should see:
# - certificates.cert-manager.io
# - certificaterequests.cert-manager.io
# - clusterissuers.cert-manager.io
# - issuers.cert-manager.io
```

## Next Steps

After installation, create a ClusterIssuer for Let's Encrypt:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
      - http01:
          ingress:
            class: alb
```

## Troubleshooting

If certificates aren't being issued:
1. Check pod status: `kubectl get pods -n cert-manager`
2. Check controller logs: `kubectl logs -n cert-manager -l app.kubernetes.io/name=cert-manager`
3. Check certificate status: `kubectl describe certificate -n <namespace> <cert-name>`
4. Verify ClusterIssuer: `kubectl describe clusterissuer letsencrypt-prod`

