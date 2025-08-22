# owner/admin.py
from django.contrib import admin
from .models import Owner,OwnerPhoto
from immobile.models import Immobile  # ajuste o import para o seu app immobile
from .forms import OwnerPhotoForm
admin.site.register(OwnerPhoto)
# 1) Cria o inline para Immobile
class ImmobileInline(admin.TabularInline):
    model = Immobile
    extra = 1             
    fields = [
        'property_type', 'zip_code', 'city', 'street', 'number',
        'bedrooms', 'bathrooms', 'rent', 'status','area'
    ]
    readonly_fields = ['id_immobile']
class OwnerPhotoInline(admin.TabularInline):
    model = OwnerPhoto
    form = OwnerPhotoForm
    extra = 1
    fields = ['content_type', 'uploaded_at']
    readonly_fields = ['uploaded_at']  

@admin.register(Owner)
class OwnerAdmin(admin.ModelAdmin):
    list_display = ['name', 'phone', 'city', 'state']
    inlines = [ImmobileInline,OwnerPhotoInline] 
