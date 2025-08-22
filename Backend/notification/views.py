from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from .models import Notification
from .serializers import NotificationSerializer
from django.contrib.auth import get_user_model
from rest_framework.views import APIView
from tenant.models import Tenant
from owner.models import Owner
from rental.models import Rental
from django.core.mail import send_mail
from django.conf import settings

User = get_user_model()

class NotificationListView(generics.ListAPIView):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user)

class NotificationMarkReadView(generics.UpdateAPIView):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]
    queryset = Notification.objects.all()

    def perform_update(self, serializer):
        serializer.instance.is_read = True
        serializer.save()

class NotificationCreateView(generics.CreateAPIView):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class NotificationDeleteView(generics.DestroyAPIView):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user)

@api_view(['PATCH'])
@permission_classes([permissions.IsAuthenticated])
def mark_all_as_read(request):
    notifications = Notification.objects.filter(user=request.user, is_read=False)
    notifications.update(is_read=True)
    return Response({"message": "Todas as notificações foram marcadas como lidas"}, status=status.HTTP_200_OK)

class SendNotificationView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        try:
            owner = Owner.objects.get(user=request.user)
        except Owner.DoesNotExist:
            return Response(
                {"detail": "Somente proprietários podem enviar notificações."},
                status=status.HTTP_403_FORBIDDEN
            )

        title = request.data.get('title')
        message = request.data.get('message')
        email = request.data.get('email')

        if not title or not message or not email:
            return Response(
                {"detail": "Título, mensagem e e-mail são obrigatórios."},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            target_user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response(
                {"detail": "Usuário com este e-mail não encontrado."},
                status=status.HTTP_404_NOT_FOUND
            )

        Notification.objects.create(
            user=target_user,
            title=title,
            message=message,
            type='GENERAL',
        )

        # Enviar e-mail para o usuário
        if target_user.email:
            try:
                email_subject = title
                sender_name = request.user.name
                email_message = (
                    f"Olá, {target_user.username},\n\n"
                    f"Você recebeu uma nova notificação:\n\n"
                    f"{message}\n\n"
                    f"Atenciosamente,\n{sender_name}"
                )
                send_mail(
                    subject=email_subject,
                    message=email_message,
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    recipient_list=[target_user.email],
                    fail_silently=False,
                )
            except Exception as e:
                pass
        else:
            pass

        return Response(
            {"message": f"Notificação enviada para {target_user.email}."},
            status=status.HTTP_201_CREATED
        )