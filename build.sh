#!/bin/bash

# 1. Definir a versão do Flutter a ser utilizada
FLUTTER_VERSION="stable"

# 2. Verificar se o SDK do Flutter já existe para evitar downloads desnecessários
if [ ! -d "flutter" ]; then
  echo "--- Baixando o SDK do Flutter ($FLUTTER_VERSION) ---"
  git clone https://github.com/flutter/flutter.git -b $FLUTTER_VERSION
fi

# 3. Adicionar o Flutter ao PATH temporário da sessão de build
export PATH="$PATH:`pwd`/flutter/bin"

# 4. Pré-download de artefatos para a Web
echo "--- Preparando artefatos para Web ---"
flutter doctor
flutter precache --web

# 5. Executar o Build do SGT injetando as variáveis do Firebase (Tecnologia de Ponta)
echo "--- Iniciando Compilação do Sistema SGT (CIG Investimento) ---"
flutter build web --release \
  --dart-define=API_KEY=$FIREBASE_API_KEY \
  --dart-define=AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN \
  --dart-define=PROJECT_ID=$FIREBASE_PROJECT_ID \
  --dart-define=STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET \
  --dart-define=MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID \
  --dart-define=APP_ID=$FIREBASE_APP_ID

echo "--- Build concluído com sucesso! ---"