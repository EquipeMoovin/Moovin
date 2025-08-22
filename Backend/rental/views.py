from django.shortcuts import render, get_object_or_404
from django.views.generic import CreateView
from django.urls import reverse
from django.http import HttpResponseRedirect
from .models import Rental
from .forms import RentalForm
from .consts import RENT_STATUS_CHOICES
from immobile.models import Immobile
from tenant.models import Tenant

class RentalCreateView(CreateView):
    template_name = 'owner/rental_create.html'
    model = Rental
    form_class = RentalForm

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        pk = self.kwargs.get('pk')
        immobile = get_object_or_404(Immobile, id_immobile=pk)
        context['immobile'] = immobile
        context['tenants'] = Tenant.objects.all()  # Add tenants to context
        context['RENT_STATUS_CHOICES'] = RENT_STATUS_CHOICES
        return context

    def get_initial(self):
        initial = super().get_initial()
        pk = self.kwargs.get('pk')
        immobile = get_object_or_404(Immobile, id_immobile=pk)
        initial['immobile'] = immobile
        return initial

    def form_valid(self, form):
        rental = form.save(commit=False)
        immobile = get_object_or_404(Immobile, id_immobile=self.kwargs.get('pk'))
        immobile.status = 'Rented'
        immobile.save()
        rental.immobile = immobile
        rental.immobile.status = 'Rented'
        rental.save()
        return HttpResponseRedirect(self.get_success_url())

    def get_success_url(self):
        return reverse('owner-management')