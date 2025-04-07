from django.contrib import admin
from .models import PlantInfo, UserPlant

@admin.register(PlantInfo)
class PlantInfoAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'watering', 'sunlight', 'temperature']
    search_fields = ['name']

@admin.register(UserPlant)
class UserPlantAdmin(admin.ModelAdmin):
    list_display = ['id', 'nickname', 'user', 'plant', 'last_watered']
    list_filter = ['user', 'plant']
