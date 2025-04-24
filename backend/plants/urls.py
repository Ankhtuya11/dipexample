from django.urls import path
from . import views

urlpatterns = [
    path('user/plant/<int:plant_id>/', views.get_plant_detail, name='plant-detail'),
] 