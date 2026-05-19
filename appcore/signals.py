from django.db import models
from django.db.models import Q
from django.db.models.signals import pre_save
from django.dispatch import receiver
from django.core.exceptions import ValidationError
from .models import Especialidade, Dentista, Paciente, Agendamento

# ================================================================
# == TRIGGERS DE PADRONIZAÇÃO DE DADOS (UPPERCASE)
# ================================================================

@receiver(pre_save, sender=Especialidade)
def tg_especialidade_upper(sender, instance, **kwargs):
    if instance.nome:
        instance.nome = instance.nome.upper()

@receiver(pre_save, sender=Dentista)
def tg_dentista_upper(sender, instance, **kwargs):
    if instance.nome:
        instance.nome = instance.nome.upper()

@receiver(pre_save, sender=Paciente)
def tg_paciente_upper(sender, instance, **kwargs):
    if instance.nome:
        instance.nome = instance.nome.upper()

    if instance.endereco:
        instance.endereco = instance.endereco.upper()

@receiver(pre_save, sender=Agendamento)
def tg_agendamento_upper(sender, instance, **kwargs):
     if instance.motivo_cancelamento:
         instance.motivo_cancelamento = instance.motivo_cancelamento.upper()

     if instance.observacao:
         instance.observacao = instance.observacao.upper()

     if instance.nome_procedimento:
        instance.nome_procedimento = instance.nome_procedimento.upper()

# ==========================================================================================
# MAPEAMENTO DE STATUS DO AGENDAMENTO
# OBJETIVO: Definir a codificação numérica para o fluxo de estados da consulta.
# 
# VALORES DE REFERÊNCIA:
# 1 = AGENDADO  -> Consulta marcada.
# 2 = CONCLUIDO -> Atendimento finalizado.
# 3 = CANCELADO -> Consulta desmarcada.
# ==========================================================================================


# ==========================================================================================
# TRIGGER: tg_validar_conflito_horario_dentista
# OBJETIVO: Impedir o agendamento de múltiplas consultas no mesmo horário para o mesmo dentista.
# 
# CENÁRIO DE PROTEÇÃO:
# 1. Verifica se já existe uma consulta (AGENDADO) para o dentista
#    na mesma data e hora informada.
# ==========================================================================================

@receiver(pre_save, sender=Agendamento)
def tg_validar_conflito_horario_dentista(sender, instance, **kwargs):
    conflito_existe = Agendamento.objects.filter(
        data_consulta=instance.data_consulta,
        hora_consulta=instance.hora_consulta,
        status_agendamento=1
    ).filter(
        Q(dentista=instance.dentista) | Q(paciente=instance.paciente)
    )

    if instance.pk:
        conflito_existe = conflito_existe.exclude(pk=instance.pk)

    if conflito_existe.exists():
        raise ValidationError(
            "ERRO: O dentista possui uma consulta agendada para este horário."
        )

# ==========================================================================================
# TRIGGER: tg_travar_agendamento
# OBJETIVO: Garantir a imutabilidade dos dados clínicos após o encerramento do atendimento.
# 
# CENÁRIO DE PROTEÇÃO:
# 1. Se status_agendamento for 'CONCLUIDO' -> Bloqueia qualquer alteração na linha (UPDATE).
# 2. Garante a integridade do histórico do paciente.
# 3. Impede adulteração de procedimentos, datas ou profissionais em registros finalizados.
# ==========================================================================================

@receiver(pre_save, sender=Agendamento)
def tg_travar_agendamento_concluido(sender, instance, **kwargs):
    # O OLD só existe se o registro já tiver uma chave primária (ou seja, é um UPDATE)
    if instance.pk:
        # Busca o status atual que está gravado no banco (o "OLD")
        status_antigo = Agendamento.objects.filter(pk=instance.pk).values_list('status_agendamento', flat=True).first()
        
        if status_antigo == 2:  
            raise ValidationError(
                "Erro: Não é permitido editar um agendamento com status concluído."
            )
 
# ==========================================================================================
# TRIGGER: tg_validar_motivo_cancelamento_obrigatorio
# OBJETIVO: Validar se o motivo de cancelamento foi preenchido ao alterar o status para CANCELADO.
# ==========================================================================================

@receiver(pre_save, sender=Agendamento)
def tg_validar_motivo_cancelamento_obrigatorio(sender, instance, **kwargs):
    # 1. Se for CANCELADO (3), obriga a ter o motivo
    if instance.status_agendamento == 3:
        if not instance.motivo_cancelamento or not instance.motivo_cancelamento.strip():
            raise ValidationError(
                "Erro: É obrigatório informar o motivo do cancelamento."
            )
            
    # 2. Se NÃO for cancelado, proíbe ter qualquer texto no motivo
    else:
        if instance.motivo_cancelamento and instance.motivo_cancelamento.strip():
            raise ValidationError(
                "Erro: O motivo do cancelamento só deve ser preenchido se o status for Cancelado."
            )