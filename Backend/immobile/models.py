from django.db import models
from django.utils import timezone
from .consts import *

from django.contrib.contenttypes.models import ContentType
from review.models import Review, ReviewType
from users.models import User
from tenant.models import Tenant

class Immobile(models.Model):
    owner = models.ForeignKey('owner.Owner', related_name='properties', on_delete=models.CASCADE, null=True,blank=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE,null=True)
    id_immobile = models.AutoField(primary_key=True)
    property_type = models.CharField(max_length=20, choices=PROPERTY_TYPE_CHOICES,default='House')
    zip_code = models.CharField(max_length=9)
    state = models.CharField(max_length=50)
    city = models.CharField(max_length=50)
    street = models.CharField(max_length=100)
    number = models.CharField(max_length=10, blank=True)
    no_number = models.BooleanField(default=False)

    bedrooms = models.IntegerField()
    bathrooms = models.IntegerField()
    area = models.DecimalField(max_digits=6, decimal_places=2)
    rent = models.DecimalField(max_digits=10, decimal_places=2)

    air_conditioning = models.BooleanField(default=False)
    garage = models.BooleanField(default=False)
    pool = models.BooleanField(default=False)
    furnished = models.BooleanField(default=False)
    pet_friendly = models.BooleanField(default=False)
    nearby_market = models.BooleanField(default=False)
    nearby_bus = models.BooleanField(default=False)
    internet = models.BooleanField(default=False)

    description = models.TextField()
    additional_rules = models.TextField(blank=True)

    status = models.CharField(max_length=15, choices=STATUS_CHOICES, default='Available')
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.property_type} in {self.city} - {self.street}, {self.number or 'No number'}"

    def get_reviews(self):
        content_type = ContentType.objects.get_for_model(self)
        return Review.objects.filter(content_type=content_type, object_id=self.id, type=ReviewType.PROPERTY)

    def average_rating(self):
        return Review.average_for_object(self)
class ImmobilePhoto(models.Model):
    immobile = models.ForeignKey(Immobile, related_name='photos_blob', on_delete=models.CASCADE)
    image_blob = models.BinaryField(default=bytes)
    content_type = models.CharField(max_length=50, default='')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Photo (BLOB) for {self.immobile}"


class Payment(models.Model):
    immobile = models.ForeignKey(Immobile, related_name='payments', on_delete=models.CASCADE)
    amount_received = models.DecimalField(max_digits=10, decimal_places=2)
    date_received = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Payment of {self.amount_received} for {self.immobile} on {self.date_received}"
