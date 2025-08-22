from django import forms
from .models import Immobile, ImmobilePhoto
from .consts import *
class ImmobileRegisterPart1Form(forms.ModelForm):
    property_type = forms.ChoiceField(
        label='Tipo de Imóvel',  # Label em português
        choices= PROPERTY_TYPE_CHOICES
    )
    zip_code = forms.CharField(
        label='CEP',  # Label em português
        max_length=9
    )
    state = forms.CharField(
        label='Estado',  # Label em português
        max_length=2
    )
    city = forms.CharField(
        label='Cidade',  # Label em português
        max_length=100
    )
    street = forms.CharField(
        label='Rua',  # Label em português
        max_length=200
    )
    number = forms.CharField(
        label='Número',  # Label em português
        max_length=10
    )
    no_number = forms.BooleanField(
        label='Sem Número',  # Label em português
        required=False
    )
    bedrooms = forms.IntegerField(
        label='Quartos',  # Label em português
        min_value=0
    )
    bathrooms = forms.IntegerField(
        label='Banheiros',  # Label em português
        min_value=0
    )
    area = forms.DecimalField(
        label='Área (m²)',  # Label em português
        min_value=0
    )
    rent = forms.DecimalField(
        label='Aluguel (R$)',  # Label em português
        min_value=0
    )
    air_conditioning = forms.BooleanField(
        label='Ar Condicionado',  # Label em português
        required=False
    )
    garage = forms.BooleanField(
        label='Garagem',  # Label em português
        required=False
    )
    pool = forms.BooleanField(
        label='Piscina',  # Label em português
        required=False
    )
    furnished = forms.BooleanField(
        label='Mobiliado',  # Label em português
        required=False
    )
    pet_friendly = forms.BooleanField(
        label='Aceita Animais',  # Label em português
        required=False
    )
    nearby_market = forms.BooleanField(
        label='Próximo a Mercado',  # Label em português
        required=False
    )
    nearby_bus = forms.BooleanField(
        label='Próximo a Ônibus',  # Label em português
        required=False
    )
    internet = forms.BooleanField(
        label='Internet',  # Label em português
        required=False
    )
    class Meta:
        model = Immobile
        fields = [
            'property_type', 'zip_code', 'state', 'city', 'street', 'number', 'no_number',
            'bedrooms', 'bathrooms', 'area', 'rent', 'air_conditioning',
            'garage', 'pool', 'furnished', 'pet_friendly',
            'nearby_market', 'nearby_bus', 'internet',
        ]

class ImmobileRegisterPart2Form(forms.ModelForm):
    description = forms.CharField(
        label='Descrição do Imóvel',  # Label em português
        widget=forms.Textarea,
        required=True
    )
    additional_rules = forms.CharField(
        label='Regras Adicionais',  # Label em português
        widget=forms.Textarea,
        required=False
    )
    class Meta:
        model = Immobile
        fields = [
            'description',
            'additional_rules',
        ]

class ImmobileForm(forms.ModelForm):
    additional_rules = forms.CharField(widget=forms.Textarea, required=False) 
    class Meta:
        model = Immobile
        fields = [
            'property_type', 'zip_code', 'state', 'city', 'street', 'number', 'no_number',
            'bedrooms', 'bathrooms', 'area', 'rent', 'air_conditioning',
            'garage', 'pool', 'furnished', 'pet_friendly',
            'nearby_market', 'nearby_bus', 'internet','description',
            'additional_rules',
        ]


class ImmobilePhotoForm(forms.Form):
    class Meta:
        model = ImmobilePhoto
        fields = ['image']  # Inclua o campo que você quer editar
        widgets = {
            'image': forms.FileInput(attrs={'accept': '.png,.jpg,.jpeg'})
        }