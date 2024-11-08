from django.urls import path
from django.contrib.auth.views import LogoutView
from . import views
from .views import form_view ,  UserLoginView,UserSignupView




urlpatterns = [
  #web routes
    path('register/', views.user_action, name='user_action'),
    path('success/', views.success_page, name='success'),
    path('form/', views.predictor, name = 'formInfo'),
    path('formInfo', views.formInfo, name = 'formInfo'),

    path('logout/', LogoutView.as_view(next_page='register_login'), name='logout'),
   
    # path('form/', form_view, name='form'), 


    #mobile routes
    path('signup/', UserSignupView.as_view(), name='signup'),
    path('login/', UserLoginView.as_view(), name='login'),
]

