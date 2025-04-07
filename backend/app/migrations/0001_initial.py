# Generated by Django 4.1.7 on 2025-04-07 09:16

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='PlantInfo',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('description', models.TextField()),
                ('watering', models.CharField(max_length=100)),
                ('sunlight', models.CharField(max_length=100)),
                ('temperature', models.CharField(max_length=100)),
                ('image', models.ImageField(upload_to='plants/')),
            ],
        ),
        migrations.CreateModel(
            name='UserPlant',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('nickname', models.CharField(max_length=100)),
                ('last_watered', models.DateField(blank=True, null=True)),
                ('image', models.ImageField(upload_to='user_plants/')),
                ('plant', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='app.plantinfo')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]
