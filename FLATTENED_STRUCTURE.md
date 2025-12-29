# Flattened Bootstrap Structure

## What Changed

All bootstrap resources have been moved to a single directory to ensure ArgoCD scans all files properly.

### Before (Subdirectories - Not Working)
```
bootstrap/
├── namespaces.yaml
├── quotas/
│   ├── team-a-quota.yaml
│   └── ...
├── limit-ranges/
│   └── default-limits.yaml
└── network-policies/
    └── default-deny-all.yaml
```

### After (Flattened - Should Work)
```
bootstrap/
├── namespaces.yaml
├── team-a-quota.yaml
├── team-b-quota.yaml
├── data-quota.yaml
├── ml-quota.yaml
├── default-limits.yaml
└── default-deny-all.yaml
```

## Why This Fixes the Issue

ArgoCD's plain YAML scanning sometimes doesn't scan subdirectories reliably. By flattening the structure, all files are in one directory that ArgoCD will definitely scan.

## Next Steps

1. **Commit and push the changes:**
   ```bash
   cd data-platform-infra
   git add .
   git commit -m "Flatten bootstrap structure - move all YAML files to single directory"
   git push
   ```

2. **Sync in ArgoCD:**
   - Go to ArgoCD UI
   - Click on "bootstrap" application
   - Click "Refresh" to reload from Git
   - Click "Sync" to apply changes

3. **Verify resources are created:**
   ```bash
   kubectl get resourcequota --all-namespaces
   kubectl get limitrange --all-namespaces
   kubectl get networkpolicies --all-namespaces
   ```

## Files in Bootstrap Directory

- `namespaces.yaml` - All 7 namespaces
- `team-a-quota.yaml` - Resource quota for team-a
- `team-b-quota.yaml` - Resource quota for team-b
- `data-quota.yaml` - Resource quota for data
- `ml-quota.yaml` - Resource quota for ml
- `default-limits.yaml` - Limit ranges for team-a and team-b
- `default-deny-all.yaml` - Network policies for all tenant namespaces

All files are now in the same directory, so ArgoCD will find and sync all of them.

