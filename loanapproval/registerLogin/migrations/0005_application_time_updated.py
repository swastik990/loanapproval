# Generated by Django 5.1.1 on 2024-11-26 09:29

import registerLogin.models
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('registerLogin', '0004_faq'),
    ]

    operations = [
        migrations.AddField(
            model_name='application',
            name='time_updated',
            field=models.CharField(default=registerLogin.models.Application.get_nepal_time, max_length=50),
        ),
    ]
