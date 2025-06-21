from django.contrib import admin
from .models import Review

@admin.register(Review)


class ReviewAdmin(admin.ModelAdmin):
    list_display = ('author', 'type', 'rating', 'created_at','author_username')
    list_filter = ('type', 'created_at')
    search_fields = ('comment', 'author__username')

    def author_username(self, obj):
        return obj.author.username

    author_username.admin_order_field = 'author__username'  # permite ordenação
    author_username.short_description = 'Autor'  # título da coluna
