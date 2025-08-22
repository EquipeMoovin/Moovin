from rest_framework.permissions import BasePermission
from django.utils import timezone
from .models import Subscription

class HasActiveSubscription(BasePermission):
    """
    Permissão para garantir que o usuário tenha uma assinatura ativa.
    Usa cache em request para evitar múltiplas consultas no mesmo ciclo de requisição.
    """

    def has_permission(self, request, view):
        user = request.user

        if not user.is_authenticated:
            return False

       
        if hasattr(request, "_cached_has_active_subscription"):
            return request._cached_has_active_subscription

        # now = timezone.now()

        # Usa exists() para verificar validade sem carregar objeto inteiro
        has_subscription = Subscription.objects.filter(
            user=user,
            active=True
        ).exists()

        request._cached_has_active_subscription = has_subscription
        return has_subscription
