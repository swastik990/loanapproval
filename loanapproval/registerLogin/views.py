from venv import logger
from django.shortcuts import render, redirect
import mysql.connector as sql
from rest_framework import status
from django.views.decorators.csrf import csrf_protect
from joblib import load
import numpy as np
import pandas as pd
from rest_framework.parsers import MultiPartParser, FormParser
from sklearn.preprocessing import OneHotEncoder
from rest_framework.response import Response
from django.views.decorators.csrf import csrf_exempt
from .models import *
from rest_framework.decorators import api_view
from django.contrib.auth import authenticate, login as auth_login
from django.contrib.auth.hashers import make_password
from django.http import JsonResponse
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import UserLoginSerializer, UserUpdateSerializer,ChangePasswordSerializer, LoanStatusSerializer
from rest_framework.views import APIView
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import authenticate
from django.contrib.auth import login 
from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.contrib.auth import get_user_model
from registerLogin.models import User   
from rest_framework.decorators import api_view,permission_classes
from rest_framework.response import Response
from rest_framework import status
import pandas as pd
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
import pandas as pd
from .models import Application, User
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import Application
import pandas as pd
from rest_framework.permissions import IsAuthenticated
from .models import Feedback
from .serializers import FeedbackSerializer

User = get_user_model()

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
    # Initialize context for separate messages
    context = {
        'signup_messages': [],
        'signin_messages': []
    }

    if request.method == 'POST':
        action = request.POST.get('action')  # 'SignUp' or 'SignIn'

        if action == 'SignUp':
            first_name = request.POST.get('firstname', '').strip()
            last_name = request.POST.get('lastname', '').strip()
            email = request.POST.get('Remail', '').strip()
            dob = request.POST.get('dob', '').strip()
            phone = request.POST.get('phone', '').strip()
            password = request.POST.get('Rpassword', '').strip()
            agree_terms = request.POST.get('agree_terms') == 'on'

            try:
                # Check if email is already registered
                if User.objects.filter(email=email).exists():
                    context['signup_messages'].append("An account with this email already exists.")
                    return render(request, 'registerLogin.html', context)

                # Create and save the user
                user = User.objects.create_user(
                    email=email,
                    first_name=first_name,
                    last_name=last_name,
                    phone=phone,
                    dob=dob,
                    password=password,
                    agree_terms=agree_terms,
                )
                user.save()
                context['signin_messages'].append("Account created successfully!")

            except Exception as e:
                print(f"Error during signup: {e}")
                context['signup_messages'].append("An error occurred while creating your account. Please try again.")
                return render(request, 'registerLogin.html', context)

        elif action == 'SignIn':
            login_email = request.POST.get('Lemail', '').strip()
            login_password = request.POST.get('Lpassword', '').strip()
            
                        # Check if email exists before authentication
            if not User.objects.filter(email=login_email).exists():
                context['signin_messages'].append("Account not registered")
                return render(request, 'registerLogin.html', context)

                # Authenticate user
            user = authenticate(request, username=login_email, password=login_password)
            if user:
        # If authentication is successful, log the user in
                login(request, user)
                context['signin_messages'].append("Logged in successfully!")
                return redirect('home')  # Redirect to the home page
            else:
        # If authentication fails, show a generic error message
                context['signin_messages'].append("Invalid email or password.")
                return render(request, 'registerLogin.html', context)

    # Default rendering for GET requests
    return render(request, 'registerLogin.html', context)



def success_page(request):
    return render(request, 'success.html')

#For Home Page
@login_required
@csrf_protect
def home_page(request):
    if request.method == 'POST' and request.POST.get('action') == 'applyforaloan':
            return redirect('formInfo')

    return render(request, 'homepage.html')

#For Settings Page
@csrf_protect
def settings_page(request):
    user = request.user
    context = {
        'profile_picture': user.pictures.url if user.pictures.url else 'https://via.placeholder.com/130',  # Default image if no profile picture
        'first_name': user.first_name,
        'last_name': user.last_name,
        'email': user.email,
        'phone': user.phone,
        'dob': user.dob,
    }  
    return render(request, 'settings.html', context)



#jwt token authentication

def get_tokens_for_user(user):
    """Generate JWT tokens for the given user."""
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

