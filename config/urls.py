from django.contrib import admin
from django.urls import path
from appcore import views

urlpatterns = [
    path('admin/', admin.site.urls),

    path('login/', views.login_view, name='login'),
    path('cadastro/', views.cadastro, name='cadastro'),
    path('', views.home, name='home'),
    path('paciente/', views.paciente, name='paciente'),
    path('dentista/', views.dentista, name='dentista'),
    path('agendamento', views.agendamento, name='agendamento')
]