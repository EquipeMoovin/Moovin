from django import forms
from .models import OwnerPhoto

class OwnerPhotoForm(forms.ModelForm):
    upload = forms.FileField(required=True, label='Imagem')

    class Meta:
        model = OwnerPhoto
        fields = ['upload', 'content_type']  # NÃO inclua image_blob diretamente

    def save(self, commit=True):
        instance = super().save(commit=False)
        uploaded_file = self.cleaned_data.get('upload')
        if uploaded_file:
            instance.image_blob = uploaded_file.read()
            instance.content_type = uploaded_file.content_type
        if commit:
            instance.save()
        return instance