from django.contrib import admin
from .models import UsuarioSistema, Especialidade, Dentista, Paciente, Agendamento

# Registra os modelos para aparecerem na web
admin.site.register(UsuarioSistema)
admin.site.register(Especialidade)
admin.site.register(Dentista)
admin.site.register(Paciente)
admin.site.register(Agendamento)