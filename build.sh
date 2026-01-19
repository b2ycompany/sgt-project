#!/bin/bash

# Interrompe o script se houver qualquer erro
set -e

# 1. Instalação do SDK do Flutter
FLUTTER_VERSION="stable"
if [ ! -d "flutter" ]; then
  echo "--- Baixando SDK do Flutter ---"
  git clone https://github.com/flutter/flutter.git -b $FLUTTER_VERSION
fi

export PATH="$PATH:`pwd`/flutter/bin"

# 2. Preparação do ambiente
echo "--- Instalando dependências ---"
flutter doctor
flutter precache --web
flutter pub get

# 3. Compilação para Web (Injetando chaves da Vercel)
echo "--- Compilando Plataforma SGT ---"
# O uso de --no-source-maps reduz o tamanho e evita erros de memória no build
flutter build web --release --no-source-maps \
  --dart-define=API_KEY=$API_KEY \
  --dart-define=AUTH_DOMAIN=$AUTH_DOMAIN \
  --dart-define=PROJECT_ID=$PROJECT_ID \
  --dart-define=STORAGE_BUCKET=$STORAGE_BUCKET \
  --dart-define=MESSAGING_SENDER_ID=$MESSAGING_SENDER_ID \
  --dart-define=APP_ID=$APP_ID

# 4. Verificação final
echo "--- Conteúdo gerado com sucesso em build/web ---"
ls -la build/web

echo "--- Processo Concluído ---"