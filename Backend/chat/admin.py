from django.contrib import admin
from .models import Conversation, Message

@admin.register(Conversation)
class ConversationAdmin(admin.ModelAdmin):
    list_display = ('id', 'tenant', 'owner', 'immobile', 'created_at', 'updated_at')
    list_filter = ('created_at', 'updated_at', 'tenant', 'owner', 'immobile')
    search_fields = ('tenant__name', 'owner__name', 'immobile__title')  # ajuste o campo do immobile conforme necessário
    readonly_fields = ('created_at', 'updated_at')
    ordering = ('-updated_at',)


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ('id', 'conversation', 'sender', 'sent_at', 'is_read')
    list_filter = ('is_read', 'sent_at', 'sender')
    search_fields = ('conversation__tenant__name', 'conversation__owner__name', 'sender__email', 'content')
    readonly_fields = ('sent_at',)
    ordering = ('-sent_at',)
