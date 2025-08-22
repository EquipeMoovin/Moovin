from django.contrib import admin
from rest_framework.permissions import IsAdminUser
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User,EmailVerificationCode
from users .serializers import UserSerializer
from rest_framework.response import Response
from rest_framework.views import APIView
@admin.register(User)
class UserAdmin(BaseUserAdmin):
    ordering = ['email']
    list_display = ['email', 'username', 'name', 'user_type', 'is_staff']
    
    fieldsets = (
        (None, {'fields': ('email', 'username', 'password')}),
        ('Informações pessoais', {'fields': ('name', 'user_type')}),
        ('Permissões', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Datas importantes', {'fields': ('last_login',)}),
    )
    
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'username', 'name', 'user_type', 'password1', 'password2', 'is_staff', 'is_active')}
        ),
    )
    
    search_fields = ('email', 'username', 'name')



# Essa classe serve para controlar a permissao de todos os usuarios. apenas admins conseguem acessar os dados de todos os usuarios.
class UserListView(APIView):
    permission_classes = [IsAdminUser]

    def get(self, request):
        users = User.objects.all()
        serializer = UserSerializer(users, many=True)
        return Response(serializer.data)
    
@admin.register(EmailVerificationCode)
class EmailVerificationCodeAdmin(admin.ModelAdmin):
    list_display = ['email', 'code', 'created_at']
    search_fields = ['email', 'code']
    readonly_fields = ['created_at']