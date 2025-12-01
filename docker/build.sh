#!/bin/bash
set -e

# Configuration
IMAGE_NAME="smpnet74/devcontainer"
VERSION="${1:-v2}"

echo "🔨 Building local image: ${IMAGE_NAME}:${VERSION}"

# Build for local architecture only
docker build \
    -t ${IMAGE_NAME}:${VERSION} \
    -t ${IMAGE_NAME}:latest \
    -f Dockerfile \
    .

echo "✅ Successfully built locally:"
echo "   ${IMAGE_NAME}:${VERSION}"
echo "   ${IMAGE_NAME}:latest"
echo ""
echo "📝 Update your devcontainer.json to use:"
echo "   \"image\": \"${IMAGE_NAME}:${VERSION}\""
echo ""
echo "🧪 Test it with your devcontainer, then run:"
echo "   ./push.sh ${VERSION}"

