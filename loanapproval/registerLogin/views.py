from venv import logger
from django.shortcuts import render, redirect
from rest_framework import status
from django.views.decorators.csrf import csrf_protect
from joblib import load
import numpy as np
import pandas as pd
from rest_framework.response import Response
from .models import *
from rest_framework.decorators import api_view
from django.contrib.auth import authenticate, login as auth_login
from django.contrib.auth.hashers import make_password
from django.http import JsonResponse
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import *
from rest_framework.views import APIView
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import authenticate
from django.contrib.auth import login
from django.contrib.auth import logout
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
from rest_framework.parsers import MultiPartParser, FormParser
from django.contrib.auth.hashers import check_password
from django.contrib.auth import update_session_auth_hash


#for password validation
from django.core.exceptions import ValidationError
import re

from .models import CMSLog
from django.contrib.auth.models import User

def log_to_cms(table, value, old_data, updated_by):
    """
    Logs changes to the CMSLog table.
    :param table: The table where the change occurred.
    :param value: The specific value/record modified.
    :param old_data: A string representation of the old data.
    :param updated_by: The user responsible for the update.
    """
    CMSLog.objects.create(
        table=table,
        value=value,
        old_data=old_data,
        updated_by=updated_by
    )

from django.dispatch import receiver
from django.contrib.auth.signals import user_logged_in
@receiver(user_logged_in)
def log_login(sender, request, user, **kwargs):
    log_to_cms(
        table='User',
        value=f"User ID: {user.user_id}",
        old_data='Logged In',
        updated_by=user.email
    )

def validate_password_strength(password):
    # Ensure the password contains at least one uppercase letter, one lowercase letter, and one number
    if not re.search(r'[A-Z]', password):  # Uppercase letter
        raise ValidationError("Password must contain at least one uppercase letter.")
    if not re.search(r'[a-z]', password):  # Lowercase letter
        raise ValidationError("Password must contain at least one lowercase letter.")
    if not re.search(r'[0-9]', password):  # Number
        raise ValidationError("Password must contain at least one number.")
    if len(password) < 8:
        raise ValidationError("Password must be at least 8 characters long.")
    return password


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
        'signup_messages_success': [],
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
                
                # make password strong
                try:
                    validate_password_strength(password)
                except ValidationError as e:
                    context['signup_messages'].append(str(e))
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
                    check_in_time=pd.Timestamp.now()  # Store current time as submission time
                )
                user.save()
                context['signup_messages_success'].append("Account created successfully! Now Sign In.")
                return render(request, 'registerLogin.html', context)


            except Exception as e:
                print(f"Error during signup: {e}")
                context['signup_messages'].append("An error occurred. Please try again.")
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
                                # Optional: Generate JWT tokens for API compatibility
                refresh = RefreshToken.for_user(user)
                messages.success(request, "You've Successfully Logged In!")
                return redirect('home')  # Redirect to the home page
            else:
        # If authentication fails, show a generic error message
                context['signin_messages'].append("Invalid email or password.")
                return render(request, 'registerLogin.html', context)

    # Default rendering for GET requests
    return render(request, 'registerLogin.html', context)

def logout_view(request):
    logout(request)
    return redirect('landing_page')

def aboutus_page(request):
    about_us = AboutUs.objects.first()  # Assuming you only have one "About Us" entry
    return render(request, 'aboutus.html', {'about_us': about_us})

@login_required
def feedback_page(request):
    if request.method == 'POST':
        
        rating = request.POST.get('rating')
        feedback = request.POST.get('feedback')
        
        if rating and feedback:
            feedback_instance = Feedback(user=request.user, rating=rating, feedback=feedback)
            feedback_instance.save()
            messages.success(request, 'Thank you for your feedback!')
            return redirect('feedback')
        else:
            messages.error(request, 'Please provide both rating and feedback.')
        
    return render(request, 'feedback.html')


#For Home Page
@login_required
@csrf_protect
def home_page(request):
    if request.method == 'POST':
        faq_id = request.POST.get('faq_id')
        question = request.POST.get('question')
        answer = request.POST.get('answer')
        

        # If faq_id is provided, update an existing FAQ; otherwise, create a new FAQ
        if faq_id:
            faq = get_object_or_404(FAQ, faq_id=faq_id)
            faq.question = question
            faq.answer = answer
            faq.save()
        else:
            FAQ.objects.create(question=question, answer=answer)

        # Redirect to the homepage after saving
        return redirect('home')

    # Fetch all FAQs from the database
    faqs = FAQ.objects.all()    

    return render(request, 'homepage.html', {'faqs': faqs})


