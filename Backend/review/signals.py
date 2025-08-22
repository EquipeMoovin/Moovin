from django.db.models.signals import post_save
from django.dispatch import receiver
from django.core.mail import send_mail
from django.conf import settings
from .models import Review
from notification.models import Notification
from django.contrib.contenttypes.models import ContentType
from immobile.models import Immobile 
from users.models import User
from tenant.models import Tenant
from owner.models import Owner

@receiver(post_save, sender=Review)
def create_review_notification(sender, instance, created, **kwargs):
    if created:
        review_type = instance.type
        target_id = instance.object_id
        content_type = instance.content_type

        # Determinar o destinatário e a mensagem com base no tipo de avaliação
        if review_type == 'PROPERTY':
            try:
                immobile = Immobile.objects.get(id_immobile=target_id)
                recipient = immobile.owner.user 
                message = f"Seu imóvel '{immobile}' recebeu uma nova avaliação com nota {instance.rating}."
                email_subject = "Nova Avaliação do Seu Imóvel"
                email_message = (
                    f"Olá, {recipient.username},\n\n"
                    f"Seu imóvel '{immobile}' recebeu uma nova avaliação com nota {instance.rating}.\n"
                    f"Comentário: {instance.comment or 'Nenhum comentário fornecido.'}\n\n"
                    f"Atenciosamente, Moovin\nEquipe Imobiliária"
                )
            except Immobile.DoesNotExist:
                return 
        elif review_type == 'TENANT':
            # Buscar o inquilino
            try:
                tenant = Tenant.objects.get(id=target_id)
                recipient = tenant.user
                message = f"Você recebeu uma nova avaliação como inquilino com nota {instance.rating}."
                email_subject = "Nova Avaliação como Inquilino"
                email_message = (
                    f"Olá, {recipient.username},\n\n"
                    f"Você recebeu uma nova avaliação com nota {instance.rating}.\n"
                    f"Comentário: {instance.comment or 'Nenhum comentário fornecido.'}\n\n"
                    f"Atenciosamente, Moovin\nEquipe Imobiliária"
                )
            except Tenant.DoesNotExist:
                return  
        elif review_type == 'OWNER':
            # Buscar o proprietário
            try:
                owner = Owner.objects.get(id=target_id)
                recipient = owner.user
                message = f"Você recebeu uma nova avaliação como proprietário com nota {instance.rating}."
                email_subject = "Nova Avaliação como Proprietário"
                email_message = (
                    f"Olá, {recipient.username},\n\n"
                    f"Você recebeu uma nova avaliação com nota {instance.rating}.\n"
                    f"Comentário: {instance.comment or 'Nenhum comentário fornecido.'}\n\n"
                    f"Atenciosamente, Moovin\nEquipe Imobiliária"
                )
            except Owner.DoesNotExist:
                return  
        else:
            return 

        Notification.objects.create(
            user=recipient,
            title="Avaliação Recebida",
            message=message,
            type="REVIEW_RECEIVED",
            related_object_id=instance.id,
            related_object_type="Review"
        )

        # Enviar e-mail para o destinatário
        send_mail(
            subject=email_subject,
            message=email_message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[recipient.email],
            fail_silently=False,
        )