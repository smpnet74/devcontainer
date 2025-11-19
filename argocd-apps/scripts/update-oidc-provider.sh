#!/bin/bash
set -e

# Script to update OIDC provider ID in ArgoCD manifests from Terraform output
# Run this after recreating the EKS cluster or when OIDC provider changes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARGOCD_APPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TERRAFORM_DIR="$ARGOCD_APPS_DIR/../fargate-cluster/eks"

echo "=================================="
echo "Update OIDC Provider in ArgoCD Manifests"
echo "=================================="
echo ""

# Check if terraform directory exists
if [ ! -d "$TERRAFORM_DIR" ]; then
    echo "❌ Error: Terraform directory not found at $TERRAFORM_DIR"
    exit 1
fi

# Check if terraform state exists
if [ ! -f "$TERRAFORM_DIR/terraform.tfstate" ]; then
    echo "❌ Error: terraform.tfstate not found at $TERRAFORM_DIR"
    echo "   Run 'terraform apply' in the eks directory first."
    exit 1
fi

echo "📂 ArgoCD Apps Directory: $ARGOCD_APPS_DIR"
echo "📂 Terraform Directory:   $TERRAFORM_DIR"
echo ""

# Navigate to terraform directory
cd "$TERRAFORM_DIR"

echo "📖 Reading Terraform outputs..."

# Get OIDC provider ARN from terraform output
OIDC_PROVIDER_ARN=$(terraform output -raw oidc_provider_arn 2>/dev/null)
if [ -z "$OIDC_PROVIDER_ARN" ]; then
    echo "❌ Error: Could not read oidc_provider_arn from Terraform output"
    echo "   Make sure the output exists in your terraform configuration."
    exit 1
fi

# Extract OIDC provider ID from ARN
# ARN format: arn:aws:iam::ACCOUNT_ID:oidc-provider/oidc.eks.REGION.amazonaws.com/id/OIDC_ID
OIDC_PROVIDER_ID=$(echo "$OIDC_PROVIDER_ARN" | grep -oP 'id/\K[A-Z0-9]+')
if [ -z "$OIDC_PROVIDER_ID" ]; then
    echo "❌ Error: Could not extract OIDC provider ID from ARN: $OIDC_PROVIDER_ARN"
    exit 1
fi

# Extract OIDC provider URL (without https://)
OIDC_PROVIDER_URL=$(echo "$OIDC_PROVIDER_ARN" | sed 's|arn:aws:iam::[0-9]*:oidc-provider/||')

echo "✅ OIDC Provider ARN: $OIDC_PROVIDER_ARN"
echo "✅ OIDC Provider ID:  $OIDC_PROVIDER_ID"
echo "✅ OIDC Provider URL: $OIDC_PROVIDER_URL"
echo ""

# Files to update
FILES_TO_UPDATE=(
    "crossplane-provider-keyspaces-irsa.yaml"
    "crossplane-provider-opensearchserverless-irsa.yaml"
    "temporal-infrastructure.yaml"
)

# Find all unique OIDC IDs currently in the files
OLD_OIDC_IDS=()
for file in "${FILES_TO_UPDATE[@]}"; do
    filepath="$ARGOCD_APPS_DIR/$file"
    if [ -f "$filepath" ]; then
        # Extract any 32-character alphanumeric OIDC IDs from the file
        while IFS= read -r id; do
            if [[ ! " ${OLD_OIDC_IDS[@]} " =~ " ${id} " ]] && [ -n "$id" ] && [ "$id" != "$OIDC_PROVIDER_ID" ]; then
                OLD_OIDC_IDS+=("$id")
            fi
        done < <(grep -oP 'id/\K[A-Z0-9]{32}' "$filepath" 2>/dev/null || true)
    fi
done

echo "📝 Files to update:"
for file in "${FILES_TO_UPDATE[@]}"; do
    filepath="$ARGOCD_APPS_DIR/$file"
    if [ -f "$filepath" ]; then
        echo "   ✓ $file"
    else
        echo "   ✗ $file (not found - will skip)"
    fi
done
echo ""

if [ ${#OLD_OIDC_IDS[@]} -gt 0 ]; then
    echo "🔍 Old OIDC Provider IDs found (will be replaced):"
    for old_id in "${OLD_OIDC_IDS[@]}"; do
        echo "   - $old_id"
    done
    echo ""
else
    echo "ℹ️  No old OIDC IDs found - files may already be up to date"
    echo ""
fi

# Ask for confirmation (unless --yes flag is provided)
if [[ "$1" != "--yes" ]] && [[ "$1" != "-y" ]]; then
    read -p "❓ Update files with new OIDC Provider ID: $OIDC_PROVIDER_ID? (y/n) " -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Aborted by user."
        exit 0
    fi
    echo ""
else
    echo "✅ Auto-confirming update (--yes flag provided)"
    echo ""
fi

# Update each file
UPDATED_COUNT=0
UNCHANGED_COUNT=0

for file in "${FILES_TO_UPDATE[@]}"; do
    filepath="$ARGOCD_APPS_DIR/$file"

    if [ ! -f "$filepath" ]; then
        echo "⏭️  Skipping $file (not found)"
        continue
    fi

    # Create backup
    cp "$filepath" "$filepath.backup"

    # Replace all old OIDC IDs with the new one
    CHANGED=0
    if [ ${#OLD_OIDC_IDS[@]} -gt 0 ]; then
        for old_id in "${OLD_OIDC_IDS[@]}"; do
            if grep -q "$old_id" "$filepath"; then
                sed -i "s/$old_id/$OIDC_PROVIDER_ID/g" "$filepath"
                CHANGED=1
            fi
        done
    fi

    if [ $CHANGED -eq 1 ]; then
        echo "✅ Updated $file"
        UPDATED_COUNT=$((UPDATED_COUNT + 1))
    else
        echo "➖ No changes needed in $file"
        rm "$filepath.backup"  # Remove backup if no changes
        UNCHANGED_COUNT=$((UNCHANGED_COUNT + 1))
    fi
done

echo ""
echo "=================================="
echo "✨ Summary"
echo "=================================="
echo "Files updated:   $UPDATED_COUNT"
echo "Files unchanged: $UNCHANGED_COUNT"
echo "New OIDC ID:     $OIDC_PROVIDER_ID"
echo ""

if [ $UPDATED_COUNT -gt 0 ]; then
    echo "📦 Backups created with .backup extension"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Review the changes:"
    echo "      git diff argocd-apps/"
    echo ""
    echo "   2. If changes look good, commit them:"
    echo "      git add argocd-apps/"
    echo "      git commit -m \"Update OIDC provider ID to $OIDC_PROVIDER_ID\""
    echo ""
    echo "   3. Apply the updated manifests:"
    echo "      kubectl apply -f argocd-apps/crossplane-provider-keyspaces-irsa.yaml"
    echo "      kubectl apply -f argocd-apps/crossplane-provider-opensearchserverless-irsa.yaml"
    echo "      kubectl apply -f argocd-apps/temporal-infrastructure.yaml"
    echo ""
    echo "   4. Or let ArgoCD auto-sync if enabled"
else
    echo "✅ All files are already up to date!"
fi

echo "=================================="
