from django.db import models

# 1. TABELA: usuario_sistema
class UsuarioSistema(models.Model):
    cod_usuario_sistema = models.AutoField(primary_key=True)
    email = models.EmailField(max_length=255, unique=True)
    senha = models.CharField(max_length=255)
    data_cadastro = models.DateField(auto_now_add=True)
    status = models.IntegerField(default=1, choices=[(1, 'Ativo'), (0, 'Inativo')])

    class Meta:
        db_table = 'usuario_sistema'


# 2. TABELA: especialidade
class Especialidade(models.Model):
    cod_especialidade = models.AutoField(primary_key=True)
    nome = models.CharField(max_length=100, unique=True)
    data_cadastro = models.DateField(auto_now_add=True)
    status = models.IntegerField(default=1, choices=[(1, 'Ativo'), (0, 'Inativo')])

    def __str__(self):
        return self.nome

    class Meta:
        db_table = 'especialidade'

# 3. TABELA: procedimento
class Procedimento(models.Model):
    cod_procedimento = models.AutoField(primary_key=True)
    nome = models.CharField(max_length=100, unique=True)
    data_cadastro = models.DateField(auto_now_add=True)
    status = models.IntegerField(default=1, choices=[(1, 'Ativo'), (0, 'Inativo')])

    def __str__(self):
        return self.nome

    class Meta:
        db_table = 'procedimento'

# 4. TABELA: dentista
class Dentista(models.Model):
    cod_dentista = models.AutoField(primary_key=True)
    nome = models.CharField(max_length=255)
    telefone = models.CharField(max_length=15, unique=True)
    especialidade = models.ForeignKey(Especialidade, on_delete=models.PROTECT)
    data_cadastro = models.DateField(auto_now_add=True)
    status = models.IntegerField(default=1, choices=[(1, 'Ativo'), (0, 'Inativo')])

    def __str__(self):
        return self.nome

    class Meta:
        db_table = 'dentista'

# 5. TABELA: paciente
class Paciente(models.Model):
    cod_paciente = models.AutoField(primary_key=True)
    nome = models.CharField(max_length=255)
    cpf = models.CharField(max_length=14, unique=True)
    data_nascimento = models.DateField()
    telefone = models.CharField(max_length=15, unique=True)
    email = models.EmailField(max_length=255, unique=True)
    endereco = models.CharField(max_length=255)
    data_cadastro = models.DateField(auto_now_add=True)
    status = models.IntegerField(default=1, choices=[(1, 'Ativo'), (0, 'Inativo')])

    def __str__(self):
        return self.nome

    class Meta:
        db_table = 'paciente'

# 6. TABELA: agendamento
class Agendamento(models.Model):
    # Definindo as escolhas como números
    class StatusAgendamento(models.IntegerChoices):
        AGENDADO  = 1, 'Agendado'
        CONCLUIDO = 2, 'Concluído'
        CANCELADO = 3, 'Cancelado'

    cod_agendamento = models.AutoField(primary_key=True)

    # Dados do atendimento
    data_consulta = models.DateField()
    hora_consulta = models.TimeField()
    
    # Campo configurado com a classe StatusAgendamento
    status_agendamento = models.IntegerField(
        choices=StatusAgendamento.choices, 
        default=StatusAgendamento.AGENDADO
    )
    
    motivo_cancelamento = models.TextField(blank=True, null=True)
    observacao = models.TextField(blank=True, null=True)

    # Relacionamentos
    dentista = models.ForeignKey(Dentista, on_delete=models.PROTECT)
    paciente = models.ForeignKey(Paciente, on_delete=models.PROTECT)
    procedimento = models.ForeignKey(Procedimento, on_delete=models.PROTECT)

    data_cadastro = models.DateField(auto_now_add=True)

    class Meta:
        db_table = 'agendamento'

