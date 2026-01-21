#!/bin/bash

# 1. Install Flutter
echo "Downloading Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

# 2. Verify Flutter installation
echo "Checking Flutter version..."
flutter --version

# 3. Enable web
echo "Cleaning flutter build..."
flutter clean
flutter config --enable-web

# 4. Get dependencies
echo "Getting dependencies..."
flutter pub get

# 5. Build web
echo "Building Flutter Web..."
flutter build web --release --base-href /

# 6. Prepare public directory
echo "Moving build to public/..."
rm -rf public
mkdir -p public
cp -r build/web/* public/

# 7. Verify public content
echo "Verifying public/ content:"
ls -la public/

if [ ! -f "public/main.dart.js" ]; then
    echo "ERROR: main.dart.js not found in public/!"
    exit 1
fi

echo "Build complete! Files are in 'public' directory."
