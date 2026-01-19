#!/bin/bash
set -e

if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable
fi

export PATH="$PATH:`pwd`/flutter/bin"

flutter pub get

echo "--- COMPILANDO SGT ---"
flutter build web --release --no-source-maps \
  --dart-define="API_KEY=$API_KEY" \
  --dart-define="AUTH_DOMAIN=$AUTH_DOMAIN" \
  --dart-define="PROJECT_ID=$PROJECT_ID" \
  --dart-define="STORAGE_BUCKET=$STORAGE_BUCKET" \
  --dart-define="MESSAGING_SENDER_ID=$MESSAGING_SENDER_ID" \
  --dart-define="APP_ID=$APP_ID"

echo "--- BUILD CONCLUÍDO ---"