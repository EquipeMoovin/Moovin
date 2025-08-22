COMPOSE ?= docker compose
FILE ?= docker-compose.dev.yml

# ===== Fluxos completos =====

# Sobe ambiente dev normal (build + up com logs)
dev:
	$(COMPOSE) -f $(FILE) up --build

# Dev "FRESH": zera banco (volumes), apaga migrations, sobe e recria tudo
dev-fresh: stop reset-db clean-migrations dev

# ===== Tarefas auxiliares =====

stop:
	$(COMPOSE) -f $(FILE) down

reset-db:
	$(COMPOSE) -f $(FILE) down -v

clean-migrations:
	./tools/clean_migrations.sh

logs:
	$(COMPOSE) -f $(FILE) logs -f backend

shell:
	$(COMPOSE) -f $(FILE) exec backend sh

migrate:
	$(COMPOSE) -f $(FILE) exec backend python manage.py migrate --noinput

makemigrations:
	$(COMPOSE) -f $(FILE) exec backend python manage.py makemigrations

superuser:
	$(COMPOSE) -f $(FILE) exec backend python manage.py createsuperuser
