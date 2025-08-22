
from rest_framework import serializers
from .models import *
from immobile.serializers import ImmobileSerializer
from django.urls import reverse
from drf_extra_fields.fields import Base64FileField
from django.contrib.auth import get_user_model

User = get_user_model()

class OwnerPhotoSerializer(serializers.ModelSerializer):
    image_blob = Base64FileField(write_only=True)
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = OwnerPhoto
        fields = ['id', 'image_url', 'image_blob', 'content_type', 'uploaded_at']

    def get_image_url(self, obj):
        request = self.context.get('request')
        if request:
            return request.build_absolute_uri(
                reverse('serve_image_blob_api', kwargs={'photo_id': obj.id})
            )
        return None
    
class OwnerSerializer(serializers.ModelSerializer):
    user = serializers.PrimaryKeyRelatedField(queryset=User.objects.all())  
    properties = ImmobileSerializer(many=True, read_only=True)

    photos = OwnerPhotoSerializer(many=True,read_only=True,source='photos_blob',allow_null=True)

    class Meta:
        model = Owner
        fields = [
            'id', 'user', 'name', 'phone', 'city', 'state', 'about_me',
            'revenue_generated', 'rented_properties', 'rated_by_tenants',
            'recommended_by_tenants', 'fast_responder', 'properties','photos',
        ]

        #read_only_fields = ['id', 'user']

        read_only_fields = ['id']
    def create(self, validated_data):
    
        print("DEBUG: validated_data =", validated_data)

        photos_data = validated_data.pop('photos_blob', [])
        owner = Owner.objects.create(**validated_data)

        for photo_data in photos_data:
            OwnerPhoto.objects.create(owner=owner, **photo_data)

        return owner

