#!/bin/bash
# Initialize Git repository and push to GitHub

set -e

REPO_URL="https://github.com/RitzLearnsK8s/data-platform-infra.git"

echo "🚀 Setting up Git repository for data-platform-infra"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Check if already a git repo
if [ -d .git ]; then
    echo "⚠️  Already a Git repository"
    read -p "Continue with push? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
else
    echo "📝 Initializing Git repository..."
    git init
    git branch -M main
fi

# Check if remote exists
if git remote get-url origin &> /dev/null; then
    CURRENT_REMOTE=$(git remote get-url origin)
    if [ "$CURRENT_REMOTE" != "$REPO_URL" ]; then
        echo "⚠️  Remote already exists with different URL: $CURRENT_REMOTE"
        read -p "Update to $REPO_URL? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git remote set-url origin "$REPO_URL"
        fi
    else
        echo "✅ Remote already configured: $REPO_URL"
    fi
else
    echo "📝 Adding remote: $REPO_URL"
    git remote add origin "$REPO_URL"
fi

# Add all files
echo "📝 Staging files..."
git add .

# Check if there are changes
if git diff --staged --quiet; then
    echo "⚠️  No changes to commit"
else
    echo "📝 Committing files..."
    git commit -m "Initial GitOps structure with bootstrap resources

- Namespaces for all tenants (team-a, team-b, data, ml, cicd, platform, monitoring)
- Resource quotas per namespace
- Limit ranges for default resource limits
- Network policies (default deny-all)
- ArgoCD bootstrap application"
fi

# Push to GitHub
echo ""
echo "📤 Pushing to GitHub..."
echo "   Repository: $REPO_URL"
echo ""
echo "⚠️  Make sure you have:"
echo "   1. Created the repository on GitHub: https://github.com/RitzLearnsK8s/data-platform-infra"
echo "   2. Authenticated with GitHub (SSH key or personal access token)"
echo ""

read -p "Continue with push? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled. You can push manually later with:"
    echo "  git push -u origin main"
    exit 0
fi

# Try to push
if git push -u origin main; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Add repository to ArgoCD:"
    echo "      - Go to ArgoCD UI → Settings → Repositories"
    echo "      - Add: $REPO_URL"
    echo ""
    echo "   2. Create bootstrap application:"
    echo "      docker run --rm \\"
    echo "        -v ~/.aws:/root/.aws \\"
    echo "        -v ~/.kube:/root/.kube \\"
    echo "        -v \$(pwd):/workspace \\"
    echo "        eks-toolbox:latest \\"
    echo "        kubectl apply -f /workspace/clusters/eks-platform/bootstrap-app.yaml"
    echo ""
    echo "   3. Sync in ArgoCD UI"
else
    echo ""
    echo "❌ Push failed. Common issues:"
    echo "   - Repository doesn't exist on GitHub (create it first)"
    echo "   - Authentication failed (check SSH keys or GitHub token)"
    echo "   - No write access to repository"
    echo ""
    echo "Create the repository at: https://github.com/new"
    echo "Repository name: data-platform-infra"
    echo "Then try again or push manually: git push -u origin main"
fi

