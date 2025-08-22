
from django.urls import reverse
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.viewsets import ModelViewSet
from .models import *
from .serializers import TenantSerializer
from django.contrib.auth.models import User
from rest_framework.permissions import AllowAny
from rest_framework import generics
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from django.http import HttpResponse
from rest_framework.parsers import MultiPartParser, FormParser

class TenantViewSet(ModelViewSet):
    queryset = Tenant.objects.all()
    serializer_class = TenantSerializer
    permission_classes=[IsAuthenticated]

    @action(detail=True, methods=['patch'], url_path='update-profile')
    def update_profile(self, request, pk=None):
        tenant = self.get_object()
        serializer = self.get_serializer(tenant, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['get'], url_path='profile/me')
    def me(self,request):
        try:
            profile = Tenant.objects.get(user=request.user)
        except Tenant.DoesNotExist:
            return Response({"detail": "Perfil não encontrado."}, status=status.HTTP_404_NOT_FOUND)

        serializer = self.get_serializer(profile)
        return Response(serializer.data)
    
    @action(detail=False, methods=['patch'], url_path='me/update-profile')
    def update_me_profile(self, request):
        try:
            tenant = Tenant.objects.get(user=request.user)
        except Tenant.DoesNotExist:
            return Response({"detail": "Perfil não encontrado."}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = self.get_serializer(tenant, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class TenantCreateView(generics.CreateAPIView):
    queryset = Tenant.objects.all()
    serializer_class = TenantSerializer
    permission_classes = [AllowAny]

    def create(self, request, *args, **kwargs):
        print("REQUISIÇÃO RECEBIDA:", request.data)
        return super().create(request, *args, **kwargs)
class ServeImageBlobAPIView(APIView):
    """
    Retorna o conteúdo binário da foto.
    """
    def get(self, request, photo_id, format=None):
        try:
            photo = TenantPhoto.objects.get(id=photo_id)
            return HttpResponse(photo.image_blob, content_type=photo.content_type)
        except TenantPhoto.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)


    def serve_image_blob(request, photo_id):
        photo = get_object_or_404(TenantPhoto, id=photo_id)
        print("SERVE IMAGE BLOB:")
        print("  Photo ID:", photo.id)
        print("  Content Type:", photo.content_type)
        print("  First 20 bytes of blob:", photo.image_blob[:20] if photo.image_blob else None)
        return HttpResponse(photo.image_blob, content_type=photo.content_type)
class TenantPhotoListAPIView(APIView):
    def get(self, request, tenant_id):
        try:
            tenant = Tenant.objects.get(id=tenant_id)
        except Tenant.DoesNotExist:
            return Response({'error': 'Owner not found'}, status=status.HTTP_404_NOT_FOUND)

        photos = TenantPhoto.objects.filter(tenant=tenant)
        data = []

        for photo in photos:
            photo_url = request.build_absolute_uri(
                reverse('serve-owner-photo', args=[photo.id])
            )
            data.append({
                'photo_id': photo.id,
                'uploaded_at': photo.uploaded_at,
                'url': photo_url,
            })

        return Response(data, status=status.HTTP_200_OK)
class TenantPhotoUploadAPIView(APIView):
    parser_classes = (MultiPartParser, FormParser)

    def post(self, request, format=None):
        print("\n--- DEBUG: TenantPhotoUploadAPIView POST request received ---")
        print(f"Request method: {request.method}") # Deve ser POST

        # Tenta obter o arquivo e o ID do inquilino
        uploaded_file = request.FILES.get('photos') # Nome do campo do arquivo no Flutter
        tenant_id = request.data.get('tenant_id')

        print(f"DEBUG: 'photos' (uploaded_file): {uploaded_file.name if uploaded_file else 'None'} (Type: {type(uploaded_file)})")
        print(f"DEBUG: 'tenant_id': {tenant_id} (Type: {type(tenant_id)})")

        # Mostra o conteúdo completo de request.FILES e request.data
        print(f"DEBUG: Full request.FILES content: {request.FILES}")
        print(f"DEBUG: Full request.data content: {request.data}")

        if not uploaded_file or not tenant_id:
            print(f"DEBUG: BAD REQUEST - Missing photo or tenant_id. uploaded_file: {uploaded_file}, tenant_id: {tenant_id}")
            return Response({'error': 'Missing photo or tenant_id'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Tenta encontrar o objeto Tenant
            tenant = Tenant.objects.get(id=tenant_id)
            print(f"DEBUG: Tenant found: {tenant} (ID: {tenant.id})")
        except Tenant.DoesNotExist:
            # ATENÇÃO: A mensagem de erro aqui está 'Owner not found'.
            # Mudei para 'Tenant not found' para refletir a lógica.
            print(f"DEBUG: NOT FOUND - Tenant with ID {tenant_id} not found.")
            return Response({'error': 'Tenant not found'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            # Captura outras exceções ao buscar o tenant
            print(f"DEBUG: SERVER ERROR - Error trying to get Tenant: {e}")
            return Response({'error': f'Server error trying to find tenant: {e}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        try:
            # Cria o objeto TenantPhoto e salva o BLOB
            photo = TenantPhoto.objects.create(
                tenant=tenant,
                image_blob=uploaded_file.read(),
                content_type=uploaded_file.content_type
            )
            print(f"DEBUG: TenantPhoto created successfully with ID: {photo.id}")
            return Response({'message': 'Photo uploaded successfully', 'photo_id': photo.id}, status=status.HTTP_201_CREATED)
        except Exception as e:
            # Captura exceções durante a criação do TenantPhoto
            print(f"DEBUG: SERVER ERROR - Error creating TenantPhoto object: {e}")
            return Response({'error': f'Error saving photo: {e}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)