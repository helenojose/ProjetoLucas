# ================================================================
# == CÓDIGOS DE ERRO
# ================================================================

# SQLSTATE 45000 --> Indica um erro genérico e definido pelo utilizador.
#                   usado para bloquear operações não permitidas nas triggers.


-- ==========================================================================================
-- TRIGGER: tg_validar_conflito_horario_dentista_insert
-- OBJETIVO: Impedir o agendamento de múltiplas consultas no mesmo horário para o mesmo dentista.
-- 
-- CENÁRIO DE PROTEÇÃO:
-- 1. Verifica se já existe uma consulta (PENDENTE ou EM ANDAMENTO) para o dentista
--    na mesma data e hora informada.
-- ==========================================================================================
DELIMITER //

CREATE TRIGGER tg_validar_conflito_horario_dentista_insert
BEFORE INSERT ON consulta
FOR EACH ROW
BEGIN
	-- =============================================================
    -- 1. VERIFICAÇÃO DE CONFLITO
    -- =============================================================
    IF EXISTS (
        SELECT 1 FROM consulta 
        WHERE (cod_dentista = NEW.cod_dentista OR cod_paciente = NEW.cod_paciente)
          AND data_consulta = NEW.data_consulta 
          AND hora_consulta = NEW.hora_consulta
          AND status_consulta IN ('PENDENTE', 'EM ANDAMENTO')
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: O dentista possui uma consulta agendada para este horário.';
    END IF;
END //

DELIMITER ;

-- ==========================================================================================
-- TRIGGER: tg_validar_conflito_horario_dentista_update
-- OBJETIVO: Prevenir a sobreposição de horários durante o REAGENDAMENTO de consultas.
-- 
-- CENÁRIO DE PROTEÇÃO:
-- 1. Atua quando a data, hora ou profissional são alterados em um registro existente.
-- 2. Verifica se o novo horário já está ocupado por outro agendamento ativo.
-- 3. Garante que nem o dentista nem o paciente possuam dois compromissos simultâneos.
-- 4. Exclui o próprio registro da verificação para permitir edições sem falso-positivo.
-- ==========================================================================================
DELIMITER //

CREATE TRIGGER tg_validar_conflito_horario_dentista_update
BEFORE UPDATE ON consulta
FOR EACH ROW
BEGIN

    -- =============================================================
    -- 1. FILTRO DE ALTERAÇÃO CRÍTICA
    -- =============================================================
    -- A validação só ocorre se houver mudança no "quando" ou "com quem".
    IF (NEW.data_consulta <> OLD.data_consulta OR 
        NEW.hora_consulta <> OLD.hora_consulta OR 
        NEW.cod_dentista <> OLD.cod_dentista) THEN
        
        -- =============================================================
        -- 2. VERIFICAÇÃO DE CONFLITO
        -- =============================================================
        IF EXISTS (
            SELECT 1 FROM consulta 
            WHERE (cod_dentista = NEW.cod_dentista OR cod_paciente = NEW.cod_paciente) 
              AND data_consulta = NEW.data_consulta 
              AND hora_consulta = NEW.hora_consulta 
              AND status_consulta IN ('PENDENTE', 'EM ANDAMENTO')
              -- Impede que o banco compare a consulta com ela mesma
              AND cod_consulta <> NEW.cod_consulta 
        ) THEN 
            -- Bloqueia a atualização e retorna o erro de conflito
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'ERRO: O horário escolhido para o reagendamento já está ocupado.'; 
        END IF;
        
    END IF;

END //

DELIMITER ;

-- ==========================================================================================
-- TRIGGER: tg_validar_disponibilidade_dentista_insert
-- OBJETIVO: Restringir agendamentos apenas aos períodos de trabalho do profissional.
-- 
-- CENÁRIO DE PROTEÇÃO:
-- 1. Identifica o dia da semana da nova consulta através da data informada.
-- 2. Cruza essa informação com a grade horária na tabela 'disponibilidade'.
-- 3. Bloqueia a inserção se o dentista não estiver ativo ou se o horário estiver fora da grade.
-- ==========================================================================================
DELIMITER //

CREATE TRIGGER tg_validar_disponibilidade_dentista_insert
BEFORE INSERT ON consulta
FOR EACH ROW
BEGIN
    -- =============================================================
    -- 1. VALIDAÇÃO DE ADERÊNCIA À GRADE
    -- =============================================================
    
    -- Verifica se NÃO EXISTE registro que autorize o atendimento neste momento
    IF NOT EXISTS (
        SELECT 1 
        FROM disponibilidade 
        WHERE cod_dentista = NEW.cod_dentista 
          AND status = 1
          -- Converte a data para o nome do dia da semana (Padrão UPPERCASE do banco)
          AND dia_semana = (
              SELECT CASE DAYOFWEEK(NEW.data_consulta)
                  WHEN 1 THEN 'DOMINGO'
                  WHEN 2 THEN 'SEGUNDA'
                  WHEN 3 THEN 'TERCA'
                  WHEN 4 THEN 'QUARTA'
                  WHEN 5 THEN 'QUINTA'
                  WHEN 6 THEN 'SEXTA'
                  WHEN 7 THEN 'SABADO'
              END
          )
          -- Valida se a hora escolhida está dentro do intervalo de atendimento
          AND NEW.hora_consulta BETWEEN horario_inicio AND horario_fim
    ) THEN
        -- Bloqueia a operação caso a grade não seja respeitada
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: O dentista não possui disponibilidade cadastrada para este dia/horário.';
    END IF;
END //

DELIMITER ;

-- ==========================================================================================
-- TRIGGER: tg_validar_disponibilidade_dentista_update
-- OBJETIVO: Validar a grade de horários durante o REAGENDAMENTO de consultas.
-- 
-- CENÁRIO DE PROTEÇÃO:
-- 1. Monitora alterações em campos críticos: data, hora ou profissional (cod_dentista).
-- 2. Evita que uma edição manual mova uma consulta para um dia/horário em que o 
--    dentista não atende.
-- 3. Utiliza a lógica de conversão de calendário para garantir a integridade.
-- ==========================================================================================
DELIMITER //

CREATE TRIGGER tg_validar_disponibilidade_dentista_update
BEFORE UPDATE ON consulta
FOR EACH ROW
BEGIN

    -- =============================================================
    -- 1. FILTRO DE ALTERAÇÃO (OTIMIZAÇÃO)
    -- =============================================================
    -- A validação só é processada se houver mudança nos dados de agendamento.
    -- Isso evita processamento desnecessário ao editar apenas o status ou observações.
    IF (NEW.data_consulta <> OLD.data_consulta OR 
        NEW.hora_consulta <> OLD.hora_consulta OR 
        NEW.cod_dentista <> OLD.cod_dentista) THEN
        
        -- =============================================================
        -- 2. VALIDAÇÃO DE CONFORMIDADE COM A GRADE
        -- =============================================================
        IF NOT EXISTS (
            SELECT 1 FROM disponibilidade 
            WHERE cod_dentista = NEW.cod_dentista 
              AND status = 1
              -- Tradução da data do novo agendamento para o formato da grade (UPPERCASE)
              AND dia_semana = (
                  SELECT CASE DAYOFWEEK(NEW.data_consulta)
                      WHEN 1 THEN 'DOMINGO'
                      WHEN 2 THEN 'SEGUNDA'
                      WHEN 3 THEN 'TERCA'
                      WHEN 4 THEN 'QUARTA'
                      WHEN 5 THEN 'QUINTA'
                      WHEN 6 THEN 'SEXTA'
                      WHEN 7 THEN 'SABADO'
                  END
              )
              -- Garante que o novo horário esteja dentro do expediente cadastrado
              AND NEW.hora_consulta BETWEEN horario_inicio AND horario_fim
        ) THEN
            -- Bloqueia a atualização caso o novo horário seja inválido para o profissional
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: O dentista não possui disponibilidade para este novo horário.';
        END IF;
        
    END IF;

END //

DELIMITER ;

-- ==========================================================================================
-- TRIGGER: tg_travar_consulta_concluida
-- OBJETIVO: Garantir a imutabilidade dos dados clínicos após o encerramento do atendimento.
-- 
-- CENÁRIO DE PROTEÇÃO:
-- 1. Se status_consulta for 'CONCLUIDO' -> Bloqueia qualquer alteração na linha (UPDATE).
-- 2. Garante a integridade do histórico médico/odontológico do paciente.
-- 3. Impede adulteração de procedimentos, datas ou profissionais em registros finalizados.
-- ==========================================================================================

DELIMITER //

CREATE TRIGGER tg_travar_consulta_concluida
BEFORE UPDATE ON consulta
FOR EACH ROW
BEGIN

    -- =============================================================
    -- 1. VALIDAÇÃO DE STATUS CONCLUIDO
    -- =============================================================
    
    -- Verifica se o registro atual (OLD) já consta como encerrado
    IF OLD.status_consulta = 'CONCLUIDO' THEN
        
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: Não é permitido editar uma consulta com status concluído.';
    END IF;

END //

DELIMITER ;


-- ==========================================================================================
-- TRIGGER: tg_limitar_atendimento_ativo_dentista
-- OBJETIVO: Garantir que um dentista só tenha UM atendimento iniciado por vez.
-- ==========================================================================================
DELIMITER //

CREATE TRIGGER tg_limitar_atendimento_ativo_dentista
BEFORE UPDATE ON consulta
FOR EACH ROW
BEGIN
	-- =============================================================
    -- 1. VALIDAÇÃO DE ATENDIMENTO ÚNICO
    -- =============================================================
    -- Se o status está mudando para 'EM ANDAMENTO'
    IF NEW.status_consulta = 'EM ANDAMENTO' AND OLD.status_consulta <> 'EM ANDAMENTO' THEN
        -- Verifica se o dentista já tem outro paciente na sala
        IF EXISTS (
            SELECT 1 FROM consulta 
            WHERE cod_dentista = NEW.cod_dentista 
              AND status_consulta = 'EM ANDAMENTO'
              AND cod_consulta <> NEW.cod_consulta
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Este dentista já está com um atendimento em andamento.';
        END IF;
    END IF;
END //

DELIMITER ;

-- ==========================================================================================
-- TRIGGER: tg_validar_tempo_cancelamento
-- OBJETIVO: Impor a política de cancelamento antecipado para otimização da agenda.
-- 
-- CENÁRIO DE PROTEÇÃO:
-- 1. Verifica se a transição de status é para 'CANCELADO'.
-- 2. Bloqueia o cancelamento se faltarem menos de 120 minutos (2 horas) para a consulta.
-- ==========================================================================================
DELIMITER //

CREATE TRIGGER tg_validar_tempo_cancelamento
BEFORE UPDATE ON consulta
FOR EACH ROW
BEGIN

    -- =============================================================
    -- 1. VALIDAÇÃO DE TRANSIÇÃO PARA CANCELAMENTO
    -- =============================================================
    
    -- Verifica se o status está sendo alterado para 'CANCELADO' e se já não estava assim
    IF NEW.status_consulta = 'CANCELADO' AND OLD.status_consulta <> 'CANCELADO' THEN
        
        -- =============================================================
        -- 2. CÁLCULO DE ANTECEDÊNCIA
        -- =============================================================
        
        -- Valida se a diferença entre o horário da consulta e o momento atual é inferior a 120 minutos
        -- O uso de OLD garante a comparação com o horário originalmente agendado
        IF TIMESTAMPDIFF(MINUTE, NOW(), TIMESTAMP(OLD.data_consulta, OLD.hora_consulta)) < 120 THEN
            
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Erro: O cancelamento deve ser realizado com antecedência mínima de 2 horas.';
        END IF;
    END IF;
END //

DELIMITER ;


-- ==========================================================================================
-- EVENT SCHEDULER
-- Ativa e verifica o agendador de eventos do MySQL
-- ==========================================================================================

SET GLOBAL event_scheduler = ON;
SELECT @@event_scheduler;

-- ==========================================================================================
-- EVENTO: ev_remocao_consultas_pendentes_antigas
-- OBJETIVO: Realizar a remoção de agendamentos pendentes após o período de retenção.
--
-- REGRA DE NEGÓCIO:
-- Consultas com status_consulta = 'PENDENTE' e com data_cadastro superior a 6 meses
-- são consideradas elegíveis para exclusão definitiva.
--
-- COMPORTAMENTO:
-- A exclusão ocorre em lote controlado (LIMIT 500),
-- garantindo execução eficiente e com baixo impacto no banco de dados.
--
-- FREQUÊNCIA:
-- Executado automaticamente 1 vez por dia (às 02:00h) pelo Event Scheduler do MySQL.
--
-- FINALIDADE:
-- Garantir a limpeza de agendamentos que nunca foram concluídos ou cancelados,
-- atuando como reforço na manutenção de registros obsoletos.
--
-- OBSERVAÇÃO:
-- Este processo é totalmente gerenciado pelo banco de dados. A data de referência 
-- (data_cadastro) possui preenchimento automático via DEFAULT (CURRENT_DATE), 
-- assegurando a integridade do intervalo de retenção mesmo em caso de omissão pelo backend.
-- ==========================================================================================

DELIMITER //

CREATE EVENT IF NOT EXISTS ev_remocao_consultas_pendentes_antigas
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE, '02:00:00')
DO
BEGIN
	-- =============================================================
    -- 1. LIMPEZA DE REGISTROS OBSOLETOS
    -- =============================================================
    -- Remove consultas que ficaram 'PENDENTE' e foram criadas há mais de 6 meses
    DELETE FROM consulta
    WHERE status_consulta = 'PENDENTE'
      AND data_cadastro <= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    LIMIT 500;

END //

DELIMITER ;

