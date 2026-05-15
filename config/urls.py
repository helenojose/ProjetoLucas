
from django.contrib import admin
from django.urls import path

from appcore.views import login_view
from appcore.views import cadastro
from appcore.views import home

urlpatterns = [
    path('admin/', admin.site.urls),

    path('login/', login_view, name='login'),
    path('cadastro/', cadastro, name='cadastro'),
    path('', home, name='home'),
]