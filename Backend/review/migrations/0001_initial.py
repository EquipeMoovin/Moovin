# Generated by Django 5.2 on 2025-06-27 18:35

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Review',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('rating', models.PositiveSmallIntegerField()),
                ('comment', models.TextField(blank=True)),
                ('type', models.CharField(choices=[('TENANT', 'Tenant'), ('OWNER', 'Owner'), ('PROPERTY', 'Immobile')], max_length=20)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('object_id', models.PositiveIntegerField()),
            ],
            options={
                'ordering': ['-created_at'],
            },
        ),
    ]
