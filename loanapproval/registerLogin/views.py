from django.shortcuts import render, redirect
import mysql.connector as sql
from rest_framework import status
from django.views.decorators.csrf import csrf_protect
from joblib import load
import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
from rest_framework.response import Response
from django.views.decorators.csrf import csrf_exempt
from .models import *
from rest_framework.decorators import api_view
from django.contrib.auth import authenticate, login as auth_login
from django.contrib.auth.hashers import make_password
from django.http import JsonResponse
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import UserRegistrationSerializer
from .serializers import UserLoginSerializer
from rest_framework.views import APIView
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import authenticate
import logging
from django.contrib import messages

#For Landing Page
@csrf_protect
def landing_page(request):
    if request.method == 'POST' and request.POST.get('action') == 'login_signup':
        # Redirect to the register/login page
        return redirect('user_action')  # Assuming you have a URL pattern named 'registerlogin'

    # Render the landing page by default
    return render(request, 'landingpage.html')

@csrf_protect
def user_action(request):
    if request.method == 'POST':
        action = request.POST.get('action')  # 'Sign Up' or 'Sign In'
        
        if action == 'SignUp':
            first_name = request.POST.get('firstname')
            last_name = request.POST.get('lastname')
            email = request.POST.get('Remail')
            dob = request.POST.get('dob')  # Convert to date format if necessary
            phone = request.POST.get('phone')
            password = request.POST.get('Rpassword')
            agree_terms = request.POST.get('agree_terms') == 'on'
            
            # Only proceed if terms are agreed to
            if agree_terms:
                try:
                    user = User.objects.create_user(
                        email=email,
                        first_name=first_name,
                        last_name=last_name,
                        phone=phone,
                        dob=dob,
                        password=make_password(['Rpassword']),
                        agree_terms=agree_terms,
                    )
                    user.save()
                    messages.success(request, "Account created successfully!")
                    return redirect('home')  # Redirect to a relevant page after signup
                except Exception as e:
                    print(f"Error saving user: {e}")
                    messages.error(request, "Failed to create account.")
            else:
                messages.error(request, "You must agree to terms and conditions to sign up.")
                
        elif action == 'SignIn':
            login_email = request.POST.get('Lemail')
            login_password = request.POST.get('Lpassword')

            # Validate email and password
            if not login_email or not login_password:
                return render(request, 'registerLogin.html', {'error': 'Email and password are required for login'})

            # Authenticate the user
            try:
                user = User.objects.get(email=login_email)
                if user.check_password(login_password):  # Use Django's password check method
                    return redirect('home')
                else:
                    return render(request, 'registerLogin.html', {'error': 'Invalid email or password'})
            except User.DoesNotExist:
                return render(request, 'registerLogin.html', {'error': 'Invalid email or password'})

    return render(request, 'registerLogin.html')


def success_page(request):
    return render(request, 'success.html')

#For Home Page
@csrf_protect
def home_page(request):
    if request.method == 'POST' and request.POST.get('action') == 'applyforaloan':
            return redirect('formInfo')

    return render(request, 'homepage.html')

#For Settings Page
@csrf_protect
def settings_page(request):
    if request.method == 'POST':
        pass
    return render(request, 'settings.html')

#jwt token authentication

def get_tokens_for_user(user):
    """Generate JWT tokens for the given user."""
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }


class UserSignupView(APIView):
    def post(self, request, *args, **kwargs):
        try:
            data = request.data
            required_fields = ['firstname', 'lastname', 'email', 'dob', 'phone', 'password', 'agree_terms']
            for field in required_fields:
                if field not in data:
                    return Response({"error": f"Missing required field: {field}"}, status=status.HTTP_400_BAD_REQUEST)

            user = User(
                firstname=data['firstname'],
                lastname=data['lastname'],
                email=data['email'],
                dob=data['dob'],
                phone=data['phone'],
                password=make_password(data['password']),
                is_admin=data.get('is_admin', False),
                agree_terms=data['agree_terms']
            )
            user.save()

            # Create JWT tokens
            refresh = RefreshToken.for_user(user)

            return Response({
                "message": "User created successfully",
                "refresh": str(refresh),
                "access": str(refresh.access_token)
            }, status=status.HTTP_201_CREATED)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
    
    def get(self, request, *args, **kwargs):
        return Response({"error": "GET method not allowed"}, status=status.HTTP_405_METHOD_NOT_ALLOWED)




