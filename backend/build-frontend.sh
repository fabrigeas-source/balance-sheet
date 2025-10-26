#!/bin/bash
# Build Flutter web app and copy to backend static folder
set -e

cd "$(dirname "$0")/.."

# Build Flutter web app
flutter build web

# Remove old static files
rm -rf backend/public/*

# Copy new build to backend static folder
cp -r build/web/* backend/public/

echo "Frontend built and copied to backend/public."