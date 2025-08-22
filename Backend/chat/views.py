from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import Conversation, Message
from .serializers import ConversationSerializer, MessageSerializer
from tenant.models import Tenant
from owner.models import Owner
from immobile.models import Immobile
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import PermissionDenied

class ConversationListView(generics.ListAPIView):
    serializer_class = ConversationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        try:
            tenant = Tenant.objects.get(user=user)
            return Conversation.objects.filter(tenant=tenant)
        except Tenant.DoesNotExist:
            try:
                owner = Owner.objects.get(user=user)
                return Conversation.objects.filter(owner=owner)
            except Owner.DoesNotExist:
                return Conversation.objects.none()

class ConversationCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        tenant_id = request.data.get('tenant_id')
        owner_id = request.data.get('owner_id')
        immobile_id = request.data.get('immobile_id')

        try:
            tenant = Tenant.objects.get(id=tenant_id, user=request.user)
            owner = Owner.objects.get(id=owner_id)
            immobile = Immobile.objects.get(id_immobile=immobile_id)
        except (Tenant.DoesNotExist, Owner.DoesNotExist, Immobile.DoesNotExist):
            return Response({"error": "Invalid tenant, owner, or immobile."}, status=status.HTTP_400_BAD_REQUEST)

        conversation, created = Conversation.objects.get_or_create(
            tenant=tenant, owner=owner, immobile=immobile
        )
        return Response(ConversationSerializer(conversation).data, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)

class MessageCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        conversation_id = request.data.get('conversation_id')
        content = request.data.get('content')

        if not conversation_id or not content:
            return Response({"error": "Conversation ID and content are required."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            conversation = Conversation.objects.get(id=conversation_id)
            if request.user not in [conversation.tenant.user, conversation.owner.user]:
                return Response({"error": "You are not part of thisigh conversation."}, status=status.HTTP_403_FORBIDDEN)
        except Conversation.DoesNotExist:
            return Response({"error": "Conversation not found."}, status=status.HTTP_404_NOT_FOUND)

        message = Message.objects.create(
            conversation=conversation,
            sender=request.user,
            content=content
        )
        return Response(MessageSerializer(message).data, status=status.HTTP_201_CREATED)

class MessageMarkReadView(generics.UpdateAPIView):
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated]
    queryset = Message.objects.all()

    def perform_update(self, serializer):
        if self.request.user not in [serializer.instance.conversation.tenant.user, serializer.instance.conversation.owner.user]:
            raise PermissionDenied("You are not part of this conversation.")
        serializer.instance.is_read = True
        serializer.save()