# User registration viewclass UserSignupView(APIView):
class UserSignupView(APIView):
    def post(self, request, *args, **kwargs):
        try:
            data = request.data
            required_fields = ['first_name', 'last_name', 'email', 'dob', 'phone', 'password', 'agree_terms']
            for field in required_fields:
                if field not in data:
                    return Response({"error": f"Missing required field: {field}"}, status=status.HTTP_400_BAD_REQUEST)

            user = User(    
                first_name=data['first_name'],
                last_name=data['last_name'],
                email=data['email'],
                dob=data['dob'],
                phone=data['phone'],
                password=make_password(data['password']),
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


def predictor(request):
    return render(request, 'form.html')
@login_required
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
            user=request.user,
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

        prediction = model.predict(input_data)
        
        #LoanStatus entry based on the prediction
        loan_status = LoanStatus(
            user=request.user,  # Linking the loan status to the logged-in user
            application=application,  # Link to the application
            status=prediction == 1,  # If approved, status is True
        )
        loan_status.save()

        # Convert the prediction into a human-readable format
        prediction_text = "Congratulations, your loan is approved!" if prediction == 1 else "Sorry, your loan application is rejected."

        # Render the result page
        return render(request, 'result.html', {'prediction': prediction_text})

    except Exception as e:
        return render(request, 'result.html', {'prediction': f"An error occurred: {str(e)}"})
    
def form_view(request):
    return render(request, 'form.html')


# mobile loan approval System
model1= load('./predictionModel/model.pkl')

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def loan_prediction(request):
    print("Request data:", request.data)
    
    try:
        # Get user by email 
        user = request.user

        # Extract and validate fields from request data
        
        education = request.data.get('education', 'Not Graduate').strip()
        self_employed = request.data.get('self_employed', 'No').strip()
        loan_amount = float(request.data.get('loan_amount', 0))
        loan_term = int(request.data.get('loan_term', 0))
        no_of_dependents = int(request.data.get('no_of_dependents', 0))
        cibil_score = int(request.data.get('credit_score', 0))
        annual_income = float(request.data.get('income_annum', 0))
        residential_asset = float(request.data.get('residential_assets_value', 0))
        commercial_asset = float(request.data.get('commercial_assets_value', 0))
        luxury_asset = float(request.data.get('luxury_assets_value', 0))
        bank_asset = float(request.data.get('bank_asset_value', 0))

        # Convert education and self_employed to boolean
        education_bool = education == 'Graduate'
        self_employed_bool = self_employed == 'Yes'

        # Prepare input DataFrame for the prediction model
        input_data = pd.DataFrame([[
            no_of_dependents,
            education_bool,
            self_employed_bool,
            annual_income,
            loan_amount,
            loan_term,
            cibil_score,
            residential_asset,
            commercial_asset,
            luxury_asset,
            bank_asset
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

        # Create the application instance and save it
        application = Application(
            user=user,
             loan_amount= loan_amount,
             loan_terms= loan_term,
             credit_score= cibil_score,
             no_of_dependents= no_of_dependents,
             education= education_bool,
             self_employed= self_employed_bool,
             annual_income= annual_income,
             residential_asset= residential_asset,
             commercial_asset= commercial_asset,
             luxury_asset= luxury_asset,
             bank_asset= bank_asset,
            submitted_time=pd.Timestamp.now()
        )
        application.save()

        # Prediction (ensure `model` is defined and imported)
        prediction = model1.predict_proba(input_data)[:, 1]
        threshold = 0.5
        loan_status = LoanStatus(
            user=request.user,
            application=application,
            status=prediction[0] > threshold  # If probability > threshold, approve
        )
        loan_status.save()

        prediction_text = (
            "Congratulations, your loan is approved!" if prediction[0] > threshold
            else "Sorry, your loan application is rejected."
        )
        return Response({'prediction': prediction_text}, status=status.HTTP_200_OK)

    except ValueError as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({'error': 'An error occurred. ' + str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    except User.DoesNotExist:
        return Response({'error': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)
    except ValueError as e:
        return Response({'error': f'Invalid data: {e}'}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({'error': f'An unexpected error occurred: {e}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
# moblie feedback

class FeedbackView(APIView):
    permission_classes = [IsAuthenticated]  # Require authentication

    def post(self, request):
        serializer = FeedbackSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save()  # Save feedback
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
# mobile user profile
class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]  # Add multipart parser for handling file uploads

    def get(self, request):
        # Retrieve the current user's profile data
        serializer = UserUpdateSerializer(request.user, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)

    def put(self, request):
        # Update the user's profile data, including the picture if provided
        serializer = UserUpdateSerializer(request.user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({"message": "Profile updated successfully."}, status=status.HTTP_200_OK)
    

# change Password   
class ChangePasswordView(APIView):
    permission_classes = [IsAuthenticated]
    

    def post(self, request, *args, **kwargs):
        user = request.user
        print(request.data) 
        serializer = ChangePasswordSerializer(data=request.data, context={'request': request})

        if serializer.is_valid():
            # Check if the old password matches
            if not user.check_password(serializer.validated_data['old_password']):
                return Response({"old_password": ["Wrong password."]}, status=status.HTTP_400_BAD_REQUEST)

            # Set the new password
            user.set_password(serializer.validated_data['new_password'])
            user.save()

            return Response({"message": "Password updated successfully."}, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
# loanhistorymobile  
class LoanHistoryView(APIView):
    permission_classes = [IsAuthenticated]  # Ensures only logged-in users can access

    def get(self, request):
        user = request.user        
        loan_statuses = LoanStatus.objects.filter(user=user)   # Fetch the user's loan history      
        serializer = LoanStatusSerializer(loan_statuses, many=True)  # Serialize the data
        return Response(serializer.data)