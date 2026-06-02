#!/bin/bash
echo "Installing Flutter for Vercel..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

echo "Checking Flutter version..."
flutter --version

echo "Enabling Flutter Web..."
flutter config --enable-web

echo "Getting dependencies..."
flutter pub get

echo "Generating .env file from Vercel Environment Variables..."
echo "GROK_API_KEY=$GROK_API_KEY" > .env

echo "Building Flutter Web..."
flutter build web --release
