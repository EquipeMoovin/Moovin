from django.apps import AppConfig


class ImoveisConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'immobile'

    def ready(self):
            import immobile.signals