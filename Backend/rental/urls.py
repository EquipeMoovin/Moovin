from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import *

urlpatterns = [
   path('rental-register/<str:pk>/',RentalCreateView.as_view(),name='rental-register'),
]
