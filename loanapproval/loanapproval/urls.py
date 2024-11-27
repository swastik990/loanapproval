
from django.conf.urls.i18n import i18n_patterns
from django.contrib import admin
from django.urls import path, include
from registerLogin import views
from registerLogin import admin as admin1

urlpatterns = [
    path("i18n/", include("django.conf.urls.i18n")),

    path('admin/', admin.site.urls),
    # path('admin/loan-dashboard/', admin1.loan_dashboard, name='loan_dashboard'), 

    # path('admin/dashboard/', views.dashboard_stats, name='dashboard_stats'),

    path('admin_tools_stats/', include('admin_tools_stats.urls')),
    # path('', include('admin_adminlte3.urls')),   

    path('', include('registerLogin.urls')),  

]

urlpatterns +=  i18n_patterns (
    path('admin/', admin.site.urls),
)