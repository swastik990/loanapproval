from django.contrib import admin
from registerLogin.models import User
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

class UserModelAdmin(BaseUserAdmin):
    # The fields to be used in displaying the User model.
    list_display = ('id', 'email', 'firstname', 'lastname', 'phone','password', 'is_admin')
    list_filter = ('is_admin',)
    
    # Fieldsets define the layout of the admin interface.
    fieldsets = (
        ('User Credentials', {'fields': ('email', 'password')}),
        ('Personal Info', {'fields': ('firstname', 'lastname', 'dob', 'phone')}),
        ('Permissions', {'fields': ('is_admin', 'agree_terms')}),
    )
    
    # Add fieldsets is used when creating a new user.
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'firstname', 'lastname', 'phone', 'password1',  'agree_terms'),
        }),
    )
    
    search_fields = ('email', 'firstname', 'lastname', 'phone')
    ordering = ('email', 'id')
    filter_horizontal = ()

# Register the new UserModelAdmin
admin.site.register(User, UserModelAdmin)
