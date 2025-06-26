from django.shortcuts import render, redirect
from django.views.generic import View
from django.contrib.auth import authenticate,login,logout
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated, AllowAny, IsAdminUser
from .models import *
from .serializers import UserSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.exceptions import NotFound
from rest_framework.views import APIView
from django.http import HttpResponseRedirect
from django.urls import reverse
from django.utils import timezone
import datetime

from django.core.mail import send_mail
from django.conf import settings
import random
import string
from .models import EmailVerificationCode
from django.contrib import messages
from django.urls import reverse_lazy
from django.core.exceptions import PermissionDenied

class UserRegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [AllowAny]

class ProtectedView(APIView): 
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response({'message': f'Olá {request.user.username}, você está autenticado com JWT!'})

def UserLogout(request):

    logout(request)
    return redirect('get-token')

class UserUpdateView(generics.UpdateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

class UserListView(generics.ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAdminUser]

class UserRetriverView(generics.RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    def get_object(self):
        """
        Sobrescreve o método get_object para buscar o usuário através do
        JWT (request.user), que já contém o pk do usuário autenticado.
        """
        user = self.request.user  

        if not user:
            raise NotFound("Usuário não encontrado.")

        return user
    

class UserDeleteView(generics.DestroyAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAdminUser]

class RequestEmailVerification(APIView):
    permission_classes = [AllowAny]
    def post(self, request):
        email = request.data.get('email')
        if not email:
            return Response({'error': 'O e-mail é obrigatório.'}, status=status.HTTP_400_BAD_REQUEST)

        # Gerar um código de verificação aleatório
        verification_code = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(6))

        try:
            # Salvar o código de verificação (com um tempo de expiração)
            EmailVerificationCode.objects.update_or_create(
                email=email,
                created_at = timezone.now(),
                defaults={'code': verification_code}
            )

            # Enviar o e-mail
            subject = 'Verifique seu e-mail'
            message = f'Seu código de verificação é: {verification_code}'
            from_email = settings.DEFAULT_FROM_EMAIL
            recipient_list = [email]
            send_mail(subject, message, from_email, recipient_list)

            return Response({'status': 'success', 'message': 'Código de verificação enviado para o seu e-mail.'}, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({'status': 'error', 'message': f'Erro ao enviar o e-mail: {str(e)}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class VerifyEmailCode(APIView):
    permission_classes = [AllowAny]
    def post(self, request):
        email = request.data.get('email')
        code = request.data.get('code')

        if not email or not code:
            return Response({'error': 'Email e código são obrigatórios.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            verification_entry = EmailVerificationCode.objects.get(email=email, code=code)
            now = timezone.now()
            expiration_time = verification_entry.created_at + datetime.timedelta(minutes=15)

            print(f"Agora bim: {now}")
            print(f"Criado em: {verification_entry.created_at}")
            print(f"Expira em: {expiration_time}")

            if not verification_entry.is_expired():
                verification_entry.delete()
                return Response({'status': 'success', 'message': 'Email verificado com sucesso.'}, status=status.HTTP_200_OK)
            else:
                return Response({'error': 'Código de verificação expirou.'}, status=status.HTTP_400_BAD_REQUEST)
        except EmailVerificationCode.DoesNotExist:
            return Response({'error': 'Código de verificação inválido.'}, status=status.HTTP_400_BAD_REQUEST)


class LoginWebView(View):
    template_name = 'login_web.html'

    def get(self, request):
        return render(request, self.template_name)

    def post(self, request):
        email = request.POST.get('email')
        password = request.POST.get('password')

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            messages.error(request, "Usuário com esse email não foi encontrado.")
            return render(request, self.template_name)

        user = authenticate(request, username=user.email, password=password)

        if user is not None:
            login(request, user)
            # messages.success(request, "Login realizado com sucesso.")
            # Verificar o parâmetro 'next' para redirecionamento
            next_url = request.POST.get('next', request.GET.get('next', ''))
            # Garantir que a URL é segura para evitar redirecionamentos maliciosos
            if next_url:
                return redirect(next_url)
           
            if user.has_perm('subscriptions.has_active_subscription'):
                messages.success(request, "Bem vindo de volta!")
                return redirect('owner-management')
            else:
                messages.error(request, "Você não tem permissão para acessar este recurso.")
                return render(request, self.template_name)
        else:

            messages.error(request, "Senha incorreta.")
            return render(request, self.template_name)
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['has_permission'] = self.request.user.has_perm('subscriptions.has_active_subscription')
        
        return context
        
class LogoutWebView(View):
    template_name = 'login_web.html'

    def get(self, request):
        return render(request, self.template_name)

    def post(self, request):
        if request.user.is_authenticated:
            logout(request)
            messages.success(request, "Logout realizado com sucesso.")
        return redirect(reverse_lazy('login-web'))

class RegisterWebView(View):
    template_name = 'register_web.html'
    
    def get(self, request):
        return render(request, self.template_name)
    
    def post(self, request):
        email = request.POST.get('email')
        name = request.POST.get('name')
        user_type = request.POST.get('user_type')
        password = request.POST.get('password')
        confirm_password = request.POST.get('confirm_password')
        
        # Validate required fields
        if not all([email, name, user_type, password, confirm_password]):
            messages.error(request, 'Todos os campos são obrigatórios.')
            return render(request, self.template_name)
        
        # Validate password match
        if password != confirm_password:
            messages.error(request, 'As senhas não coincidem.')
            return render(request, self.template_name)
        
        # Validate user_type
        valid_user_types = [choice[0] for choice in User.user_type.field.choices]
        if user_type not in valid_user_types:
            messages.error(request, 'Tipo de usuário inválido.')
            return render(request, self.template_name)
        
        # Check if email already exists
        if User.objects.filter(email=email).exists():
            messages.error(request, 'Este e-mail já está registrado.')
            return render(request, self.template_name)
        
        try:
            # Generate verification code
            verification_code = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(6))
            
            # Create user (but don't save yet)
            user = User(
                email=email,
                name=name,
                user_type=user_type
            )
            user.set_password(password)
            
            # Save verification code
            EmailVerificationCode.objects.update_or_create(
                email=email,
                defaults={'code': verification_code}
            )
            
            # Send verification email
            subject = 'Verifique seu e-mail'
            message = f'Seu código de verificação é: {verification_code}'
            from_email = settings.DEFAULT_FROM_EMAIL
            recipient_list = [email]
            send_mail(subject, message, from_email, recipient_list)
            
            # Save user to session for verification
            request.session['pending_user'] = {
                'email': email,
                'name': name,
                'user_type': user_type,
                'password': password
            }
            
            messages.success(request, 'Código de verificação enviado para o seu e-mail.')
            return HttpResponseRedirect(reverse('verify-email-code-web'))
            
        except Exception as e:
            messages.error(request, f'Erro ao processar o registro: {str(e)}')
            return render(request, self.template_name)
        

class VerifyEmailCodeView(View):
    template_name = 'verify_email_code.html'

    def get(self, request):
        return render(request, self.template_name)

    def post(self, request):
        code = request.POST.get('code')
        pending_user = request.session.get('pending_user')

        if not pending_user:
            messages.error(request, 'Sessão expirada. Por favor, registre-se novamente.')
            return redirect('register-web')

        email = pending_user['email']

        try:
            verification_entry = EmailVerificationCode.objects.get(email=email, code=code)
            expiration_time = verification_entry.created_at + datetime.timedelta(minutes=15)

            if timezone.now() > expiration_time:
                verification_entry.delete()
                messages.error(request, 'O código expirou. Solicite um novo.')
                return redirect('register-web')

            # Criar o usuário
            user = User(
                email=pending_user['email'],
                name=pending_user['name'],
                user_type=pending_user['user_type']
            )
            user.set_password(pending_user['password'])
            user.save()

            # Limpar código e sessão
            verification_entry.delete()
            del request.session['pending_user']

            messages.success(request, 'Cadastro concluído com sucesso! Faça login.')
            return redirect('login-web')

        except EmailVerificationCode.DoesNotExist:
            messages.error(request, 'Código inválido.')
            return render(request, self.template_name)
   
class ResetPasswordView(APIView):
    def post(self, request):
        email = request.data.get('email')
        #code = request.data.get('code')
        new_password = request.data.get('new_password')
        try:
            user = User.objects.get(email=email)
            user.set_password(new_password)
            user.save()
            return Response({'message': 'Senha redefinida com sucesso'}, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            return Response({'error': 'Usuário não encontrado'}, status=status.HTTP_404_NOT_FOUND)

