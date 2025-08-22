from datetime import datetime

from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse
from django.shortcuts import render, redirect

from rest_framework import viewsets, permissions
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.exceptions import ValidationError

from .models import Visit
from .forms import VisitForm
from .serializers import VisitSerializer
from immobile.models import Immobile
from rest_framework.exceptions import ValidationError
from rest_framework.permissions import IsAuthenticated, AllowAny
from datetime import datetime


class VisitViewSet(viewsets.ModelViewSet):
    """
    ViewSet da API para agendamento de visitas.
    Restrito ao proprietário logado.
    """
    queryset = Visit.objects.all()
    serializer_class = VisitSerializer

    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]


    def get_queryset(self):
        return Visit.objects.filter(owner=self.request.user)

    def perform_create(self, serializer):
        date = serializer.validated_data['date']
        time = serializer.validated_data['time']
        immobile = serializer.validated_data['immobile']

        if Visit.objects.filter(immobile=immobile, date=date, time=time).exists():
            raise ValidationError("Já existe uma visita agendada para este imóvel neste horário.")

        if date < datetime.now().date():
            raise ValidationError("Não é possível agendar visitas para datas passadas.")

        serializer.save(owner=self.request.user)


# --- HTML tradicional (formulário com render) ---
@login_required(login_url='login-web')
def visit_create_view(request):
    if request.method == 'POST':
        form = VisitForm(request.POST, user=request.user)
        if form.is_valid():
            visit = form.save(commit=False)
            visit.owner = request.user
            visit.save()
            messages.success(request, "Visita agendada com sucesso!")
            return redirect('owner_visit_schedule')
        else:
            messages.error(request, "Erro ao enviar formulário.")
    else:
        form = VisitForm(user=request.user)

    return render(request, 'owner/visit_schedule.html', {'form': form})