#for user page
from django.shortcuts import get_object_or_404
from django.http import HttpResponse
from .models import Application, LoanStatus
from xhtml2pdf import pisa
from io import BytesIO
@login_required
@csrf_protect    
def user_page(request):
    # Get all applications related to the logged-in user
    applications = Application.objects.filter(user=request.user)

    application = None  # Initialize as None in case no application is selected
    loan_status = None  # Initialize as None to handle cases where no loan status is found
    status = 'Pending'  # Default status if no loan status is found or set

    # If application_id is passed via GET, fetch the corresponding application
    application_id = request.GET.get('application_id', None)

    if application_id:
        try:
            application = Application.objects.get(application_id=application_id, user=request.user)
            loan_status = LoanStatus.objects.filter(application=application).first()
        except Application.DoesNotExist:
            application = None

    # Determine the status
    if loan_status:
        if loan_status.status:
            status = 'Approved'
        else:
            status = 'Rejected'

    context = {
        'applications': applications,
        'application': application,
        'application_id': application_id,
        'loan_status': status,  # Pass the determined status to the template
    }

    return render(request, 'userdetails.html', context)



def download_pdf(request, application_id):
    # Fetch the application details
    application = get_object_or_404(Application, application_id=application_id)
    user = request.user
    
    loan_status = LoanStatus.objects.filter(application=application).first()
    if loan_status:
        if loan_status.status:
            status = 'Approved'
        else:
            status = 'Rejected'
    else:
        status = 'Pending'
    # HTML content for the PDF with added company name and watermark
    html_content = f"""
    <html>
    <head>
        <style>
            h1 {{
                text-align: center;
                color: #0066cc;  /* Company Blue */
                font-size: 18px;
                text-decoration: underline;
            }}
            .watermark {{
                text-align: center;
                font-size: 40px;
                color: rgba(0, 102, 204, 0.1);  /* Light blue for watermark */
                font-weight: bold;
            }}
            .section {{
                margin: 15px 0;
                padding: 10px;
                background-color: #ffffff;
                border-radius: 8px;
                box-shadow: 0px 0px 5px rgba(0, 0, 0, 0.1);
            }}
            .section p {{
                font-size: 15px;
                margin: 3px 0;
            }}
        </style>
    </head>
    <body>
        <div class="watermark">Loan Approval System</div>
            <h1>Loan Application Details</h1>
        <div class="content">
            <div class="section">
                <p><strong>User Name:</strong> {user.first_name} {user.last_name}</p>
                <p><strong>User ID:</strong> {user.user_id}</p>
                <p><strong>Application ID:</strong> {application.application_id}</p>
                <p><strong>Loan Amount:</strong> {application.loan_amount}</p>
                <p><strong>Loan Terms:</strong> {application.loan_terms} Year</p>
                <p><strong>Credit Score:</strong> {application.credit_score}</p>
                <p><strong>Number of Dependents:</strong> {application.no_of_dependents}</p>
                <p><strong>Education:</strong> {'Yes' if application.education else 'No'}</p>
                <p><strong>Self Employed:</strong> {'Yes' if application.self_employed else 'No'}</p>
                <p><strong>Annual Income:</strong> {application.annual_income}</p>
                <p><strong>Residential Asset:</strong> {application.residential_asset}</p>
                <p><strong>Luxury Asset:</strong> {application.luxury_asset}</p>
                <p><strong>Bank Asset:</strong> {application.bank_asset}</p>
                <p><strong>Commercial Asset:</strong> {application.commercial_asset}</p>
                <p><strong>Citizenship No:</strong> {application.citizenship_no}</p>
                <p><strong>Zip Code:</strong> {application.zip_code}</p>
                <p><strong>State:</strong> {application.state}</p>
                <p><strong>Street:</strong> {application.street}</p>
                <p><strong>Submitted Time:</strong> {application.submitted_time}</p>
                <p><strong>Status:</strong> {status}</p>
            </div>
        </div>
    </body>
    </html>
    """

    # Generate PDF from the HTML content
    response = HttpResponse(content_type='application/pdf')
    response['Content-Disposition'] = f'attachment; filename="application_{application_id}.pdf"'

    # Use xhtml2pdf to convert HTML to PDF
    pisa_status = pisa.CreatePDF(html_content, dest=response)
    
    # If there were any errors in generating the PDF, show an error
    if pisa_status.err:
        return HttpResponse('Error generating PDF', status=500)

    return response



