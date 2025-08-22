from django.core.management.base import BaseCommand
from ...models import Subscription
from django.utils import timezone

class Command(BaseCommand):
    help = 'Desativa assinaturas vencidas'

    def handle(self, *args, **kwargs):
        hoje = timezone.now().date()
        vencidas = Subscription.objects.filter(active=True, end_date__lt=hoje)

        for sub in vencidas:
            sub.active = False
            sub.save()
            self.stdout.write(f"Assinatura de {sub.user.email} desativada.")


# Configurar cronjob no servidor hospedado. Render, por exemplo.
# 2. No painel do Render, vá em:
# Dashboard > Cron Jobs > New Cron Job

# 3. Configure o cron job
# Name: check_subscriptions

# Schedule: Ex: 0 3 * * * (todos os dias às 3h da manhã)

# Command: python manage.py verificar_assinaturas
# Environment: escolha o mesmo ambiente do seu Django app

# Service: selecione o seu serviço web Django principal

# Dicas importantes
# Certifique-se de que todas as variáveis de ambiente (ex: DJANGO_SETTINGS_MODULE, DATABASE_URL) estão disponíveis nesse ambiente.

# O cron job compartilha o mesmo container do seu app, então não precisa instalar nada extra.

# Você pode ver os logs das execuções direto no painel do Render.

