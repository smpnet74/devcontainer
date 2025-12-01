#!/bin/bash
set -e

# Configuration
IMAGE_NAME="smpnet74/devcontainer"
VERSION="${1:-v2}"

echo "🚀 Pushing multi-architecture image: ${IMAGE_NAME}:${VERSION}"

# Create buildx builder if it doesn't exist
if ! docker buildx ls | grep -q multiarch; then
    echo "📦 Creating buildx builder..."
    docker buildx create --name multiarch --use
fi

# Use the multiarch builder
docker buildx use multiarch

# Build and push for both architectures
echo "🏗️  Building for linux/amd64 and linux/arm64..."
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t ${IMAGE_NAME}:${VERSION} \
    -t ${IMAGE_NAME}:latest \
    -f Dockerfile \
    --push \
    .

echo "✅ Successfully built and pushed:"
echo "   ${IMAGE_NAME}:${VERSION}"
echo "   ${IMAGE_NAME}:latest"
echo ""
echo "🌍 Available on both architectures:"
echo "   - linux/amd64 (Intel/AMD)"
echo "   - linux/arm64 (Apple Silicon)"

