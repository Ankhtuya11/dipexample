from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import PlantInfoViewSet, UserPlantViewSet, RegisterView
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

router = DefaultRouter()
router.register('plants', PlantInfoViewSet)
router.register('myplants', UserPlantViewSet, basename='myplants')

urlpatterns = [
    path('', include(router.urls)),
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('register/', RegisterView.as_view(), name='auth_register'),  # ← 👈 Бүртгэл энд нэмэгдлээ
]
