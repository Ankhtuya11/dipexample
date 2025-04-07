from rest_framework import serializers
from .models import PlantInfo, UserPlant
from django.contrib.auth.models import User
from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password2 = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = ('username', 'password', 'password2', 'email')
    
    def validate(self, attrs):
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Нууц үг таарахгүй байна."})
        return attrs

    def create(self, validated_data):
        user = User.objects.create(
            username = validated_data['username'],
            email = validated_data['email']
        )
        user.set_password(validated_data['password'])
        user.save()
        return user

class PlantInfoSerializer(serializers.ModelSerializer):
    class Meta:
        model = PlantInfo
        fields = '__all__'

class UserPlantSerializer(serializers.ModelSerializer):
    plant = PlantInfoSerializer(read_only=True)  # Ургамлын дэлгэрэнгүйг харуулна
    plant_id = serializers.PrimaryKeyRelatedField(
        queryset=PlantInfo.objects.all(), write_only=True, source='plant'
    )

    class Meta:
        model = UserPlant
        fields = ['id', 'user', 'plant', 'plant_id', 'nickname', 'last_watered', 'image']
        read_only_fields = ['user']

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email']
