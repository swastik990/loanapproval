from rest_framework import serializers
from .models import User
from django.contrib.auth.hashers import make_password

from rest_framework.authtoken.models import Token

class UserSignupSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['first_name', 'last_name', 'email', 'phone', 'dob', 'password', 'agree_terms']

    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        return super(UserSignupSerializer, self).create(validated_data)

class UserLoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()

