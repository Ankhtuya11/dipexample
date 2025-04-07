from django.db import models
from django.contrib.auth.models import User

class PlantInfo(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()
    watering = models.CharField(max_length=100)
    sunlight = models.CharField(max_length=100)
    temperature = models.CharField(max_length=100)
    image = models.ImageField(upload_to='plants/')

    def __str__(self):
        return self.name

class UserPlant(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    plant = models.ForeignKey(PlantInfo, on_delete=models.CASCADE)
    nickname = models.CharField(max_length=100)
    last_watered = models.DateField(null=True, blank=True)
    image = models.ImageField(upload_to='user_plants/')

    def __str__(self):
        return f"{self.nickname} - {self.user.username}"
