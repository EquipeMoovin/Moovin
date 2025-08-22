from django.db.models.signals import post_save
from django.dispatch import receiver
from django.core.mail import send_mail
from django.conf import settings
from rental.models import Rental
from notification.models import Notification

@receiver(post_save, sender=Rental)
def create_rental_notification(sender, instance, created, **kwargs):
    if created:
        # Notificar o proprietário do imóvel
        owner = instance.immobile.owner.user
        Notification.objects.create(
            user=owner,
            title="Imóvel Alugado com Sucesso",
            message=f"O inquilino {instance.tenant.name} alugou o imóvel {instance.immobile}.",
            type="RENTED_CONFIRMATION",
            related_object_id=instance.id,
            related_object_type="Rental"
        )

        # Enviar e-mail para o proprietário
        owner_subject = "Seu imóvel foi alugado!"
        owner_message = (
            f"Olá, {owner.username},\n\n"
            f"O inquilino {instance.tenant.name} alugou seu imóvel '{instance.immobile}' com sucesso.\n"
            f"Entre em contato com o inquilino para os próximos passos.\n\n"
            f"Atenciosamente, Moovin\nEquipe Imobiliária"
        )
        send_mail(
            subject=owner_subject,
            message=owner_message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[owner.email],
            fail_silently=False,
        )

        # Notificar o inquilino
        tenant = instance.tenant.user
        Notification.objects.create(
            user=tenant,
            title="Aluguel Confirmado com Sucesso",
            message=f"Você alugou o imóvel {instance.immobile} com sucesso! Entre em contato com o proprietário para os próximos passos.",
            type="RENTED_CONFIRMATION",
            related_object_id=instance.id,
            related_object_type="Rental"
        )

        # Enviar e-mail para o inquilino
        tenant_subject = "Confirmação de Aluguel"
        tenant_message = (
            f"Olá, {tenant.username},\n\n"
            f"Você alugou o imóvel '{instance.immobile}' com sucesso!\n"
            f"Entre em contato com o proprietário para os próximos passos.\n\n"
            f"Atenciosamente, Moovin\nEquipe Imobiliária"
        )
        send_mail(
            subject=tenant_subject,
            message=tenant_message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[tenant.email],
            fail_silently=False,
        )