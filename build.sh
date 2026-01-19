#!/bin/bash

# 1. Configuração do ambiente
FLUTTER_VERSION="stable"

# 2. Instalação do SDK do Flutter no servidor da Vercel
if [ ! -d "flutter" ]; then
  echo "--- Baixando SDK do Flutter ($FLUTTER_VERSION) ---"
  git clone https://github.com/flutter/flutter.git -b $FLUTTER_VERSION
fi

# 3. Definição do PATH para execução dos comandos
export PATH="$PATH:`pwd`/flutter/bin"

# 4. Preparação e Limpeza
echo "--- Preparando dependências do sistema SGT ---"
flutter doctor
flutter precache --web
flutter pub get

# 5. Build Final injetando as chaves de segurança (Tecnologia de Ponta)
echo "--- Iniciando Compilação Web para CIG Investimento ---"
flutter build web --release \
  --dart-define=API_KEY=$API_KEY \
  --dart-define=AUTH_DOMAIN=$AUTH_DOMAIN \
  --dart-define=PROJECT_ID=$PROJECT_ID \
  --dart-define=STORAGE_BUCKET=$STORAGE_BUCKET \
  --dart-define=MESSAGING_SENDER_ID=$MESSAGING_SENDER_ID \
  --dart-define=APP_ID=$APP_ID

# 6. Verificação do diretório de saída
echo "--- Verificando integridade da pasta build/web ---"
ls build/web

echo "--- Build do SGT Finalizado com Sucesso ---"