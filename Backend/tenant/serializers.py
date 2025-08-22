from rest_framework import serializers
from .models import *
from django.urls import reverse



class TenantPhotoSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = TenantPhoto
        fields = ['id', 'image_url','image_blob', 'content_type', 'uploaded_at']

    def get_image_url(self, obj):
        
        request = self.context.get('request')
        if request:
            return request.build_absolute_uri(reverse('serve_image_blob_api', kwargs={'photo_id': obj.id}))
        return None

class TenantSerializer(serializers.ModelSerializer):
    photos = TenantPhotoSerializer(many=True,read_only=True,source='photos_blob')
    
    class Meta:
        model = Tenant
        fields = [
            'id', 'user', 'name', 'age', 'job', 'city', 'state',
            'about_me', 'prefers_studio', 'prefers_apartment',
            'prefers_shared_rent', 'accepts_pets', 'user_rating',
            'properties_rented', 'rated_by_landlords', 'recommended_by_landlords',
            'favorited_properties', 'fast_responder', 'member_since','photos'
        ]

