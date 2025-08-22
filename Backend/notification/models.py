from django.db import models
from django.utils import timezone
from users.models import User

class Notification(models.Model):
    TYPE_CHOICES = [
        ('RENTED_CONFIRMATION', 'Confirmação de Aluguel'),
        ('PAYMENT_RECEIVED', 'Pagamento Recebido'),
        ('REVIEW_RECEIVED', 'Avaliação Recebida'),
        ('GENERAL', 'Geral'),
    ]

    user = models.ForeignKey(User, related_name='notifications', on_delete=models.CASCADE)
    title = models.CharField(max_length=100)
    message = models.TextField()
    type = models.CharField(max_length=20, choices=TYPE_CHOICES, default='GENERAL')
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(default=timezone.now)
    related_object_id = models.PositiveIntegerField(null=True, blank=True)  # ID do objeto relacionado (e.g., Rental, Payment)
    related_object_type = models.CharField(max_length=50, null=True, blank=True) 

    def __str__(self):
        return f"{self.title} - {self.user.email} ({self.created_at})"

    class Meta:
        ordering = ['-created_at']