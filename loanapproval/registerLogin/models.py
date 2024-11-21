from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.db import models
from django.utils import timezone
import pytz
from django.contrib.auth import get_user_model

# function to show nepali time
NEPAL_TZ = pytz.timezone('Asia/Kathmandu')

class UserManager(BaseUserManager):
    def create_user(self, email, first_name, last_name, phone, dob, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        email = self.normalize_email(email)
        
        # Extract the user_type from extra_fields, default to NORMAL_USER if not provided
        user_type = extra_fields.pop('user_type', User.NORMAL_USER)
        
        user = self.model(
            email=email,
            first_name=first_name,
            last_name=last_name,
            phone=phone,
            dob=dob,
            user_type=user_type,  # Set user_type here
            is_staff=extra_fields.get('is_staff', False),
            is_superuser=extra_fields.get('is_superuser', False)
        )
        
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, first_name, last_name, phone, dob, password=None, **extra_fields):
        extra_fields.setdefault('user_type', User.ADMIN_SUPERUSER)  # Ensure user_type is set to Admin/Superuser
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        
        return self.create_user(email, first_name, last_name, phone, dob, password, **extra_fields)

class User(AbstractBaseUser):

    NORMAL_USER = 0
    ADMIN_SUPERUSER = 1
    STAFF = 2

    USER_TYPE_CHOICES = [
        (NORMAL_USER, 'Normal User'),
        (ADMIN_SUPERUSER, 'Admin/Superuser'),
        (STAFF, 'Staff'),
    ]

    user_id = models.AutoField(primary_key=True)
    first_name = models.CharField(max_length=255)
    last_name = models.CharField(max_length=255)
    phone = models.CharField(max_length=15)
    dob = models.DateField()
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)
    pictures = models.ImageField(upload_to='uploads/')
    user_type = models.IntegerField(choices=USER_TYPE_CHOICES, default=NORMAL_USER)
    agree_terms = models.BooleanField(default=True)
    # nepali time function call gareko
    def get_nepal_time():
    # Get current datetime in Nepal timezone
        nepal_time = timezone.now().astimezone(NEPAL_TZ)
    # Format date, day, and time as requested
        return nepal_time.strftime("%Y-%m-%d, %A %H:%M:%S")

    check_in_time = models.CharField(max_length=50, default=get_nepal_time)


    # New fields required by Django's authentication system
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)

    # The field used to log in
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name', 'last_name', 'phone', 'dob']

    # Link the custom manager
    objects = UserManager()

    def __str__(self):
        return self.email

    # Required for Django admin access
    def has_perm(self, perm, obj=None):
        """ Return True if the user has the specified permission """
        return self.is_superuser

    def has_module_perms(self, app_label):
        """ Return True if the user has permissions to view the app `app_label` """
        return self.is_superuser


class Navbar(models.Model):
    nav_id = models.AutoField(primary_key=True)
    title = models.CharField(max_length=255)
    details = models.TextField()

class Feedback(models.Model):
    fb_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(get_user_model(), to_field='user_id', on_delete=models.CASCADE)
    feedback = models.TextField()
    rating = models.DecimalField(max_digits=2, decimal_places=1, null=True, blank=True)  # Allow null and blank
    feedback_time = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.email} - {self.feedback[:30]} ({self.rating})"


class Profile(models.Model):
    profile_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    profile_picture = models.ImageField(upload_to='profiles/')
    created_at = models.DateTimeField(auto_now_add=True)

class Application(models.Model):
    application_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(get_user_model(), to_field='user_id', on_delete=models.CASCADE)
    loan_amount = models.DecimalField(max_digits=10, decimal_places=2)
    loan_terms = models.IntegerField()
    credit_score = models.IntegerField()
    no_of_dependents = models.IntegerField()
    education = models.BooleanField(default=False)
    self_employed = models.BooleanField(default=False)
    annual_income = models.DecimalField(max_digits=12, decimal_places=2)
    residential_asset = models.DecimalField(max_digits=12, decimal_places=2)
    luxury_asset = models.DecimalField(max_digits=12, decimal_places=2)
    bank_asset = models.DecimalField(max_digits=12, decimal_places=2)
    commercial_asset = models.DecimalField(max_digits=12, decimal_places=2)
    citizenship_no = models.CharField(max_length=255)
    zip_code = models.CharField(max_length=10)
    submitted_time = models.DateTimeField(auto_now_add=True)
    state = models.CharField(max_length=255)
    street = models.CharField(max_length=255)

class LoanStatus(models.Model):
    status_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    application = models.ForeignKey(Application, on_delete=models.CASCADE)
    status = models.BooleanField(default=False)
    def get_nepal_time():
        nepal_time = timezone.now().astimezone(NEPAL_TZ)
        return nepal_time.strftime("%Y-%m-%d, %A %H:%M:%S")
    time_updated = models.CharField(max_length=50, default=get_nepal_time)

class AboutUs(models.Model):
    about_id = models.AutoField(primary_key=True)
    title = models.CharField(max_length=255)
    details = models.TextField()
    pictures = models.ImageField(upload_to='about/')

class TermsAndConditions(models.Model):
    terms_id = models.AutoField(primary_key=True)
    title = models.CharField(max_length=255)
    details = models.TextField()

class CMSLog(models.Model):
    cms_id = models.AutoField(primary_key=True)
    table = models.CharField(max_length=255)
    value = models.CharField(max_length=255)
    old_data = models.TextField()
    updated_at = models.DateTimeField(auto_now=True)
    updated_by = models.CharField(max_length=255)

class FAQ(models.Model):
    faq_id = models.AutoField(primary_key=True)  # Auto-incrementing primary key
    question = models.TextField()               # Field to store the FAQ question
    answer = models.TextField()                 # Field to store the FAQ answer
