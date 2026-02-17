#!/bin/bash
set -e

# Install Flutter SDK if not present
if [ ! -d "flutter" ]; then
  git clone --depth 1 https://github.com/flutter/flutter.git
fi
export PATH="$PATH:$(pwd)/flutter/bin"

flutter config --enable-web
flutter pub get
flutter build web --release
