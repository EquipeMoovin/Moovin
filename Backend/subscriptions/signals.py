from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Subscription
from django.contrib.auth.models import Permission


@receiver(post_save, sender=Subscription)
def status_changes(sender, instance, created, **kwargs):
    user = instance.user
    permission = Permission.objects.get(codename='has_active_subscription')

    if instance.active:
        user.user_permissions.add(permission)
    else:
        user.user_permissions.remove(permission)


