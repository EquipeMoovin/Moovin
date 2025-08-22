# from django.db import models
# from users.models import User
# from django.conf import settings
# from django.contrib.contenttypes.models import ContentType
# from review.models import Review, ReviewType
# class Tenant(models.Model):
#     user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE,related_name='tenant_profile')
#     name = models.CharField(max_length=100)
#     age = models.PositiveIntegerField(null=True)
#     job = models.CharField(max_length=100,null=True)
#     city = models.CharField(max_length=100,null=True)
#     state = models.CharField(max_length=100,null=True)
#     about_me = models.TextField(null=True)
    
#     # Rental preferences
#     prefers_studio = models.BooleanField(default=False)
#     prefers_apartment = models.BooleanField(default=False)
#     prefers_shared_rent = models.BooleanField(default=False)
#     accepts_pets = models.BooleanField(default=False)

#     # User rating
#     user_rating = models.FloatField(default=0.0)

#     # Platform history
#     properties_rented = models.PositiveIntegerField(default=0)
#     rated_by_landlords = models.PositiveIntegerField(default=0)
#     recommended_by_landlords = models.PositiveIntegerField(default=0)
#     favorited_properties = models.PositiveIntegerField(default=0)
#     fast_responder = models.BooleanField(default=False)
#     member_since = models.DateField(auto_now_add=True)

#     def get_reviews(self):
#         content_type = ContentType.objects.get_for_model(self)
#         return Review.objects.filter(content_type=content_type, object_id=self.id, type=ReviewType.PROPERTY)

#     def average_rating(self):
#         return Review.average_for_object(self)

#     def __str__(self):
#         return self.name

from django.db import models
from django.conf import settings
from django.contrib.contenttypes.models import ContentType
from review.models import Review, ReviewType

class Tenant(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='tenant_profile')
    name = models.CharField(max_length=100)
    age = models.PositiveIntegerField(null=True)
    job = models.CharField(max_length=100, null=True)
    city = models.CharField(max_length=100, null=True)
    state = models.CharField(max_length=100, null=True)
    about_me = models.TextField(null=True)

    prefers_studio = models.BooleanField(default=False)
    prefers_apartment = models.BooleanField(default=False)
    prefers_shared_rent = models.BooleanField(default=False)
    accepts_pets = models.BooleanField(default=False)

    user_rating = models.FloatField(default=0.0)

    properties_rented = models.PositiveIntegerField(default=0)
    rated_by_landlords = models.PositiveIntegerField(default=0)
    recommended_by_landlords = models.PositiveIntegerField(default=0)
    favorited_properties = models.PositiveIntegerField(default=0)
    fast_responder = models.BooleanField(default=False)
    member_since = models.DateField(auto_now_add=True)

    def get_reviews(self):
        content_type = ContentType.objects.get_for_model(self)
        return Review.objects.filter(content_type=content_type, object_id=self.id, type=ReviewType.PROPERTY)

    def average_rating(self):
        return Review.average_for_object(self)

    def __str__(self):
        return self.name

class TenantPhoto(models.Model):
    tenant = models.ForeignKey(Tenant, related_name='photos_blob', on_delete=models.CASCADE)
    image_blob = models.BinaryField(default=bytes)
    content_type = models.CharField(max_length=50, default='')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Photo (BLOB) for {self.tenant}"