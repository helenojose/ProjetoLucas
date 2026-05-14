# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = True` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class Consulta(models.Model):
    cod_consulta = models.AutoField(primary_key=True)
    data_consulta = models.DateField()
    hora_consulta = models.TimeField()
    status_consulta = models.CharField(max_length=20, blank=True, null=True)
    motivo_cancelamento = models.CharField(max_length=80, blank=True, null=True, db_comment='Preenchido apenas se a consulta for CANCELADO')
    cod_dentista = models.ForeignKey('Dentista', models.DO_NOTHING, db_column='cod_dentista')
    cod_paciente = models.ForeignKey('Paciente', models.DO_NOTHING, db_column='cod_paciente')
    cod_procedimento = models.ForeignKey('Procedimento', models.DO_NOTHING, db_column='cod_procedimento')
    data_cadastro = models.DateField()
    status = models.IntegerField(blank=True, null=True, db_comment='Ativo (1) ou Inativo (0)')

    class Meta:
        managed = True
        db_table = 'consulta'
        db_table_comment = 'Gerencia o agendamento e o historico de consultas clÝnicas do paciente.'


class Dentista(models.Model):
    cod_dentista = models.AutoField(primary_key=True)
    nome = models.CharField(max_length=150)
    cro = models.CharField(unique=True, max_length=30)
    telefone = models.CharField(unique=True, max_length=15, db_comment='Telefone celular sem formatacao, 11 digitos: DDD + numero')
    especialidade = models.CharField(max_length=100)
    data_cadastro = models.DateField()
    status = models.IntegerField(blank=True, null=True, db_comment='Ativo (1) ou Inativo (0)')
    
    class Meta:
        managed = True
        db_table = 'dentista'
        db_table_comment = 'Registra os dados profissionais e de contato dos dentistas.'


class Disponibilidade(models.Model):
    cod_disponibilidade = models.AutoField(primary_key=True)
    dia_semana = models.CharField(max_length=50)
    horario_inicio = models.TimeField()
    horario_fim = models.TimeField()
    cod_dentista = models.ForeignKey(Dentista, models.DO_NOTHING, db_column='cod_dentista')
    data_cadastro = models.DateField()
    status = models.IntegerField(blank=True, null=True, db_comment='Ativo (1) ou Inativo (0)')

    class Meta:
        managed = True
        db_table = 'disponibilidade'
        unique_together = (('dia_semana', 'horario_inicio', 'horario_fim', 'cod_dentista'),)
        db_table_comment = 'Armazena os horarios de atendimento semanais de cada dentista.'


class Endereco(models.Model):
    cod_endereco = models.AutoField(primary_key=True)
    cep = models.CharField(max_length=15, db_comment='Sem tracos ou pontos, exatamente 8 digitos numericos')
    rua = models.CharField(max_length=150)
    numero = models.IntegerField(blank=True, null=True)
    complemento = models.CharField(max_length=100, blank=True, null=True)
    bairro = models.CharField(max_length=100)
    cidade = models.CharField(max_length=150)
    estado = models.CharField(max_length=50)
    cod_paciente = models.OneToOneField('Paciente', models.DO_NOTHING, db_column='cod_paciente')
    data_cadastro = models.DateField()
    status = models.IntegerField(blank=True, null=True, db_comment='Ativo (1) ou Inativo (0)')

    class Meta:
        managed = True
        db_table = 'endereco'
        db_table_comment = 'Armazena os endereþos residenciais vinculados a cada paciente.'


class Paciente(models.Model):
    cod_paciente = models.AutoField(primary_key=True)
    nome = models.CharField(max_length=150)
    cpf = models.CharField(unique=True, max_length=14, db_comment='CPF sem pontos ou tracos, exatamente 11 digitos numericos')
    data_nascimento = models.DateField()
    telefone = models.CharField(unique=True, max_length=15, db_comment='Telefone celular sem formatacao, 11 digitos: DDD + n·mero')
    email = models.CharField(unique=True, max_length=255)
    cod_usuario_sistema = models.ForeignKey('UsuarioSistema', models.DO_NOTHING, db_column='cod_usuario_sistema')
    data_cadastro = models.DateField()
    status = models.IntegerField(blank=True, null=True, db_comment='Ativo (1) ou Inativo (0)')

    class Meta:
        managed = True
        db_table = 'paciente'
        db_table_comment = 'Registra as informacoes pessoais e de contato dos pacientes.'


class Procedimento(models.Model):
    cod_procedimento = models.AutoField(primary_key=True)
    nome = models.CharField(unique=True, max_length=100)
    data_cadastro = models.DateField()
    status = models.IntegerField(blank=True, null=True, db_comment='Ativo (1) ou Inativo (0)')

    class Meta:
        managed = True
        db_table = 'procedimento'
        db_table_comment = 'Catalogo de procedimentos odontologicos realizados na clinica.'


class UsuarioSistema(models.Model):
    cod_usuario_sistema = models.AutoField(primary_key=True)
    email = models.CharField(unique=True, max_length=255)
    senha = models.CharField(max_length=255)
    tipo_usuario = models.CharField(max_length=1, db_comment='(1) Administrador | (2) Recepcionista')
    data_cadastro = models.DateField()
    status = models.IntegerField(blank=True, null=True, db_comment='Ativo (1) ou Inativo (0)')

    class Meta:
        managed = True
        db_table = 'usuario_sistema'
        db_table_comment = 'Armazena os dados de acesso e perfis dos usuarios do sistema.'
