from rest_framework import viewsets, permissions
from .models import PlantInfo, UserPlant, Category
from .serializers import PlantInfoSerializer, UserPlantSerializer, CategorySerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework import generics
from .serializers import RegisterSerializer
from django.contrib.auth.models import User
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework import status
from rest_framework.views import APIView
class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = [AllowAny]
    serializer_class = RegisterSerializer

class PlantInfoCreateView(generics.CreateAPIView):
    queryset = PlantInfo.objects.all()
    serializer_class = PlantInfoSerializer
    permission_classes = [permissions.AllowAny]

class CategoryListView(generics.ListAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [permissions.AllowAny]

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



class PlantsByCategoryAPIView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, category_id, format=None):
        """
        Get all plants that belong to the specified category ID.
        """
        # Filter plants by category_id
        plants = PlantInfo.objects.filter(category_id=category_id)

        # Check if any plants were found for the given category
        if not plants:
            return Response(
                {"detail": "No plants found for this category."},
                status=status.HTTP_404_NOT_FOUND
            )

        # Serialize the plants
        serializer = PlantInfoSerializer(plants, many=True)

        # Return the list of plants
        return Response(serializer.data, status=status.HTTP_200_OK)