#for history page
from django.db.models import F

@login_required
@csrf_protect
def history_page(request):
    # Get the logged-in user's ID
    user_id = request.user.user_id

    # Retrieve loan history with the related status field
    loan_history = (
        Application.objects.filter(user_id=user_id)
        .select_related('loanstatus')  # Optimize related model queries
        .annotate(
            loan_status=F('loanstatus__status')  # Fetch the status from LoanStatus
        )
        .values(
            'application_id',  # Application ID
            'loan_terms',      # Loan Term
            'loan_amount',     # Loan Amount
            'loan_status',     # Loan Status from LoanStatus model
        )
        .order_by('-submitted_time')  # Sort by submission time
    )

    # Pass the data to the template
    context = {'loan_history': loan_history}
    return render(request,'history.html', context)

#For Settings Page
@login_required
@csrf_protect
def settings_page(request):
    # Display user's information in the settings page
    user = request.user
    context = {
        'profile_picture': user.pictures.url if user.pictures else None,  # Default image if no profile picture
        'first_name': user.first_name,
        'last_name': user.last_name,
        'email': user.email,
        'phone': user.phone,
        'dob': user.dob,
    }

    old_data = {
            "first_name": user.first_name,
            "last_name": user.last_name,
            "email": user.email,
            "phone": user.phone,
        }
    # Handle form submission for updating user information
    if request.method == "POST":
        if 'update' in request.POST:

            # Update fields individually if provided
            first_name = request.POST.get('first_name')
            if first_name:
                user.first_name = first_name

            last_name = request.POST.get('last_name')
            if last_name:
                user.last_name = last_name

            email = request.POST.get('email')
            if email:
                user.email = email

            phone = request.POST.get('phone')
            if phone:
                user.phone = phone

            dob = request.POST.get('dob')
            if dob:
                user.dob = dob

            # Handle profile picture upload
            if 'pictures' in request.FILES:
                user.pictures = request.FILES['pictures']

            # Save the updated user object
            user.save()

            log_to_cms(
                table="User",
                value=f"User ID: {user.user_id}",
                old_data=str(old_data),
                updated_by=user.email
            )
            # Add a success message
            messages.success(request, "Account information has been updated successfully.")

            return redirect('settings')

        elif 'change' in request.POST:
            current_password = request.POST.get('currentPassword')
            new_password = request.POST.get('newPassword')
            confirm_password = request.POST.get('confirmPassword')

            # Validate current password
            if not check_password(current_password, request.user.password):
                messages.error(request, "Current password is incorrect.")
                return redirect('settings')

            # Validate new password and confirmation
            if new_password != confirm_password:
                messages.error(request, "Passwords do not match.")
                return redirect('settings')

            # Update the password
            user.set_password(new_password)
            user.save()

            # Update the session to avoid logout
            update_session_auth_hash(request, user)
            messages.success(request, "Your password has been updated successfully.")
            return redirect('settings')

    # Render the settings page with the updated context
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
                log_to_cms(
                table='User',
                value=f"User ID: {user.user_id}",
                old_data='Logged In',
                updated_by=user.email
    )
                # Create JWT tokens
                refresh = RefreshToken.for_user(user)
                return Response({
                    'refresh': str(refresh),
                    'access': str(refresh.access_token),
                    'msg': 'Login successful'
                }, status=status.HTTP_200_OK)
            else:
                # Log failed login attempt to CMSLog
                CMSLog.objects.create(
                    table='User',
                    value='Login Attempt',
                    old_data=f'Failed login attempt for {email}',
                    updated_by=email
                )
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
        
                # Log the form submission to CMSLog
        old_data = "Form submission: New application created"
        log_to_cms(
            table="Application",
            value=f"Application ID: {application.application_id}",
            old_data=str(old_data),
            updated_by=request.user.email
        )

        prediction = model.predict(input_data)
        
        #LoanStatus entry based on the prediction
        loan_status = LoanStatus(
            user=request.user,  # Linking the loan status to the logged-in user
            application=application,  # Link to the application
            status=prediction == 1,  # If approved, status is True
        )
        loan_status.save()
        
        loan_status_data = f"Loan status updated: {'Approved' if prediction == 1 else 'Rejected'}"
        log_to_cms(
            table="LoanStatus",
            value=f"LoanStatus ID: {loan_status.status_id}",
            old_data=loan_status_data,
            updated_by=request.user.email
        )

        # Convert the prediction into a human-readable format
        prediction_text = "Congratulations, your loan is approved!" if prediction == 1 else "Sorry, your loan application is rejected."

        # Render the result page
        return render(request, 'result.html', {'prediction': prediction_text})

    except Exception as e:
        error_data = f"Error during form submission: {str(e)}"
        log_to_cms(
            table="Error",
            value="Form Submission",
            old_data=error_data,
            updated_by=request.user.email
        )
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

        old_data = "Form submission: New application created"
        log_to_cms(
            table="Application",
            value=f"Application ID: {application.application_id}",
            old_data=str(old_data),
            updated_by=request.user.email
        )

        # Prediction (ensure `model` is defined and imported)
        prediction = model1.predict_proba(input_data)[:, 1]
        threshold = 0.5
        loan_status = LoanStatus(
            user=request.user,
            application=application,
            status=prediction[0] > threshold  # If probability > threshold, approve
        )
        loan_status.save()
        loan_status_data = f"Loan status updated: {'Approved' if prediction == 1 else 'Rejected'}"
        log_to_cms(
            table="LoanStatus",
            value=f"LoanStatus ID: {loan_status.status_id}",
            old_data=loan_status_data,
            updated_by=request.user.email
        )

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

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from django.utils import timezone
from .models import Feedback, CMSLog
from .serializers import FeedbackSerializer

