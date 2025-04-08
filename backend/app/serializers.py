from rest_framework import serializers
from .models import PlantInfo, UserPlant, Category
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
    category_id = serializers.IntegerField(write_only=True)  # Allow category_id to be passed as an integer

    class Meta:
        model = PlantInfo
        fields = '__all__'

    def create(self, validated_data):
        # If category_id is passed, link the category
        category_id = validated_data.pop('category_id', None)
        if category_id:
            category = Category.objects.get(id=category_id)
            validated_data['category'] = category
        return super().create(validated_data)

    def update(self, instance, validated_data):
        category_id = validated_data.pop('category_id', None)
        if category_id:
            category = Category.objects.get(id=category_id)
            instance.category = category
        return super().update(instance, validated_data)


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


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name']  # Assuming Category has 'id' and 'name' fields