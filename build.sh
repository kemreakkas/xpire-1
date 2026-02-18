#!/bin/bash
set -e

# Install Flutter SDK if not present
if [ ! -d "flutter" ]; then
  git clone --depth 1 https://github.com/flutter/flutter.git
fi
export PATH="$PATH:$(pwd)/flutter/bin"

flutter config --enable-web
flutter pub get
# SUPABASE_URL and SUPABASE_ANON_KEY from Vercel Environment Variables
flutter build web --release \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:-}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"
