#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
FLUTTER="${ROOT}/flutter/bin/flutter"

# Install Flutter SDK if not present (Vercel installCommand may have done this)
if [ ! -x "$FLUTTER" ]; then
  if [ ! -d "flutter" ]; then
    git clone --depth 1 https://github.com/flutter/flutter.git
  fi
  "$FLUTTER" config --enable-web
  "$FLUTTER" doctor || true
fi

"$FLUTTER" config --enable-web
"$FLUTTER" pub get

# Build must have SUPABASE_URL and SUPABASE_ANON_KEY (Vercel Environment Variables)
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "Error: SUPABASE_URL or SUPABASE_ANON_KEY is missing. Add them in Vercel -> Settings -> Environment Variables, then Redeploy."
  exit 1
fi

"$FLUTTER" build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

# SPA: serve app for any path so browser refresh on /dashboard etc. does not 404
cp build/web/index.html build/web/404.html
