# Generated by Django 5.0.7 on 2024-11-20 11:53

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('registerLogin', '0003_alter_loanstatus_time_updated_alter_user_agree_terms'),
    ]

    operations = [
        migrations.CreateModel(
            name='FAQ',
            fields=[
                ('faq_id', models.AutoField(primary_key=True, serialize=False)),
                ('question', models.TextField()),
                ('answer', models.TextField()),
            ],
        ),
    ]
