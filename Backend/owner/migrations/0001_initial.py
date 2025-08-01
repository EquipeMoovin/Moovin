# Generated by Django 5.2 on 2025-06-27 18:35

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Owner',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('phone', models.CharField(max_length=20, null=True)),
                ('city', models.CharField(max_length=100, null=True)),
                ('state', models.CharField(max_length=100, null=True)),
                ('about_me', models.TextField(null=True)),
                ('revenue_generated', models.DecimalField(decimal_places=2, default=0.0, max_digits=10)),
                ('rented_properties', models.PositiveIntegerField(default=0)),
                ('rated_by_tenants', models.PositiveIntegerField(default=0)),
                ('recommended_by_tenants', models.PositiveIntegerField(default=0)),
                ('fast_responder', models.BooleanField(default=False)),
            ],
        ),
        migrations.CreateModel(
            name='OwnerPhoto',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('image_blob', models.BinaryField(default=bytes)),
                ('content_type', models.CharField(default='', max_length=50)),
                ('uploaded_at', models.DateTimeField(auto_now_add=True)),
            ],
        ),
    ]