class FeedbackView(APIView):
    permission_classes = [IsAuthenticated]  # Require authentication

    def post(self, request):
        # Retrieve rating and feedback from request data
        rating = request.data.get('rating')
        feedback_content = request.data.get('feedback')

        if rating and feedback_content:
            # Save feedback
            feedback_instance = Feedback.objects.create(
                user=request.user,
                rating=rating,
                feedback=feedback_content
            )

            # Log the feedback submission in CMSLog
            CMSLog.objects.create(
                table="Feedback",
                value=f"Feedback ID: {feedback_instance.fb_id}", 
                old_data=f"Rating: {rating}, Feedback: {feedback_content}",  
                updated_by=request.user.email,  # Log user email
                updated_at=timezone.now(),  # Timestamp when feedback was submitted
            )

            # Return success response
            return Response(
                {"message": "Thank you for your feedback!", "feedback_id": feedback_instance.fb_id},
                status=status.HTTP_201_CREATED
            )
        else:
            # Return error response if rating or feedback is missing
            return Response(
                {"error": "Please provide both rating and feedback."},
                status=status.HTTP_400_BAD_REQUEST
            )

    
# mobile user profile

class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]  # Allow file uploads

    def get(self, request):
        """
        Retrieve the current user's profile data.
        """
        serializer = UserUpdateSerializer(request.user, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)

    def put(self, request):
        """
        Update the user's profile data, including the picture if provided.
        """
        user = request.user
        serializer = UserUpdateSerializer(user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        old_data = {field: getattr(user, field) for field in serializer.fields if hasattr(user, field)}

        serializer.save()

        
        updated_data = serializer.validated_data
        CMSLog.objects.create(
            table='User',
            value=f'User ID: {user.user_id}',
            old_data=f"Old Data: {old_data}",
            updated_at=user.user_id,  
            updated_by=user.email  
        )

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
    
# AboutUSmobile 
class AboutUsView(APIView):
    def get(self, request, *args, **kwargs):
        try:
            about_us_objects = AboutUs.objects.all()
            if not about_us_objects.exists():
                return Response(
                    {"message": "No About Us data available."},
                    status=status.HTTP_400_BAD_REQUEST
                )
            serializer = AboutUsSerializer(about_us_objects, many=True)
            return Response(
                {"message": "Data fetched successfully!", "data": serializer.data},
                status=status.HTTP_200_OK
            )
        except Exception as e:
            return Response(
                {"message": f"An error occurred: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
        
#mobile frequently ask question
class FAQView(APIView):
    def get(self, request):
        faqs = FAQ.objects.all()  # Fetch all FAQs
        serializer = FAQSerializer(faqs, many=True)
        return Response(serializer.data)

#mobile terms api    
class TermsAndConditionsView(APIView):
    def get(self, request):
        terms = TermsAndConditions.objects.all()  # Fetch all terms and conditions
        serializer = TermsAndConditionsSerializer(terms, many=True)
        return Response(serializer.data)