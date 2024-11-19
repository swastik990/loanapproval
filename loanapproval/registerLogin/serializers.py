from rest_framework import serializers
from .models import User,Feedback
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


class FeedbackSerializer(serializers.ModelSerializer):
    class Meta:
        model = Feedback
        fields = ['fb_id', 'feedback', 'rating', 'feedback_time']
        read_only_fields = ['fb_id', 'feedback_time']

    def create(self, validated_data):
        user = self.context['request'].user  # Get the logged-in user
        validated_data['user'] = user       # Assign the user to feedback
        return super().create(validated_data)
