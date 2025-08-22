
from django.contrib import admin
from django.urls import path, include
from visits.views import visit_create_view
from django.views.generic import TemplateView 
from subscriptions.views import stripe_webhook
urlpatterns = [
    path('admin/', admin.site.urls),

    path('', TemplateView.as_view(template_name='landing_page/content.html'), name='landing_page'),
    path('stripe/webhook/', stripe_webhook, name='stripe-webhook'),
    path('api/immobile/', include('immobile.urls')),
    path('api/tenants/', include('tenant.urls')),
    path('api/users/',include('users.urls')),
    path('api/owners/',include('owner.urls')),
    path('api/reviews/',include ('review.urls')),
    path('api/visits/', include('visits.urls')),
    path('api/subscriptions/',include('subscriptions.urls')),
    path('api/notifications/', include('notification.urls')),
    path('api/rentals/', include('rental.urls')),
    path('api/chat/', include('chat.urls'))
]

