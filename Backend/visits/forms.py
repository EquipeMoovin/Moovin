from django import forms
from .models import Visit
from immobile.models import Immobile
class VisitForm(forms.ModelForm):
    class Meta:
        model = Visit
        fields = ['name', 'date', 'time', 'immobile']
    def __init__(self, *args, **kwargs):
        user = kwargs.pop('user', None)
        super().__init__(*args, **kwargs)
        # filtra os imóveis apenas do usuário autenticado
        if user and hasattr(user, 'owner_profile'):
            owner = user.owner_profile.first() if hasattr(user.owner_profile, 'all') else user.owner_profile
            self.fields['immobile'].queryset = Immobile.objects.filter(owner=owner)