from rest_framework import serializers
from .models import User,Feedback,LoanStatus
from django.contrib.auth.hashers import make_password
from django.contrib.auth.password_validation import validate_password
from rest_framework.authtoken.models import Token
from decimal import Decimal, InvalidOperation

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



class UserUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'user_id', 'first_name', 'last_name', 'phone', 'dob', 'email',
            'pictures',  'agree_terms', 'check_in_time'
        ]
        read_only_fields = ['user_id', 'email', 'check_in_time']  # Make these fields read-only

    def update(self, instance, validated_data):
        # Update each field with validated data if provided
        instance.first_name = validated_data.get('first_name', instance.first_name)
        instance.last_name = validated_data.get('last_name', instance.last_name)
        instance.phone = validated_data.get('phone', instance.phone)
        instance.dob = validated_data.get('dob', instance.dob)
        instance.pictures = validated_data.get('pictures', instance.pictures)
        instance.agree_terms = validated_data.get('agree_terms', instance.agree_terms)
        
        instance.save()
        return instance


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True)
    confirm_new_password = serializers.CharField(required=True)

    def validate(self, data):
        # Ensure new passwords match
        if data['new_password'] != data['confirm_new_password']:
            raise serializers.ValidationError({"confirm_new_password": "New passwords must match."})
        
        # Validate new password against Django's validators
        validate_password(data['new_password'])

        # Check if new password is not the same as the old one
        user = self.context['request'].user
        if user.check_password(data['new_password']):
            raise serializers.ValidationError({"new_password": "New password cannot be the same as the old password."})
        
        return data
    

class LoanStatusSerializer(serializers.ModelSerializer):
    loan_amount = serializers.SerializerMethodField()

    class Meta:
        model = LoanStatus
        fields = ['loan_amount', 'status', 'time_updated']

    def get_loan_amount(self, obj):
        try:
            # Round to 2 decimal places
            return round(float(obj.application.loan_amount), 2)
        except (TypeError, ValueError, InvalidOperation):
            return None
