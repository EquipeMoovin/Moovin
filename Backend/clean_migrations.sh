#!/usr/bin/env bash
set -e

# Apps Django onde vamos limpar migrations (ajuste a lista se necessário)
APPS=(
  "chat"
  "immobile"
  "notification"
  "owner"
  "rental"
  "review"
  "subscriptions"
  "tenant"
  "users"
  "visits"
)

echo ">> Limpando migrations (mantendo __init__.py)..."
for app in "${APPS[@]}"; do
  if [ -d "./$app/migrations" ]; then
    find "./$app/migrations" -type f -name "*.py" ! -name "__init__.py" -delete
    find "./$app/migrations" -type f -name "*.pyc" -delete || true
    echo " - $app/migrations limpo"
  fi
done

echo ">> OK. Migrations removidas."
