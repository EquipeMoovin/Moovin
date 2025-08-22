from django.contrib import admin
from .models import Tenant

@admin.register(Tenant)
class TenantAdmin(admin.ModelAdmin):
    list_display = ('name', 'age', 'city', 'state', 'user_rating', 'properties_rented')
    search_fields = ('name', 'city', 'state')
    list_filter = ('prefers_studio', 'prefers_apartment', 'prefers_shared_rent', 'accepts_pets')

from .models import  TenantPhoto
@admin.register(TenantPhoto)
class TenantPhotoAdmin(admin.ModelAdmin):
    list_display = ('tenant', 'content_type', 'uploaded_at') # 'image_blob' não é adequado para list_display
    list_filter = ('uploaded_at', 'content_type')
    search_fields = ('tenant__name',)