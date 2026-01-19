#!/bin/bash

# Este script executa o build do Flutter Web para o projeto SGT
# Ele contorna o limite de caracteres da Vercel injetando as variáveis do Firebase

echo "Iniciando o Build do Sistema de Gestão de Terrenos (SGT)..."

flutter/bin/flutter build web --release \
  --dart-define=API_KEY=$FIREBASE_API_KEY \
  --dart-define=AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN \
  --dart-define=PROJECT_ID=$FIREBASE_PROJECT_ID \
  --dart-define=STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET \
  --dart-define=MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID \
  --dart-define=APP_ID=$FIREBASE_APP_ID

echo "Build concluído com sucesso!"