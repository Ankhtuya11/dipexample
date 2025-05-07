import http
from rest_framework import viewsets, permissions
from .models import PlantInfo, UserPlant, Category
from .serializers import *
from .services import *
from rest_framework.permissions import IsAuthenticated
from rest_framework import generics
from .serializers import RegisterSerializer
from django.contrib.auth.models import User
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework import status
from rest_framework.views import APIView
import json 
class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = [AllowAny]
    serializer_class = RegisterSerializer

    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        return response

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

# class UserPlantViewSet(viewsets.ModelViewSet):
#     queryset = UserPlant.objects.none()  # ← нэмэх
#     serializer_class = UserPlantSerializer
#     permission_classes = [IsAuthenticated]

#     def get_queryset(self):
#         return UserPlant.objects.filter(user=self.request.user)

#     def perform_create(self, serializer):
#         serializer.save(user=self.request.user)



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

class UserAddPlantView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, format=None):
        """
        Add a plant to the user's collection.
        """
        serializer = UserAddPlantSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            user_plant = serializer.save()
            return Response({
                'message': 'Plant added successfully!',
                'plant': serializer.data
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)    
    

class UserPlantsListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        user_plants = UserPlant.objects.filter(user=request.user)
        serializer = UserPlantDetailSerializer(user_plants, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


class PlantHealthAssessmentView(APIView):
    def post(self, request):
        """
        Assess plant health from base64 encoded image,
        then ask ChatGPT for plant care advice in Mongolian.
        """
        image_base64 = request.data.get('image')

        if not image_base64:
            return Response(
                {'error': 'Image data is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        result = PlantHealthService.assess_plant_health(image_base64)

        if result['status'] == 'error':
            return Response(result, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # Compose question for ChatGPT
        user_prompt = (
            f"Энэ бол миний ургамлын талаарх мэдээлэл: {result.get('description', '')}. "
            f"Ургамлыг хэрхэн арчлах талаар надад зөвлөгөө өгөөч."
        )

        # ChatGPT API Call
        try:
            conn = http.client.HTTPSConnection("chatgpt-42.p.rapidapi.com")

            payload = json.dumps({
                "messages": [{"role": "user", "content": 'based on this information can you give me some advice on how to take care of my plant? in mongolian{user_prompt}'}],
                "web_access": False
            })

            headers = {
                'x-rapidapi-key': "fcced1c658mshf69f17cc85ef827p175afbjsn61ed07a82da2",
                'x-rapidapi-host': "chatgpt-42.p.rapidapi.com",
                'Content-Type': "application/json"
            }

            conn.request("POST", "/deepseekai", payload, headers)
            res = conn.getresponse()
            data = res.read().decode("utf-8")
            advice_response = json.loads(data)

            # Extract ChatGPT reply
            chatgpt_reply = advice_response.get("choices", [{}])[0].get("message", {}).get("content", "")

            # Combine plant assessment with AI advice
            combined_result = {
                "health_result": result,
                "care_advice_mn": chatgpt_reply
            }

            return Response(combined_result, status=status.HTTP_200_OK)

        except Exception as e:
            return Response(
                {'error': f'Failed to get care advice: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )