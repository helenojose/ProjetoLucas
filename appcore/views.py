from django.shortcuts import render, redirect
from django.contrib.auth.models import User
from django.contrib import messages
from django.contrib.auth import authenticate, login as auth_login

def login_view(request):
    if request.method == 'POST':
        email = request.POST.get('email')
        password = request.POST.get('password')
        user = authenticate(request, username=email, password=password)

        if user is not None:
            auth_login(request, user) 
            messages.success(request, f'Bem-vindo, {user.email}!')
            return redirect('login') 
        else:
            messages.error(request, 'E-mail ou senha incorretos.')
            return redirect('login')

    return render(request, 'login.html')


def cadastro(request):
    if request.method == 'POST':
        email = request.POST.get('email')
        password = request.POST.get('password')

        if User.objects.filter(email=email).exists():
            messages.error(request, 'Email já cadastrado')
            return redirect('cadastro')

        User.objects.create_user(
            username=email, 
            email=email,
            password=password
        )

        messages.success(request, 'Cadastro realizado com sucesso!')
        return redirect('login')

    return render(request, 'cadastro.html')