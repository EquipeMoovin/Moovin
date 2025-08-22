from django.db import models
from tenant.models import Tenant
from immobile.models import Immobile
from .consts import *


class Rental(models.Model):
    tenant = models.ForeignKey(Tenant,on_delete=models.CASCADE, blank=False,null=False)
    immobile = models.ForeignKey(Immobile,on_delete=models.CASCADE, blank=False,null=False)
    start_data = models.DateField(blank=False,null=False)
    end_data = models.DateField(blank=False,null=False)
    status =  models.CharField(max_length=15, choices=RENT_STATUS_CHOICES,default='active')
    value = models.DecimalField(max_digits=10, decimal_places=2)

