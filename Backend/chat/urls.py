from django.urls import path
from .views import ConversationListView, ConversationCreateView, MessageCreateView, MessageMarkReadView

urlpatterns = [
    path('conversations/', ConversationListView.as_view(), name='conversation-list'),
    path('conversations/create/', ConversationCreateView.as_view(), name='conversation-create'),
    path('messages/create/', MessageCreateView.as_view(), name='message-create'),
    path('messages/<int:pk>/read/', MessageMarkReadView.as_view(), name='message-mark-read'),
]