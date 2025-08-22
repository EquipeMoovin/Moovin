# create_superuser.py
from django.contrib.auth import get_user_model
from django.core.management import BaseCommand
import os
class Command(BaseCommand):
    help = "Cria um superusuário automaticamente se ele ainda não existir."

    def handle(self, *args, **kwargs):
        User = get_user_model()
      
        username = os.environ.get("DJANGO_SU_NAME", "admin")
        email = os.environ.get("DJANGO_SU_EMAIL", "admin@example.com")
        password = os.environ.get("DJANGO_SU_PASSWORD", "admin1234")

        if not User.objects.filter(username=username).exists():
            User.objects.create_superuser(username=username, email=email, password=password)
            self.stdout.write(self.style.SUCCESS(f"Superusuário '{username}' criado com sucesso!"))
        else:
            self.stdout.write(f"Superusuário '{username}' já existe.")
