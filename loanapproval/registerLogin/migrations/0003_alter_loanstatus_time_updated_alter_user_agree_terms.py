# Generated by Django 5.0.7 on 2024-11-20 06:50

import registerLogin.models
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('registerLogin', '0002_feedback_rating'),
    ]

    operations = [
        migrations.AlterField(
            model_name='loanstatus',
            name='time_updated',
            field=models.CharField(default=registerLogin.models.LoanStatus.get_nepal_time, max_length=50),
        ),
        migrations.AlterField(
            model_name='user',
            name='agree_terms',
            field=models.BooleanField(default=True),
        ),
    ]
