# from django.db import models
# from django.contrib.auth.models import User
# from immobile.models import Immobile
# from django.conf import settings
# from django.contrib.contenttypes.models import ContentType
# from review.models import Review, ReviewType


# class Owner(models.Model):
#     user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE,related_name='owner_profile')
#     name = models.CharField(max_length=100)
#     phone = models.CharField(max_length=20,null=True)
#     city = models.CharField(max_length=100,null=True)
#     state = models.CharField(max_length=100,null=True)
#     about_me = models.TextField(null=True)

#     revenue_generated = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
#     rented_properties = models.PositiveIntegerField(default=0)
#     rated_by_tenants = models.PositiveIntegerField(default=0)
#     recommended_by_tenants = models.PositiveIntegerField(default=0)
#     fast_responder = models.BooleanField(default=False)

#     def __str__(self):
#         return self.name

#     @property
#     def total_properties(self):
#         return self.immobile_set.count()

#     @property
#     def active_properties(self):
#         return self.immobile_set.filter(status='Available').count()

#     @property
#     def properties(self):
#         return self.immobile_set.all().order_by('-created_at')

#     def get_reviews(self):
#         content_type = ContentType.objects.get_for_model(self)
#         return Review.objects.filter(content_type=content_type, object_id=self.id, type=ReviewType.PROPERTY)

#     def average_rating(self):
#         return Review.average_for_object(self)

from django.db import models
from django.conf import settings
from django.contrib.contenttypes.models import ContentType
from review.models import Review, ReviewType

class Owner(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='owner_profile')
    name = models.CharField(max_length=100)
    phone = models.CharField(max_length=20, null=True)
    city = models.CharField(max_length=100, null=True)
    state = models.CharField(max_length=100, null=True)
    about_me = models.TextField(null=True)

    revenue_generated = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    rented_properties = models.PositiveIntegerField(default=0)
    rated_by_tenants = models.PositiveIntegerField(default=0)
    recommended_by_tenants = models.PositiveIntegerField(default=0)
    fast_responder = models.BooleanField(default=False)
    def __str__(self):
        return self.name
    def get_reviews(self):
        content_type = ContentType.objects.get_for_model(self)
        return Review.objects.filter(content_type=content_type, object_id=self.id, type=ReviewType.PROPERTY)
    def average_rating(self):
        return Review.average_for_object(self)
    
class OwnerPhoto(models.Model):
    owner = models.ForeignKey(Owner, related_name='photos_blob', on_delete=models.CASCADE)
    image_blob = models.BinaryField(default=bytes)
    content_type = models.CharField(max_length=50, default='')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Photo (BLOB) for {self.owner}"