class UserLoginView(APIView):
    def post(self, request, format=None):
        serializer = UserLoginSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            email = serializer.data.get('email')
            password = serializer.data.get('password')

            user = authenticate(request, email=email, password=password)
            
            if user is not None:
                # Create JWT tokens
                refresh = RefreshToken.for_user(user)
                return Response({
                    'refresh': str(refresh),
                    'access': str(refresh.access_token),
                    'msg': 'Login successful'
                }, status=status.HTTP_200_OK)
            else:
                return Response({'errors': {'non_field_errors': ['Invalid credentials']}}, status=status.HTTP_401_UNAUTHORIZED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        


#loading model
model = load('./predictionModel/model.joblib')
preprocessor = load('./predictionModel/preprocessor.joblib')

# # Utility function to get feature names from ColumnTransformer
# def get_feature_names(preprocessor):
#     feature_names = []
#     if isinstance(preprocessor, ColumnTransformer):
#         for name, transformer, columns in preprocessor.transformers_:
#             if hasattr(transformer, 'get_feature_names_out'):
#                 feature_names.extend(transformer.get_feature_names_out())
#             elif isinstance(transformer, OneHotEncoder):
#                 feature_names.extend(transformer.get_feature_names_out(input_features=columns))
#             else:
#                 feature_names.extend(columns)
#     return feature_names

def predictor(request):
    return render(request, 'form.html')

def formInfo(request):
    try:
        # Getting form data with default values if missing
        
        education = request.POST.get('education', 'Not Graduate').strip()  # Default value added
        self_employed = request.POST.get('employment', 'No').strip()  # Default value added
        loan_amount = float(request.POST.get('Loanamount', 0))
        loan_term = float(request.POST.get('Loanterm', 0))
        no_of_dependents = float(request.POST.get('dependers', 0))
        cibil_score = float(request.POST.get('credit', 0))
        income_annum = float(request.POST.get('annualIncome', 0))
        residential_assets_value = float(request.POST.get('residentialAsset', 0))
        commercial_assets_value = float(request.POST.get('commercialAsset', 0))
        luxury_assets_value = float(request.POST.get('luxuryAsset', 0))
        bank_asset_value = float(request.POST.get('bankAsset', 0))
        
        print(f"education: {education}")
        print(f"self_employed: {self_employed}")

        

        # Preparing the input DataFrame 
        input_data = pd.DataFrame([[
            no_of_dependents,
            education,
            self_employed,
            income_annum,
            loan_amount,
            loan_term,
            cibil_score,
            residential_assets_value,
            commercial_assets_value,
            luxury_assets_value,
            bank_asset_value
        ]], columns=[
            ' no_of_dependents',
            ' education',
            ' self_employed',
            ' income_annum',
            ' loan_amount',
            ' loan_term',
            ' cibil_score',
            ' residential_assets_value',
            ' commercial_assets_value',
            ' luxury_assets_value',
            ' bank_asset_value'
        ])

        application = Application(
            user_id = 2,
            loan_amount=loan_amount,
            loan_terms=loan_term,
            credit_score=cibil_score,
            no_of_dependents=no_of_dependents,
            education=education == 'Graduate',  # Boolean field in the model
            self_employed=self_employed == 'Yes',  # Boolean field in the model
            annual_income=income_annum,
            residential_asset=residential_assets_value,
            commercial_asset=commercial_assets_value,
            luxury_asset=luxury_assets_value,
            bank_asset=bank_asset_value,
            state=request.POST.get('state', '').strip(),
            street=request.POST.get('street', '').strip(),
            citizenship_no=request.POST.get('citizenship_no', '').strip(),
            zip_code=request.POST.get('zip_code', '').strip(),
            submitted_time=pd.Timestamp.now()  # Store current time as submission time
        )
        application.save()
        # Get the column order expected by the preprocessor
        # expected_columns = get_feature_names(preprocessor)

        # # Ensure all expected columns are present in input_data
        # for col in expected_columns:
        #     if col not in input_data.columns:
        #         input_data[col] = 0  # Add missing columns with default value

        # # Reorder columns to match expected column order
        # input_data = input_data[expected_columns]

        # # Apply preprocessor
        # input_data_transformed = preprocessor.transform(input_data)

        # Make the prediction
        prediction = model.predict(input_data)

        # Convert the prediction into a human-readable format
        prediction_text = "Congratulations, your loan is approved!" if prediction == 1 else "Sorry, your loan application is rejected."

        # Render the result page
        return render(request, 'result.html', {'prediction': prediction_text})

    except Exception as e:
        return render(request, 'result.html', {'prediction': f"An error occurred: {str(e)}"})
def form_view(request):
    return render(request, 'form.html')



# from rest_framework.response import Response
# from rest_framework import status
# from rest_framework.views import APIView
# from rest_framework_simplejwt.tokens import RefreshToken
# from django.contrib.auth import authenticate

from .serializers import (
    UserRegistrationSerializer,
    UserLoginSerializer,
    # UserProfileSerializer,
    # UserChangePasswordSerializer,
    # SendPasswordResetEmailSerializer,
    # UserPasswordResetSerializer
)
from .renderers import UserRenderer
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.hashers import make_password
