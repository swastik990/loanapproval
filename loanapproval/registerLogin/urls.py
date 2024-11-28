from django.urls import path
from django.contrib.auth.views import LogoutView
from . import views
from .views import form_view ,  UserLoginView,UserSignupView,loan_prediction,UserProfileView,FeedbackView, ChangePasswordView,LoanHistoryView,AboutUsView, FAQView, TermsAndConditionsView
from django.conf import settings
from django.conf.urls.static import static


urlpatterns = [
  #web routes
    path('', views.landing_page, name='landing_page'),
    path('register/', views.user_action, name='user_action'),
    path('home/', views.home_page, name='home'),
    path('aboutus/', views.aboutus_page, name = 'aboutus'),
    path('feedback/', views.feedback_page, name = 'feedback'),
    path('settings/', views.settings_page, name='settings'),
    path('form/', views.predictor, name = 'form'),
    path('user/', views.user_page, name = 'user'),
    path('history/', views.history_page, name = 'history'),
    path('formInfo/', views.formInfo, name = 'formInfo'),
    path('download_pdf/<int:application_id>/', views.download_pdf, name='download_pdf'),


    path('logout/', views.logout_view, name='logout'),
    # path('form/', form_view, name='form'), 
    
    # path('dashboard/', self.admin_view(self.dashboard_view), name='dashboard'),



    #mobile routes
    path('signup/', UserSignupView.as_view(), name='signup'),
    path('login/', UserLoginView.as_view(), name='login'),
    path('api/loan-prediction/', views.loan_prediction, name='loan_prediction'),
    path('feed_back/', FeedbackView.as_view(), name='feed_back'),
    path('profile/', UserProfileView.as_view(), name='user-profile'),
    path('change-password/', ChangePasswordView.as_view(), name='change-password'),
    path('api/loan-history/', LoanHistoryView.as_view(), name='loan-history'),
    path('about-us/', AboutUsView.as_view(), name='about_us'),
    path('terms/', TermsAndConditionsView.as_view(), name='terms-list'),
    path('faqs/', FAQView.as_view(), name='faq-list')
]+ static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

