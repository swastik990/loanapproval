from django.contrib import admin

from django.contrib import admin
from .models import *

@admin.register(Navbar)
class NavbarAdmin(admin.ModelAdmin):
    list_display = ('nav_id', 'title', 'details')
    search_fields = ('title', 'details')

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('user_id', 'first_name', 'last_name', 'phone', 'dob', 'email', 'user_type', 'agree_terms', 'check_in_time')
    search_fields = ('first_name', 'last_name', 'email', 'phone')
    list_filter = ('user_type', 'agree_terms')

    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'first_name', 'last_name', 'dob', 'phone', 'password', 'user_type', 'is_staff', 'is_superuser', 'agree_terms'),
        }),
    )


@admin.register(Feedback)
class FeedbackAdmin(admin.ModelAdmin):
    list_display = ('fb_id', 'user', 'feedback', 'feedback_time')
    search_fields = ('feedback',)
    list_filter = ('user', 'feedback_time')

@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ('profile_id', 'user', 'profile_picture', 'created_at')
    search_fields = ('user__email',)
    list_filter = ('created_at',)

@admin.register(Application)
class ApplicationAdmin(admin.ModelAdmin):
    list_display = ('application_id', 'user', 'user_id', 'loan_amount', 'loan_terms', 'credit_score', 'no_of_dependents', 'education', 'self_employed', 'annual_income', 'residential_asset', 'luxury_asset', 'bank_asset', 'commercial_asset', 'citizenship_no', 'zip_code', 'submitted_time', 'state', 'street')
    search_fields = ('user__email', 'citizenship_no', 'state', 'street')
    list_filter = ('submitted_time', 'education', 'self_employed')

@admin.register(LoanStatus)
class LoanStatusAdmin(admin.ModelAdmin):
    list_display = ('status_id', 'user', 'user_id', 'application', 'status', 'time_updated')
    search_fields = ('user__email', 'application__application_id')
    list_filter = ('status', 'time_updated')

@admin.register(AboutUs)
class AboutUsAdmin(admin.ModelAdmin):
    list_display = ('about_id', 'title', 'details', 'pictures')
    search_fields = ('title', 'details')

@admin.register(TermsAndConditions)
class TermsAndConditionsAdmin(admin.ModelAdmin):
    list_display = ('terms_id', 'title', 'details')
    search_fields = ('title', 'details')

@admin.register(CMSLog)
class CMSLogAdmin(admin.ModelAdmin):
    list_display = ('cms_id', 'table', 'value', 'old_data', 'updated_at', 'updated_by')
    search_fields = ('table', 'value', 'old_data', 'updated_by')
    list_filter = ('updated_at',)
