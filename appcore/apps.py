from django.apps import AppConfig


class AppcoreConfig(AppConfig):
    name = 'appcore'

# Iniciar Triggers
    def ready(self):
        import appcore.signals