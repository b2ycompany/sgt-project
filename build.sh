#!/bin/bash

# Interrompe se houver erro
set -e

# 1. Instalação do SDK
if [ ! -d "flutter" ]; then
  echo "--- Baixando Flutter SDK ---"
  git clone https://github.com/flutter/flutter.git -b stable
fi

export PATH="$PATH:`pwd`/flutter/bin"

# 2. Configuração
echo "--- Instalando Dependências ---"
flutter pub get

# 3. Compilação Web (Injetando chaves SGT)
echo "--- Compilando SGT para Web ---"
flutter build web --release --no-source-maps \
  --dart-define=API_KEY=$API_KEY \
  --dart-define=AUTH_DOMAIN=$AUTH_DOMAIN \
  --dart-define=PROJECT_ID=$PROJECT_ID \
  --dart-define=STORAGE_BUCKET=$STORAGE_BUCKET \
  --dart-define=MESSAGING_SENDER_ID=$MESSAGING_SENDER_ID \
  --dart-define=APP_ID=$APP_ID

# 4. Verificação final dos arquivos gerados
echo "--- Conteúdo do build: ---"
ls -la build/web

echo "--- Processo Finalizado com Sucesso ---"