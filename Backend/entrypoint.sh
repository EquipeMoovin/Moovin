#!/bin/sh
set -e

echo ">> Esperando Postgres em $DB_HOST:$DB_PORT..."
until nc -z "$DB_HOST" "$DB_PORT"; do
  sleep 1
done
echo ">> Banco de dados pronto!"

# Em dev local, opcionalmente criamos as migrations automaticamente
if [ "${AUTO_MAKEMIGRATIONS}" = "1" ]; then
  echo ">> AUTO_MAKEMIGRATIONS=1 -> gerando migrations..."
  python manage.py makemigrations
else
  # fallback: se não existir nenhuma migration além do __init__.py, criamos
  if ! find . -path "*/migrations/*.py" -not -name "__init__.py" | grep -q . ; then
    echo ">> Nenhuma migration encontrada -> gerando migrations..."
    python manage.py makemigrations
  fi
fi

echo ">> Aplicando migrações..."
python manage.py migrate --noinput

if [ "$COLLECT_STATIC" = "1" ]; then
  echo ">> Coletando estáticos..."
  python manage.py collectstatic --noinput
fi

if [ "$CREATE_SUPERUSER" = "1" ]; then
  echo ">> Garantindo superuser padrão..."
  python - <<'PY'
import os
import django
os.environ.setdefault("DJANGO_SETTINGS_MODULE", os.getenv("DJANGO_SETTINGS_MODULE","backend.settings"))
django.setup()
from django.contrib.auth import get_user_model
U = get_user_model()
u = U.objects.filter(username=os.getenv("DJANGO_SUPERUSER_USERNAME","admin")).first()
if not u:
    U.objects.create_superuser(
        username=os.getenv("DJANGO_SUPERUSER_USERNAME","admin"),
        email=os.getenv("DJANGO_SUPERUSER_EMAIL","admin@moovin.local"),
        password=os.getenv("DJANGO_SUPERUSER_PASSWORD","admin123"),
    )
    print("Superuser criado.")
else:
    print("Superuser já existe.")
PY
fi

echo ">> Iniciando servidor Django (dev)"
exec python manage.py runserver 0.0.0.0:8000
