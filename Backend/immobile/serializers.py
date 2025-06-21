# serializers.py (na sua app 'immobile')
from rest_framework import serializers
from .models import Immobile, ImmobilePhoto
from django.urls import reverse,reverse_lazy


# serializers.py (na sua app 'immobile')
from rest_framework import serializers
from django.utils import timezone
from .models import Immobile, ImmobilePhoto

class ImmobilePhotoSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = ImmobilePhoto
        fields = ['id', 'image_url','image_blob', 'content_type', 'uploaded_at']

    def get_image_url(self, obj):
        
        request = self.context.get('request')
        if request:
            return request.build_absolute_uri(reverse('serve_image_blob_api', kwargs={'photo_id': obj.id}))
        return None

class ImmobileSerializer(serializers.ModelSerializer):
    photosBlob = ImmobilePhotoSerializer(many=True, read_only=True,source='photos_blob')

    class Meta:
        model = Immobile
        fields = [
            'owner',
            'id_immobile',
            'property_type',
            'zip_code',
            'state',
            'city',
            'street',
            'number',
            'no_number',
            'bedrooms',
            'bathrooms',
            'area',
            'rent',
            'air_conditioning',
            'garage',
            'pool',
            'furnished',
            'pet_friendly',
            'nearby_market',
            'nearby_bus',
            'internet',
            'description',
            'additional_rules',
            'status',
            'created_at',
            'photosBlob',
        ]