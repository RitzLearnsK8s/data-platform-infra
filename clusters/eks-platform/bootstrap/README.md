# Bootstrap Resources

All bootstrap resources are in this single directory for ArgoCD to scan.

## Files

- `namespaces.yaml` - All tenant namespaces
- `team-a-quota.yaml` - Resource quota for team-a namespace
- `team-b-quota.yaml` - Resource quota for team-b namespace
- `data-quota.yaml` - Resource quota for data namespace
- `ml-quota.yaml` - Resource quota for ml namespace
- `default-limits.yaml` - Limit ranges for team-a and team-b
- `default-deny-all.yaml` - Network policies for all tenant namespaces

## Why Flattened Structure?

ArgoCD's plain YAML scanning works best when all files are in a single directory. Subdirectories can sometimes be missed, so we've flattened the structure to ensure all resources are discovered and synced.

