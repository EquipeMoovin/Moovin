from rest_framework import serializers
from .models import Conversation, Message
from users.serializers import UserSerializer
from tenant.serializers import TenantSerializer
from owner.serializers import OwnerSerializer
from immobile.serializers import ImmobileSerializer

class MessageSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True)

    class Meta:
        model = Message
        fields = ['id', 'sender', 'content', 'sent_at', 'is_read']

class ConversationSerializer(serializers.ModelSerializer):
    tenant = TenantSerializer(read_only=True)
    owner = OwnerSerializer(read_only=True)
    immobile = ImmobileSerializer(read_only=True)
    messages = MessageSerializer(many=True, read_only=True)
    last_message = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = ['id', 'tenant', 'owner', 'immobile', 'created_at', 'updated_at', 'messages', 'last_message']

    def get_last_message(self, obj):
        last_message = obj.messages.last()
        return MessageSerializer(last_message).data if last_message else None