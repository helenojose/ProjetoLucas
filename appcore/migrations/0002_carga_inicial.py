# Generated manually for data migration

from django.db import migrations

def carregar_dados_iniciais(apps, schema_editor):
     # Recupera os modelos usando o histórico do Django
    Procedimento = apps.get_model('appcore', 'Procedimento')
    Especialidade = apps.get_model('appcore', 'Especialidade')
    
    # 1. Lista de Procedimentos
    lista_procedimentos = [
        'LIMPEZA', 'CLAREAMENTO', 'APARELHOS ORTODÔNTICOS', 
        'TRATAMENTO DE GENGIVAS', 'FACETAS', 'MANUTENÇÃO', 
        'FRENECTOMIA', 'REMOÇÃO DE LESÃO PATOLÓGICA', 
        'CIRURGIA DE REGULARIZAÇÃO DE REBORDO ALVEOLAR', 
        'PRÓTESE ADESIVA', 'AUMENTO DE COROA CLÍNICA', 
        'GENGIVOPLASTIA', 'PROVISÓRIO', 'PLACA PARA BRUXISMO', 'CONTENÇÃO'
    ]
   
    for nome_procedimento in lista_procedimentos:
        Procedimento.objects.get_or_create(nome=nome_procedimento)
        
    # 2. Lista de Especialidades
    lista_especialidades = [
        'CLÍNICA GERAL', 'ORTODONTIA', 'ENDODONTIA', 'PERIODONTIA',
        'IMPLANTODONTIA', 'ODONTOPEDIATRIA', 'PRÓTESE DENTÁRIA',
        'CIRURGIA E TRAUMATOLOGIA BUCO-MAXILO-FACIAL'
    ]
    for nome_especialidade in lista_especialidades:
        Especialidade.objects.get_or_create(nome=nome_especialidade)


class Migration(migrations.Migration):

    dependencies = [
        ('appcore', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(carregar_dados_iniciais),
    ]