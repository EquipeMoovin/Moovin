from rest_framework import serializers
from .models import Notification

class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = [
            'id', 'title', 'message', 'type', 'is_read',
            'created_at', 'related_object_id', 'related_object_type'
        ]