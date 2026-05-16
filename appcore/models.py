from django.db import models

# 1. TABELA: usuario_sistema
class UsuarioSistema(models.Model):
    email = models.EmailField(unique=True)
    senha = models.CharField(max_length=255)
    data_cadastro = models.DateField(auto_now_add=True)
    status = models.IntegerField(default=1, choices=[(1, 'Ativo'), (0, 'Inativo')])

    class Meta:
        db_table = 'usuario_sistema'


# 2. TABELA: especialidade
class Especialidade(models.Model):
    nome = models.CharField(max_length=100, unique=True)
    data_cadastro = models.DateField(auto_now_add=True)
    status = models.IntegerField(default=1, choices=[(1, 'Ativo'), (0, 'Inativo')])

    def __str__(self):
        return self.nome

    class Meta:
        db_table = 'especialidade'


# 3. TABELA: dentista
class Dentista(models.Model):
    nome = models.CharField(max_length=255)
    especialidade = models.ForeignKey(Especialidade, on_delete=models.PROTECT)
    telefone = models.CharField(max_length=11, unique=True)
    data_cadastro = models.DateField(auto_now_add=True)
    status = models.IntegerField(default=1, choices=[(1, 'Ativo'), (0, 'Inativo')])

    def __str__(self):
        return self.nome

    class Meta:
        db_table = 'dentista'


# 4. TABELA: servico
class Servico(models.Model):
    nome = models.CharField(max_length=255, unique=True)
    data_cadastro = models.DateField(auto_now_add=True)
    status = models.IntegerField(default=1, choices=[(1, 'Ativo'), (0, 'Inativo')])

    def __str__(self):
        return self.nome

    class Meta:
        db_table = 'servico'


# 5. TABELA: agendamento
class Agendamento(models.Model):
    STATUS_CONSULTA_CHOICES = [
        ('AGENDADO', 'Agendado'),
        ('CONCLUIDO', 'Concluído'),
        ('CANCELADO', 'Cancelado'),
    ]

    # Dados do paciente
    nome_paciente = models.CharField(max_length=255)
    cpf = models.CharField(max_length=14)
    data_nascimento = models.DateField()
    telefone = models.CharField(max_length=15)
    email = models.EmailField()
    endereco = models.TextField()

    # Dados do atendimento
    data_consulta = models.DateField()
    hora_consulta = models.TimeField()
    status_consulta = models.CharField(max_length=20, choices=STATUS_CONSULTA_CHOICES, default='AGENDADO')
    observacoes = models.TextField(blank=True, null=True)

    # Relacionamentos
    dentista = models.ForeignKey(Dentista, on_delete=models.PROTECT)
    servico = models.ForeignKey(Servico, on_delete=models.PROTECT)

    data_cadastro = models.DateField(auto_now_add=True)
    status = models.IntegerField(default=1, choices=[(1, 'Ativo'), (0, 'Inativo')])

    class Meta:
        db_table = 'agendamento'