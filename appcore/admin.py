from django.contrib import admin
from .models import Paciente, Dentista, Consulta, Procedimento, UsuarioSistema, Disponibilidade, Endereco

# Register your models here.

# Registo de todos os modelos para aparecerem no painel
admin.site.register(Paciente)
admin.site.register(Dentista)
admin.site.register(Consulta)
admin.site.register(Procedimento)
admin.site.register(UsuarioSistema)
admin.site.register(Disponibilidade)
admin.site.register(Endereco)
