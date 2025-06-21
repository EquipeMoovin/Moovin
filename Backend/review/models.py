from django.db import models
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
from django.contrib.auth import get_user_model

User = get_user_model()

class ReviewType(models.TextChoices):
    TENANT = 'TENANT', 'Tenant'
    LANDLORD = 'OWNER', 'Owner'
    PROPERTY = 'PROPERTY', 'Immobile'

class Review(models.Model):
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    rating = models.PositiveSmallIntegerField()
    comment = models.TextField(blank=True)
    type = models.CharField(max_length=20, choices=ReviewType.choices)
    created_at = models.DateTimeField(auto_now_add=True)
    content_type = models.ForeignKey(ContentType, on_delete=models.CASCADE)
    object_id = models.PositiveIntegerField()
    target_object = GenericForeignKey('content_type', 'object_id')
    
    @property
    def author_username(self):
        return self.author.username
    

    class Meta:
        ordering = ['-created_at']
        unique_together = ('author', 'content_type', 'object_id')

    def __str__(self):
        return f'Review by {self.author} on {self.type} #{self.object_id}'

    @classmethod
    def average_for_object(cls, obj):
        content_type = ContentType.objects.get_for_model(obj)
        reviews = cls.objects.filter(content_type=content_type, object_id=obj.id)
        return reviews.aggregate(models.Avg('rating'))['rating__avg']
