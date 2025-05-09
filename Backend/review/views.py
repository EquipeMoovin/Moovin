from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from django.contrib.contenttypes.models import ContentType
from .models import Review
from .serializers import ReviewSerializer

class ReviewViewSet(viewsets.ModelViewSet):
    queryset = Review.objects.all()
    serializer_class = ReviewSerializer

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)

    @action(detail=False, methods=['get'])
    def by_object(self, request):
        model_type = request.query_params.get('type')
        object_id = request.query_params.get('id')

        if not model_type or not object_id:
            return Response({'error': 'Missing type or id parameters.'}, status=400)

        try:
            content_type = ContentType.objects.get(model=model_type.lower())
        except ContentType.DoesNotExist:
            return Response({'error': 'Invalid model type.'}, status=400)

        reviews = Review.objects.filter(content_type=content_type, object_id=object_id)
        serializer = self.get_serializer(reviews, many=True)
        return Response(serializer.data)
