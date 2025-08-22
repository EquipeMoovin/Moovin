
from .views import StripeCheckoutView
from django.urls import path, include
urlpatterns = [
    path('checkout/',StripeCheckoutView.as_view(),name='checkout'),

]

