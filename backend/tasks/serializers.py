from rest_framework import serializers
from .models import Task

class TaskSerializer(serializers.ModelSerializer):
    title = serializers.CharField(
        required=True,
        allow_blank=True,
        max_length=255
    )
    class Meta:
        model = Task
        fields = "__all__"
        read_only_fields = [ "id","created_at","updated_at"]

    def validate_title(self,value):
        value = value.strip()
        if not value :
            raise serializers.ValidationError("Task title cannot be empty.")
        return value
    