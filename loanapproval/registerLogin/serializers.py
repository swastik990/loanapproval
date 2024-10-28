from rest_framework import serializers
from .models import User

# class UserSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = User
#         fields = ['firstname', 'lastname', 'email', 'dob', 'phone', 'password', 'is_admin', 'agree_terms']
#         extra_kwargs = {'password': {'write_only': True}}

#     def create(self, validated_data):
#         # Hash the password before saving
#         user = User(
#             firstname=validated_data['firstname'],
#             lastname=validated_data['lastname'],
#             email=validated_data['email'],
#             dob=validated_data['dob'],
#             phone=validated_data['phone'],  
#             is_admin=validated_data['is_admin'],
#             agree_terms=validated_data['agree_terms'],
#         )
#         user.set_password(validated_data['password'])
#         user.save()
#         return user


from rest_framework.authtoken.models import Token

class UserRegistrationSerializer(serializers.ModelSerializer):
    token = serializers.CharField(read_only=True)

    class Meta:
        model = User
        fields = ['firstname', 'lastname', 'email', 'dob', 'phone', 'password', 'is_admin', 'agree_terms', 'token']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        # Hash the password before saving
        user = User(
            firstname=validated_data['firstname'],
            lastname=validated_data['lastname'],
            email=validated_data['email'],
            dob=validated_data['dob'],
            phone=validated_data['phone'],  
            is_admin=validated_data['is_admin'],
            agree_terms=validated_data['agree_terms'],
        )
        user.set_password(validated_data['password'])
        user.save()

        # Create token for the user
        token, created = Token.objects.get_or_create(user=user)
        
        # Attach the token to the user object (optional)
        user.token = token.key
        
        return user




class UserLoginSerializer(serializers.ModelSerializer):
   email = serializers.EmailField(max_length=255)
   class Meta:
       model= User
       fields=['email', 'password', 'is_admin']
