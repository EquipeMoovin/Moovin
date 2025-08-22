from django.db import models
from django.utils import timezone
from users.models import User
from immobile.models import Immobile
from notification.models import Notification

class Conversation(models.Model):
    tenant = models.ForeignKey('tenant.Tenant', on_delete=models.CASCADE, related_name='conversations')
    owner = models.ForeignKey('owner.Owner', on_delete=models.CASCADE, related_name='conversations')
    immobile = models.ForeignKey('immobile.Immobile', on_delete=models.CASCADE, related_name='conversations')
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('tenant', 'owner', 'immobile')
        ordering = ['-updated_at']

    def __str__(self):
        return f"Conversation between {self.tenant.name} and {self.owner.name} about {self.immobile}"

class Message(models.Model):
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='sent_messages')
    content = models.TextField()
    sent_at = models.DateTimeField(default=timezone.now)
    is_read = models.BooleanField(default=False)

    class Meta:
        ordering = ['sent_at']

    def __str__(self):
        return f"Message from {self.sender.email} in {self.conversation}"

    def save(self, *args, **kwargs):
        is_new_message = self.pk is None
        super().save(*args, **kwargs)
        if is_new_message and self.conversation.messages.count() == 1:
            recipient = self.conversation.owner.user if self.sender == self.conversation.tenant.user else self.conversation.tenant.user
            Notification.objects.create(
                user=recipient,
                title=f"Nova mensagem sobre {self.conversation.immobile}",
                message=f"{self.sender.name} iniciou uma conversa sobre {self.conversation.immobile}.",
                type='GENERAL',
                related_object_id=self.conversation.id,
                related_object_type='Conversation'
            )