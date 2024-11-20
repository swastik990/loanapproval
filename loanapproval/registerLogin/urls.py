from django.urls import path
from django.contrib.auth.views import LogoutView
from . import views
from .views import form_view ,  UserLoginView,UserSignupView,loan_prediction,UserProfileView,FeedbackView, ChangePasswordView,LoanHistoryView,AboutUsView, FAQView
from django.conf import settings
from django.conf.urls.static import static


urlpatterns = [
  #web routes
    path('landing/', views.landing_page, name='landing_page'),
    path('home/', views.home_page, name='home'),
    path('register/', views.user_action, name='user_action'),
    path('success/', views.success_page, name='success'),
    path('form/', views.predictor, name = 'form'),
    path('settings/', views.settings_page, name='settings'),
    path('formInfo/', views.formInfo, name = 'formInfo'),

    path('logout/', LogoutView.as_view(next_page='register_login'), name='logout'),
    # path('form/', form_view, name='form'), 


    #mobile routes
    path('signup/', UserSignupView.as_view(), name='signup'),
    path('login/', UserLoginView.as_view(), name='login'),
    path('api/loan-prediction/', views.loan_prediction, name='loan_prediction'),
    path('feedback/', FeedbackView.as_view(), name='feedback'),
    path('profile/', UserProfileView.as_view(), name='user-profile'),
    path('change-password/', ChangePasswordView.as_view(), name='change-password'),
    path('api/loan-history/', LoanHistoryView.as_view(), name='loan-history'),
    path('about-us/', AboutUsView.as_view(), name='about_us'),
    path('faqs/', FAQView.as_view(), name='faq-list')
]+ static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

