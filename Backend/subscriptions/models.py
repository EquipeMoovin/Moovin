from django.db import models
from django.utils import timezone
from users.models import User
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType

class Plan(models.Model):
    name = models.TextField(max_length=100,null=False)
    price = models.DecimalField(max_digits=8, decimal_places=2)
    duration_days = models.IntegerField()



class SubscriptionManager(models.Manager):
    def activate_subscription(self, user: User):
        subscription = self.create(user=user, active=True)
        permission = Permission.objects.get(
            codename='has_active_subscription',
            content_type=ContentType.objects.get_for_model(Subscription)
        )
        user.user_permissions.add(permission)
        return subscription

    def deactivate_subscription(self, user: User):
        self.filter(user=user).update(active=False)
        permission = Permission.objects.get(
            codename='has_active_subscription',
            content_type=ContentType.objects.get_for_model(Subscription)
        )
        user.user_permissions.remove(permission)


class Subscription(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    plan = models.ForeignKey(Plan, on_delete=models.SET_NULL, null=True)
    start_date = models.DateField(auto_now_add=True)
    end_date = models.DateField()
    active = models.BooleanField(default=True)

    objects = SubscriptionManager()
    
    class Meta:
        permissions = [
            ("has_active_subscription", "User has an active subscription"),
        ]
    
    def is_valid(self):
        return self.active and self.end_date >= timezone.now().date()
