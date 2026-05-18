from django.db.models.signals import pre_save
from django.dispatch import receiver
from .models import Agendamento, Dentista, Especialidade, Paciente, Procedimento

# ================================================================
# == TRIGGERS DE PADRONIZAÇÃO DE DADOS (UPPERCASE)
# ================================================================

@receiver(pre_save, sender=Especialidade)
def tg_especialidade_upper(sender, instance, **kwargs):
    if instance.nome:
        instance.nome = instance.nome.upper()


@receiver(pre_save, sender=Procedimento)
def tg_procedimento_upper(sender, instance, **kwargs):
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

'''
@receiver(pre_save, sender=Agendamento)
def tg_agendamento_upper(sender, instance, **kwargs):
     if instance.motivo_cancelamento:
         instance.motivo_cancelamento = instance.motivo_cancelamento.upper()

     if instance.observacao:
         instance.observacao = instance.observacao.upper()
'''