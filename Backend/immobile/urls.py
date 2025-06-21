
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views
from .views import ImmobileViewSet
router = DefaultRouter()
router.register(r'', ImmobileViewSet, basename='immobile')
urlpatterns = [
    path('register/part1/', views.ImmobileRegisterPart1View.as_view(), name='register_immobile_part1'),
    path('register/part2/<int:immobile_id>/', views.ImmobileRegisterPart2View.as_view(), name='register_immobile_part2'),
    path('details/<int:pk>/', views.ImmobileDetailTemplateView.as_view(), name='immobile_detail'),
    path('edit/<int:pk>', views.ImmobileEditViewPart1.as_view(), name='immobile_edit'),
    path('edit/part2/<int:pk>/', views.ImmobileEditViewPart2.as_view(), name='immobile_edit_part2'),
    path('destroy/<int:pk>/', views.ImmobileDeleteView.as_view(), name='immobile_delete'),
    path('photo/blob/<int:photo_id>/', views.serve_image_blob, name='serve_image_blob'),
    path('', views.ImmobileListAPIView.as_view(), name='immobile-list-api'),
    path('<int:id_immobile>/', views.ImmobileDetailAPIView.as_view(), name='immobile-detail-api'),
    path('photo/blob/<int:photo_id>/', views.ServeImageBlobAPIView.as_view(), name='serve_image_blob_api'),
    path('', include(router.urls)),
    
]

