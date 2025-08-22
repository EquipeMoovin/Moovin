from rest_framework import serializers
from .models import *
from tenant.models import *
from owner.models import *
from django.contrib.auth import get_user_model


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id','password','email','user_type','name']
        extra_kwargs = {'password':{'write_only':True}}
    
    def create(self,validated_data):
        user = User.objects.create_user(**validated_data)
        return user