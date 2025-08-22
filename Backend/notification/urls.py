from django.urls import path
from .views import (
    NotificationListView,
    NotificationMarkReadView,
    NotificationCreateView,
    NotificationDeleteView,
    mark_all_as_read,
    SendNotificationView
)

urlpatterns = [
    path('', NotificationListView.as_view(), name='notification-list'),
    path('<int:pk>/read/', NotificationMarkReadView.as_view(), name='notification-mark-read'),
    path('create/', NotificationCreateView.as_view(), name='notification-create'),
    path('<int:pk>/', NotificationDeleteView.as_view(), name='notification-delete'),
    path('mark-all-read/', mark_all_as_read, name='notification-mark-all-read'),
    path('send/', SendNotificationView.as_view(), name='notification-send'),
]