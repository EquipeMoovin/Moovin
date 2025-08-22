
from django.http import HttpResponseForbidden
from django.shortcuts import get_object_or_404

class DRFPermissionMixin:
    permission_classes = []

    def get_permissions(self):
        return [permission() for permission in self.permission_classes]

    def check_permissions(self, request):
        for permission in self.get_permissions():
            if not permission.has_permission(request, self):
                return False, getattr(permission, 'message', 'Permissão negada.')
        return True, None

    def dispatch(self, request, *args, **kwargs):
        has_permission, message = self.check_permissions(request)
        if not has_permission:
            return HttpResponseForbidden(message)
        return super().dispatch(request, *args, **kwargs)