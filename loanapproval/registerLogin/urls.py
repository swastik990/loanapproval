from django.urls import path
from django.contrib.auth.views import LogoutView
from . import views


urlpatterns = [
    path('register/', views.user_action, name='user_action'),
    path('success/', views.success_page, name='success'),
    path('form/', views.predictor, name = 'formInfo'),
    path('formInfo', views.formInfo, name = 'formInfo'),

]
