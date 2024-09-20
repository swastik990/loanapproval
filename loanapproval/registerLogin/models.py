from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin

class UserManager(BaseUserManager):
    def create_user(self, email, first_name, last_name, phone, dob, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, first_name=first_name, last_name=last_name, phone=phone, dob=dob)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, first_name, last_name, phone, dob, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('check_in_time', '09:00:00') 
        return self.create_user(email, first_name, last_name, phone, dob, password, **extra_fields)

class User(AbstractBaseUser, PermissionsMixin):
    user_id = models.AutoField(primary_key=True)
    first_name = models.CharField(max_length=255)
    last_name = models.CharField(max_length=255)
    phone = models.CharField(max_length=15)
    dob = models.DateField()
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)
    pictures = models.ImageField(upload_to='uploads/')
    user_type = models.IntegerField(default=0)  # 0, 1, 2, etc. for different user types
    agree_terms = models.BooleanField(default=False)
    check_in_time = models.TimeField(default="12:00:00")

    # New fields required by Django's authentication system
    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)

    # The field used to log in
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name', 'last_name', 'phone', 'dob']

    # Link the custom manager
    objects = UserManager()

    def __str__(self):
        return self.email

class Navbar(models.Model):
    nav_id = models.AutoField(primary_key=True)
    title = models.CharField(max_length=255)
    details = models.TextField()

class Feedback(models.Model):
    fb_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    feedback = models.TextField()
    feedback_time = models.DateTimeField(auto_now_add=True)

class Profile(models.Model):
    profile_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    profile_picture = models.ImageField(upload_to='profiles/')
    created_at = models.DateTimeField(auto_now_add=True)

class Application(models.Model):
    application_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
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
    time_updated = models.TimeField(auto_now=True)

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
