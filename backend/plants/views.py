from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .models import UserPlant
from .serializers import UserPlantDetailSerializer

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_plant_detail(request, plant_id):
    try:
        user_plant = UserPlant.objects.get(id=plant_id, user=request.user)
        serializer = UserPlantDetailSerializer(user_plant)
        return Response(serializer.data)
    except UserPlant.DoesNotExist:
        return Response(
            {"error": "Plant not found"},
            status=status.HTTP_404_NOT_FOUND
        ) 