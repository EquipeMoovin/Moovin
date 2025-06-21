# review/serializers.py
from rest_framework import serializers
from .models import Review
from django.contrib.contenttypes.models import ContentType

class ReviewSerializer(serializers.ModelSerializer):
    author_username = serializers.CharField(source='author.username', read_only=True)

    class Meta:
        model = Review
        fields = ['id', 'author', 'rating', 'comment', 'type', 'object_id', 'created_at','author_username']
        read_only_fields = ['author', 'created_at']

    def create(self, validated_data):
        type_str = validated_data.pop('type')
        object_id = validated_data['object_id']
        print(f"Tentando obter ContentType para: '{type_str}'")
        content_type_model = type_str.lower() #no ContType esta immobile mas no model da review pede PROPERTY
        if type_str == 'PROPERTY':
            content_type_model = 'immobile'
        try:
            content_type = ContentType.objects.get(model=content_type_model)
            #print(f"content-{content_type}")
        except ContentType.DoesNotExist:
            raise serializers.ValidationError({'type': 'Invalid type specified.'})

        validated_data['content_type'] = content_type
        validated_data['type'] = type_str
        print(validated_data)
        return super().create(validated_data)
