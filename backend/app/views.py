from rest_framework import viewsets, permissions
from .models import PlantInfo, UserPlant
from .serializers import PlantInfoSerializer, UserPlantSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework import generics
from .serializers import RegisterSerializer
from django.contrib.auth.models import User
from rest_framework.permissions import AllowAny

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = [AllowAny]
    serializer_class = RegisterSerializer

class PlantInfoViewSet(viewsets.ModelViewSet):
    queryset = PlantInfo.objects.all()
    serializer_class = PlantInfoSerializer
    permission_classes = [permissions.AllowAny]

class UserPlantViewSet(viewsets.ModelViewSet):
    queryset = UserPlant.objects.none()  # ← нэмэх
    serializer_class = UserPlantSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return UserPlant.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

