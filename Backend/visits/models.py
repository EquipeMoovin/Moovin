
from django.db import models
from django.conf import settings
from immobile.models import Immobile

class Visit(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pendente'),
        ('confirmed', 'Confirmada'),
        ('cancelled', 'Cancelada'),
    ]

    immobile = models.ForeignKey(Immobile, on_delete=models.CASCADE, related_name='visits')
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='owner_visits')
    date = models.DateField()
    time = models.TimeField()
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    name = models.CharField(max_length=200, null=False)

    class Meta:
        unique_together = ('immobile', 'date', 'time')

    def __str__(self):
        return f"{self.immobile} - {self.date} {self.time} - {self.status}"

