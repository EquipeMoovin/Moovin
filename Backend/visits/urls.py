from django.urls import path
from rest_framework.routers import DefaultRouter
from .views import VisitViewSet, visit_create_view

router = DefaultRouter()
router.register(r'', VisitViewSet, basename='visit')

urlpatterns = [
    path('create-form/', visit_create_view, name='visit_create'),
]

urlpatterns += router.urls