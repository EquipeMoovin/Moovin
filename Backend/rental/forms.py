from django import forms
from .models import Rental

class RentalForm(forms.ModelForm):
    class Meta:
        model = Rental
        fields = ['tenant', 'immobile', 'start_data', 'end_data', 'status', 'value']
        widgets = {
            'start_data': forms.DateInput(attrs={'type': 'date'}),
            'end_data': forms.DateInput(attrs={'type': 'date'}),
        }
        labels = {
            'tenant': 'Inquilino',
            'immobile': 'Imóvel',
            'start_data': 'Data de Início',
            'end_data': 'Data de Fim',
            'status': 'Status',
            'value': 'Valor do Aluguel',
        }

    def clean(self):
        cleaned_data = super().clean()
        start_data = cleaned_data.get('start_data')
        end_data = cleaned_data.get('end_data')

        if start_data and end_data and start_data > end_data:
            raise forms.ValidationError("A data de início não pode ser posterior à data de fim.")
