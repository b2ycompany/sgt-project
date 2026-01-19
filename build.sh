#!/bin/bash
set -e

if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable
fi

export PATH="$PATH:`pwd`/flutter/bin"

flutter pub get

echo "--- COMPILANDO SGT CIG INVESTIMENTO ---"
# Mapeia as variáveis da Vercel (FIREBASE_...) para os nomes do Dart (API_KEY)
flutter build web --release --no-source-maps \
  --dart-define=API_KEY="$FIREBASE_API_KEY" \
  --dart-define=AUTH_DOMAIN="$FIREBASE_AUTH_DOMAIN" \
  --dart-define=PROJECT_ID="$FIREBASE_PROJECT_ID" \
  --dart-define=STORAGE_BUCKET="$FIREBASE_STORAGE_BUCKET" \
  --dart-define=MESSAGING_SENDER_ID="$FIREBASE_MESSAGING_SENDER_ID" \
  --dart-define=APP_ID="$FIREBASE_APP_ID"

echo "--- BUILD CONCLUÍDO ---"