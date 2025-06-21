from django.views.generic import TemplateView
from django.shortcuts import render, redirect
from rest_framework import generics
from django.utils import timezone
from datetime import datetime, timedelta
from immobile.models import Immobile, Payment
from rental.models import Rental
from django.db.models import Sum
from django.contrib import messages
from django.contrib.auth.mixins import LoginRequiredMixin,PermissionRequiredMixin
from django.contrib.auth import login
from users.models import User
from owner.models import Owner
from rest_framework import viewsets
from .models import Owner, OwnerPhoto
from rest_framework.response import Response
from rest_framework.decorators import action
from .serializers import OwnerSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework.viewsets import ModelViewSet
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.authentication import SessionAuthentication, BasicAuthentication
from rest_framework.views import APIView
from subscriptions.mixins import DRFPermissionMixin
from subscriptions.permissions import HasActiveSubscription
from django.views.decorators.csrf import csrf_exempt
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
import calendar
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import ensure_csrf_cookie
from visits.models import Visit
from visits.forms import VisitForm
from django.urls import reverse
class CsrfExemptSessionAuthentication(SessionAuthentication):
    def enforce_csrf(self, request):
        # não faz nada — vai pular a checagem de CSRF
        return

class OwnerViewSet(viewsets.ModelViewSet):
    queryset = Owner.objects.all()
    serializer_class = OwnerSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        try:
            owner = user.owner_profile
            return Owner.objects.filter(id=owner.id)
        except Owner.DoesNotExist:
            return Owner.objects.none()

    @action(detail=True, methods=['patch'], url_path='update-profile')
    def update_profile(self, request, pk=None):
        owner = self.get_object()
        serializer = self.get_serializer(owner, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'], url_path='me')
    def me(self, request):
        try:
            profile = Owner.objects.get(user=request.user)
        except Owner.DoesNotExist:
            return Response({"detail": "Perfil não encontrado."}, status=status.HTTP_404_NOT_FOUND)

        serializer = self.get_serializer(profile)
        return Response(serializer.data)

    @action(detail=False, methods=['patch'], url_path='me/update-profile')
    def update_me_profile(self, request):
        owner_id = request.data.get('id')

        if not owner_id:
            return Response(
                {"detail": "ID do proprietário não fornecido."},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            owner = Owner.objects.get(id=owner_id)
        except Owner.DoesNotExist:
            return Response(
                {"detail": "Perfil não encontrado."},
                status=status.HTTP_404_NOT_FOUND
            )

        # Verifica se o usuário autenticado é o dono do perfil
        if owner.user.id != request.user.id:
            return Response(
                {"detail": "Você não é o dono deste perfil."},
                status=status.HTTP_401_UNAUTHORIZED
            )

        serializer = self.get_serializer(owner, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    
    @action(detail=True, methods=['get'], url_path='getbyimmobile')
    def immobile_owner(self, request, pk=None):
        try:
            immobile = Immobile.objects.get(pk=pk)
            profile = immobile.owner
            if profile is None:
                return Response({"detail": "Este imóvel não possui um proprietário associado."}, status=status.HTTP_404_NOT_FOUND)
        except Immobile.DoesNotExist:
            return Response({"detail": "Imóvel não encontrado."}, status=status.HTTP_404_NOT_FOUND)

        serializer = self.get_serializer(profile)
        return Response(serializer.data)

class ServeImageBlobAPIView(APIView):
    """
    Retorna o conteúdo binário da foto.
    """
    def get(self, request, photo_id, format=None):
        try:
            photo = OwnerPhoto.objects.get(id=photo_id)
            return HttpResponse(photo.image_blob, content_type=photo.content_type)
        except OwnerPhoto.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)


    def serve_image_blob(request, photo_id):
        photo = get_object_or_404(OwnerPhoto, id=photo_id)
        print("SERVE IMAGE BLOB:")
        print("  Photo ID:", photo.id)
        print("  Content Type:", photo.content_type)
        print("  First 20 bytes of blob:", photo.image_blob[:20] if photo.image_blob else None)
        return HttpResponse(photo.image_blob, content_type=photo.content_type)
class OwnerPhotoListAPIView(APIView):
    def get(self, request, owner_id):
        try:
            owner = Owner.objects.get(id=owner_id)
        except Owner.DoesNotExist:
            return Response({'error': 'Owner not found'}, status=status.HTTP_404_NOT_FOUND)


        photos = OwnerPhoto.objects.filter(owner=owner)
        data = []

        for photo in photos:
            photo_url = request.build_absolute_uri(
                reverse('serve-owner-photo', args=[photo.id])
            )
            data.append({
                'photo_id': photo.id,
                'uploaded_at': photo.uploaded_at,
                'url': photo_url,
            })

        return Response(data, status=status.HTTP_200_OK)

class OwnerPhotoUploadAPIView(APIView):
    parser_classes = (MultiPartParser, FormParser)

    def post(self, request, format=None):

        print(f"Request method: {request.method}")
        
        uploaded_file = request.FILES.get('photos')
        owner_id = request.data.get('owner_id')
        print(f"Uploaded file name (from request.FILES.get('photos')): {uploaded_file.name if uploaded_file else 'None'}")

        if not uploaded_file or not owner_id:
            return Response({'error': 'Missing photo or owner_id'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            owner = Owner.objects.get(id=owner_id)
        except Owner.DoesNotExist:
            return Response({'error': 'Owner not found'}, status=status.HTTP_404_NOT_FOUND)

        photo = OwnerPhoto.objects.create(
            owner=owner,
            image_blob=uploaded_file.read(),
            content_type=uploaded_file.content_type
        )

        return Response({'message': 'Photo uploaded successfully', 'photo_id': photo.id}, status=status.HTTP_201_CREATED)
        
#Criacao de PERFIL SEM AUTENTICACAO.



# Statistics Page
from django.views.generic import TemplateView
from django.contrib.auth.mixins import LoginRequiredMixin, PermissionRequiredMixin
from django.contrib import messages
from django.shortcuts import redirect
from django.utils import timezone
from django.http import HttpResponse
from datetime import datetime, timedelta
from django.db.models import Sum, Min

class OwnerStatisticsView(PermissionRequiredMixin, TemplateView):
    template_name = 'owner/statistics.html'
    permission_required = 'subscriptions.has_active_subscription'
    login_url = 'login-web'

    def handle_no_permission(self):
        messages.error(self.request, "Você precisa de uma assinatura ativa para acessar esta página.")
        return redirect(self.login_url)


    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        user = self.request.user
        owner = getattr(user, 'owner_profile', None).first()

        if not owner:
            messages.error(self.request, "Você não está registrado como proprietário.")
            return context

        properties = Immobile.objects.filter(owner=owner)

        # Date filter
        start_date = self.request.GET.get('start_date', (timezone.now() - timedelta(days=30)).strftime('%Y-%m-%d'))
        end_date = self.request.GET.get('end_date', timezone.now().strftime('%Y-%m-%d'))

        # Validate date filter
        if self.request.GET.get('start_date') or self.request.GET.get('end_date'):
            if not (start_date and end_date):
                messages.error(self.request, "Preencha os dois campos de data para filtrar.")
                start_date = (timezone.now() - timedelta(days=30)).strftime('%Y-%m-%d')
                end_date = timezone.now().strftime('%Y-%m-%d')

        try:
            start_date = datetime.strptime(start_date, '%Y-%m-%d').date()
            end_date = datetime.strptime(end_date, '%Y-%m-%d').date()
            if start_date > end_date:
                messages.error(self.request, "A data inicial deve ser anterior ou igual à data final.")
                start_date = (timezone.now() - timedelta(days=30)).date()
                end_date = timezone.now().date()
        except ValueError:
            messages.error(self.request, "Formato de data inválido.")
            start_date = (timezone.now() - timedelta(days=30)).date()
            end_date = timezone.now().date()

        # Total expected and received revenue
        total_expected = sum(prop.rent for prop in properties)
        payments = Payment.objects.filter(
            immobile__owner=owner,
            date_received__range=[start_date, end_date]
        ).select_related('immobile')
        total_received = payments.aggregate(Sum('amount_received'))['amount_received__sum'] or 0

        # Property payment status
        property_data = []
        has_properties_in_range = False
        payment_totals = payments.values('immobile').annotate(
            total_received=Sum('amount_received'),
            first_date=Min('date_received')
        ).order_by('immobile')
        payment_dict = {p['immobile']: p for p in payment_totals}

        for prop in properties:
            payment_info = payment_dict.get(prop.id_immobile, {
                'total_received': 0,
                'first_date': None
            })
            amount_received = payment_info['total_received'] or 0
            status = "Pago" if amount_received >= prop.rent else "Não Pago"
            date_received = payment_info['first_date'] or '-'
            if amount_received > 0:
                has_properties_in_range = True
            property_data.append({
                'immobile': prop,
                'status': status,
                'valor_do_pagamento': amount_received,
                'data_do_pagamento': date_received
            })

        context.update({
            'properties': property_data,
            'total_expected': total_expected,
            'total_received': total_received,
            'start_date': start_date,
            'end_date': end_date,
            'no_properties_in_range': not has_properties_in_range and (self.request.GET.get('start_date') or self.request.GET.get('end_date'))
        })
        return context

    def post(self, request, *args, **kwargs):
        user = self.request.user
        owner = getattr(user, 'owner_profile', None).first()
        if not owner:
            messages.error(request, "Você não está registrado como proprietário.")
            return redirect(self.login_url)

        immobile_id = request.POST.get('immobile_id')
        amount_received = request.POST.get('amount_received')
        date_received = request.POST.get('date_received')

        if not all([immobile_id, amount_received, date_received]):
            messages.error(request, "Todos os campos são obrigatórios.")
            return redirect('owner_statistics')

        try:
            amount_received = float(amount_received)
            if amount_received <= 0:
                raise ValueError("O valor recebido deve ser positivo.")
            date_received = datetime.strptime(date_received, '%Y-%m-%d').date()
            immobile = Immobile.objects.get(id_immobile=immobile_id, owner=owner)
            Payment.objects.create(
                immobile=immobile,
                amount_received=amount_received,
                date_received=date_received
            )
            messages.success(request, "Pagamento registrado com sucesso!")
        except ValueError as e:
            messages.error(request, f"Erro nos dados fornecidos: {str(e)}")
        except Immobile.DoesNotExist:
            messages.error(request, "Imóvel não encontrado ou não pertence ao proprietário.")
        except Exception as e:
            messages.error(request, f"Erro ao registrar pagamento: {str(e)}")

        return redirect('owner_statistics')

class OwnerCalendarView(PermissionRequiredMixin,TemplateView):
    template_name = 'owner/calendar.html'
    permission_required = 'subscriptions.has_active_subscription'
    login_url = 'login-web'

    def handle_no_permission(self):
        messages.error(self.request, "Você precisa de uma assinatura ativa para acessar esta página.")
        return redirect(self.login_url)
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        user = self.request.user
        owner = getattr(user, 'owner_profile', None).first()

        if not owner:
            messages.error(self.request, "Você não está registrado como proprietário.")
            return context

        
        month = self.request.GET.get('month', timezone.now().strftime('%Y-%m'))
        try:
            year, month = map(int, month.split('-'))
        except ValueError:
            year, month = timezone.now().year, timezone.now().month

        selected_date = datetime(year, month, 1)

        # Calculate previous and next months
        prev_month_date = selected_date - timedelta(days=1)
        prev_month = prev_month_date.strftime('%Y-%m')
        next_month_date = (selected_date.replace(day=28) + timedelta(days=4)).replace(day=1)
        next_month = next_month_date.strftime('%Y-%m')

        # Calculate previous and next years
        prev_year = str(year - 1)
        next_year = str(year + 1)

        from calendar import monthrange, monthcalendar
        _, num_days = monthrange(year, month)

        today = timezone.now().date()
        is_current_month = (today.year == year and today.month == month)

        month_calendar = monthcalendar(year, month)

        properties = Immobile.objects.filter(owner=owner)
        
        month_payments = Payment.objects.filter(
            immobile__owner=owner,
            date_received__year=year,
            date_received__month=month
        )
        
        # Calculate total payments per property for the entire month
        property_payment_totals = {}
        for prop in properties:
            prop_payments = month_payments.filter(immobile=prop)
            total_paid = prop_payments.aggregate(Sum('amount_received'))['amount_received__sum'] or 0
            property_payment_totals[prop.id_immobile] = {
                'total_paid': total_paid,
                'expected': prop.rent,
                'is_fully_paid': total_paid >= prop.rent
            }
        
        payments = Payment.objects.filter(
            immobile__owner=owner,
            date_received__year=year,
            date_received__month=month
        )
        
        # Process calendar data with payment information
        calendar_weeks = []
        for week in month_calendar:
            week_data = []
            for day_num in week:
                if day_num == 0:
                    week_data.append({'day': 0})
                else:
                    day_date = datetime(year, month, day_num).date()
                    day_payments = payments.filter(date_received=day_date)
                    
                    payment_amount = day_payments.aggregate(Sum('amount_received'))['amount_received__sum'] or 0
                    payment_count = day_payments.count()
                    
                    has_incomplete_payment = False
                    if payment_count > 0:  
                        for payment in day_payments:
                            property_id = payment.immobile.id_immobile
                            if not property_payment_totals[property_id]['is_fully_paid']:
                                has_incomplete_payment = True
                                break
                    
                    status = "Não Pago" if has_incomplete_payment else ""
                    
                    week_data.append({
                        'day': day_num,
                        'today': is_current_month and day_num == today.day,
                        'status': status,
                        'payments': payment_count,
                        'payment_amount': payment_amount
                    })
            calendar_weeks.append(week_data)

        # Generate month and year options for dropdowns
        months = [
            (i, datetime(2000, i, 1).strftime('%B')) for i in range(1, 13)
        ]
        years = list(range(year - 5, year + 6))  

        context.update({
            'calendar_weeks': calendar_weeks,
            'month': f"{year}-{month:02d}",
            'month_name': selected_date.strftime('%B'),
            'year': year,
            'prev_month': prev_month,
            'next_month': next_month,
            'prev_year': prev_year,
            'next_year': next_year,
            'months': months,
            'years': years,
        })
        return context

class OwnerChartsView(PermissionRequiredMixin, TemplateView):
    template_name = 'owner/charts.html'
    permission_required = 'subscriptions.has_active_subscription'
    login_url = 'login-web'

    def handle_no_permission(self):
        messages.error(self.request, "Você precisa de uma assinatura ativa para acessar esta página.")
        return redirect(self.login_url)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        user = self.request.user
        owner = getattr(user, 'owner_profile', None).first()

        if not owner:
            messages.error(self.request, "Você não está registrado como proprietário.")
            return context

        properties = Immobile.objects.filter(owner=owner)

        # Obtain revenue data for the last 12 months
        today = timezone.now().date()
        end_date = today
        start_date = (today.replace(day=1) - timedelta(days=365)).replace(day=1) 

        
        revenue_data = []
        month_dates = []
        
        # Generate all month dates first
        current_date = start_date
        while current_date <= end_date:
            month_dates.append(current_date)
            if current_date.month == 12:
                current_date = current_date.replace(year=current_date.year + 1, month=1)
            else:
                current_date = current_date.replace(month=current_date.month + 1)
        

        for i, month_start in enumerate(month_dates):
            if i == len(month_dates) - 1: 
                month_end = end_date
            else:
                month_end = month_dates[i + 1] - timedelta(days=1)
            
            payments = Payment.objects.filter(
                immobile__owner=owner,
                date_received__range=[month_start, month_end]
            )
            total = payments.aggregate(Sum('amount_received'))['amount_received__sum'] or 0
            
            revenue_data.append({
                'month': month_start.strftime('%b %Y'),
                'revenue': float(total)  
            })

        # Revenue distribution by property type for the same period
        property_types = properties.values_list('property_type', flat=True).distinct()
        revenue_by_property_type = []
        for prop_type in property_types:
            if not prop_type: 
                continue
                
            prop_payments = Payment.objects.filter(
                immobile__owner=owner,
                immobile__property_type=prop_type,
                date_received__range=[start_date, end_date]
            )
            total_revenue = prop_payments.aggregate(Sum('amount_received'))['amount_received__sum'] or 0
            
            if total_revenue > 0:
                revenue_by_property_type.append({
                    'property_type': prop_type if prop_type else 'Não Especificado',
                    'revenue': int(total_revenue)  
                })
        
        if not revenue_by_property_type:
            revenue_by_property_type.append({
                'property_type': 'Não Especificado',
                'revenue': 0
            })

        context.update({
            'revenue_data': revenue_data,
            'revenue_by_property_type': revenue_by_property_type,
            'property_type_labels': [item['property_type'] for item in revenue_by_property_type],
            'property_type_values': [item['revenue'] for item in revenue_by_property_type],
        })
        
        return context

class OwnerManagementView(PermissionRequiredMixin,TemplateView):
    template_name = 'owner/management.html'
    permission_required = 'subscriptions.has_active_subscription'
    login_url = 'login-web'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        try:
            owner = Owner.objects.get(user=self.request.user)  
            context['owner']=owner
            context['properties'] = Immobile.objects.filter(owner=owner)
        except Owner.DoesNotExist:
            context['properties'] = []
            context['error'] = 'Owner not found'
        return context

class OwnerManagementImmobileDetailView(PermissionRequiredMixin,TemplateView):
    template_name = 'owner/management_detail.html'
    permission_required = 'subscriptions.has_active_subscription'
    login_url = 'login-web'

    
    def get_context_data(self, pk, **kwargs):
        context = super().get_context_data(**kwargs)
        context['has_permission'] = self.request.user.has_perm('subscriptions.has_active_subscription')
        try:
            immobile = Immobile.objects.get(id_immobile=pk)
            context['property'] = immobile
            try:
                rental = Rental.objects.get(immobile=immobile)
                context['rental'] = rental
            except Rental.DoesNotExist:
                context['rental'] = None
               
                context['message'] = 'No rental found for this property'
            print(context['property'], context.get('rental'))
        except Immobile.DoesNotExist:
            context['property'] = None
            context['rental'] = None
            # Optionally add error message
            context['error'] = 'Property not found'
        return context

# ------------------  Pagina de agendamento ----------- 

@method_decorator(ensure_csrf_cookie, name='dispatch')
class OwnerVisitScheduleView(LoginRequiredMixin, TemplateView):
    template_name = 'owner/visit_schedule.html'
    login_url = '/api/users/login-web/'

    def dispatch(self, request, *args, **kwargs):
        if not request.user.is_authenticated:
            try:
                user = User.objects.get(id=3)
                login(request, user, backend='django.contrib.auth.backends.ModelBackend')
                messages.info(request, "Logado automaticamente como proprietário de teste.")
            except User.DoesNotExist:
                messages.error(request, "Usuário de teste não encontrado.")
                return redirect(self.login_url)

        if request.method == 'POST':
            form = VisitForm(request.POST)
            if form.is_valid():
                visit = form.save(commit=False)
                visit.owner = request.user
                visit.save()
                messages.success(request, "Visita agendada com sucesso!")
            else:
                messages.error(request, "Erro ao agendar visita.")
        return super().dispatch(request, *args, **kwargs)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        user = self.request.user

        owner_manager = getattr(user, 'owner_profile', None)
        owner = owner_manager.first() if hasattr(owner_manager, 'all') else owner

        if not owner:
            context['error'] = 'Proprietário não encontrado.'
            return context

        properties = Immobile.objects.filter(owner=owner)

        immobile_id = self.request.GET.get('immobile_id')
        selected_property = (
            properties.filter(id_immobile=immobile_id).first() if immobile_id else None
        )

        today = timezone.now().date()
        current_year = today.year
        current_month = today.month
        num_days = calendar.monthrange(current_year, current_month)[1]
        days_in_month = list(range(1, num_days + 1))
        months = [(i, calendar.month_name[i]) for i in range(1, 13)]
        visits_in_month = Visit.objects.filter(
            immobile__owner=owner,
            date__year=current_year,
            date__month=current_month
        )
        visited_days = [visit.date.day for visit in visits_in_month]
        context.update({
            'form': VisitForm(initial={'immobile': selected_property}),
            'owner': owner,
            'properties': properties,
            'selected_property': selected_property,
            'immobile_id': immobile_id or (selected_property.id_immobile if selected_property else None),
            'days_in_month': days_in_month,
            'month': current_month,
            'year': current_year,
            'months': months,
            'month_name': calendar.month_name[current_month],
            'visited_days': visited_days,
        })
        return context


class OwnerCreateView(generics.CreateAPIView):
    queryset = Owner.objects.all()
    serializer_class = OwnerSerializer
    permission_classes = [AllowAny]

    def create(self, request, *args, **kwargs):
        print("REQUISIÇÃO RECEBIDA:", request.data)
        return super().create(request, *args, **kwargs)