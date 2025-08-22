from django.shortcuts import render
from rest_framework.views import APIView
from .permissions import HasActiveSubscription
from rest_framework.response import Response
from .models import Subscription
from users.models import User
from .models import Plan
from django.utils import timezone
from datetime import timedelta
from django.contrib.auth.mixins import LoginRequiredMixin
from django.contrib import messages
from django.urls import reverse_lazy

from django.shortcuts import redirect
from django.views import View
import stripe
from django.conf import settings

stripe.api_key = settings.STRIPE_SECRET_KEY

class ProtectedView(APIView): 
    permission_classes = [HasActiveSubscription]

    def get(self, request):
        return Response({'message': f'Olá {request.user.name}, você possui assinatura ativa!'})
    

def create_checkout_session(amount, currency, success_url, cancel_url):
    session = stripe.checkout.Session.create(
        mode='subscription',
        payment_method_types=['card','boleto'],
        line_items=[{
            'price': 'price_1RWfPi2X2ndlMYPgUXf2iBaO',
            'quantity': 1,
        }],
        success_url=success_url,
        cancel_url=cancel_url,
    )
    return session.url

from django.views.decorators.csrf import csrf_exempt
from django.http import HttpResponse
import stripe
from django.conf import settings

@csrf_exempt
def stripe_webhook(request):
    payload = request.body
    sig_header = request.META['HTTP_STRIPE_SIGNATURE']
    event = None

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
        )
    except ValueError as e:
        return HttpResponse(status=400)
    except stripe.error.SignatureVerificationError as e:
        return HttpResponse(status=400)

    if event['type'] == 'checkout.session.completed':
        session = event['data']['object']
        user_email = session['customer_details']['email']
        user = User.objects.get(email = user_email)

        if(Subscription.objects.filter(user = user).exists()):
           subs = Subscription.objects.get(user = user)
           subs.active = True
           subs.save()
        else:
            plan = Plan.objects.first()
            Subscription.objects.create(user = user, plan = plan, end_date = timezone.now() + timedelta(days=30), active = True)

    return HttpResponse(status=200)



class StripeCheckoutView(LoginRequiredMixin,View):
    login_url = '/api/users/login-web/'
    
    def get(self, request, *args, **kwargs):
     
            user_email = request.user.email
            print(user_email)
            # Verifica se o e-mail pertence a um usuário
            try:
                user = User.objects.get(email=user_email)
            except User.DoesNotExist:
                return HttpResponse("Usuário não encontrado.", status=404)

            # URLs de sucesso e cancelamento
            success_url = request.build_absolute_uri('/')
            cancel_url = request.build_absolute_uri('/')

            # Cria a sessão de checkout
            checkout_url = create_checkout_session(
                amount=39.90,
                currency='brl',
                success_url=success_url,
                cancel_url=cancel_url
            )

            return redirect(checkout_url)

