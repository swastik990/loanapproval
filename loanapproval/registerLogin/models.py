# from django.db import models
# from django.core.validators import RegexValidator
# from django.contrib.auth.hashers import make_password

# class User(models.Model):
#     id=models.AutoField(primary_key=True)
#     firstname = models.CharField(max_length=100)
#     lastname = models.CharField(max_length=100)
#     email = models.EmailField(unique=True)
#     dob = models.DateField()
#     phone_validator = RegexValidator(regex=r'^\d{10}$', message="Phone number must be a 10-digit integer.")
#     phone = models.CharField(validators=[phone_validator], max_length=10, unique=True)
#     password = models.CharField(max_length=100)
#     is_admin = models.BooleanField(default=False)
#     agree_terms = models.BooleanField(default=False)

#     def save(self, *args, **kwargs):
#         # Hash the password if it's new or has changed
#         if not self.pk or self.password != User.objects.get(pk=self.pk).password:
#             self.password = make_password(self.password)
#         super(User, self).save(*args, **kwargs)

#     def __str__(self):
#         return f"{self.email}, {self.phone}, {'Admin' if self.is_admin else 'User'}"


from django.db import models
from django.core.validators import RegexValidator
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.contrib.auth.hashers import make_password

class UserManager(BaseUserManager):
    def create_user(self, email, firstname, lastname, dob, phone, agree_terms, password=None, is_admin=False, **extra_fields):
        """
        Create and return a regular user.
        """
        if not email:
            raise ValueError('The Email field must be set')
        if not agree_terms:
            raise ValueError('The Terms and Conditions must be accepted')
        
        email = self.normalize_email(email)
        user = self.model(
            email=email,
            firstname=firstname,
            lastname=lastname,
            dob=dob,
            phone=phone,
            is_admin=is_admin,
            agree_terms=agree_terms,
            **extra_fields
        )
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, firstname, lastname, dob, phone, agree_terms, password=None, **extra_fields):
    # """
    # Create and return a superuser.
    # """
        extra_fields.setdefault('is_admin', True)

    # Create the superuser with the appropriate fields
        user = self.create_user(
            email=email,
            firstname=firstname,
            lastname=lastname,
            dob=dob,
            phone=phone,
            agree_terms=agree_terms,
            password=password,
            **extra_fields
        )

        # Ensure the user is marked as admin
        user.is_admin = True
        user.save(using=self._db)
        return user

    


class User(AbstractBaseUser):
    id = models.AutoField(primary_key=True)
    firstname = models.CharField(max_length=100)
    lastname = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    dob = models.DateField()
    phone_validator = RegexValidator(regex=r'^\d{10}$', message="Phone number must be a 10-digit integer.")
    phone = models.CharField(validators=[phone_validator], max_length=10, unique=True)
    password = models.CharField(max_length=100)
    is_admin = models.BooleanField(default=False)
    agree_terms = models.BooleanField(default=False)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['firstname', 'lastname', 'dob', 'phone', 'agree_terms']

    objects = UserManager()

    def save(self, *args, **kwargs):
        # Hash the password if it's new or has changed
        if self.pk and self.password and self.password != User.objects.get(pk=self.pk).password:
            self.password = make_password(self.password)
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.email}, {self.phone}, {'Admin' if self.is_admin else 'User'}"

    def has_perm(self, perm, obj=None):
        # Simplified permission check
        return self.is_admin

    def has_module_perms(self, app_label):
        # Simplified module permission check
        return True

    @property
    def is_staff(self):
        # All admins are staff
        return self.is_admin
