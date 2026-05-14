-- ===========================================
-- USUÁRIOS DO SISTEMA
-- ===========================================
-- Perfis de acesso: (1) Administrador | (2) Recepcionista

INSERT INTO usuario_sistema (cod_usuario_sistema, email, senha, tipo_usuario) VALUES
(1, 'adm.central@clinica.com', 'a1b2c3d4-e5f6-47a8-b9c0-123456789001', '1'),
(2, 'recepcao.sul@clinica.com', 'b2c3d4e5-f6a7-48b9-c0d1-234567890002', '2'),
(3, 'recepcao.norte@clinica.com', 'c3d4e5f6-a7b8-49c9-d0e1-345678901003', '2'),
(4, 'gerente.clinica@clinica.com', 'd4e5f6a7-b8c9-40d0-e1f2-456789012004', '1');

-- ===========================================
-- DENTISTAS
-- ===========================================
-- Profissionais e suas especialidades

INSERT INTO dentista (cod_dentista, nome, cro, telefone, especialidade) VALUES
(1, 'Ricardo Oliveira', 'CROPE12345', '81988887777', 'Ortodontia'),
(2, 'Juliana Mendes', 'CROPE67890', '81977776666', 'Endodontia'),
(3, 'Alberto Santos', 'CROPE11223', '81966665555', 'Implantodontia'),
(4, 'Fernanda Lima', 'CROPE44556', '81955554444', 'Odontopediatria');

-- ===========================================
-- PACIENTES
-- ===========================================
-- Dados pessoais dos pacientes vinculados ao usuário que realizou o cadastro

INSERT INTO paciente (cod_paciente, nome, cpf, data_nascimento, telefone, email, cod_usuario_sistema) VALUES
(1, 'Ana Beatriz Silva', '12345678901', '1995-05-15', '81911112222', 'ana.silva@email.com', 2),
(2, 'Bruno Henrique Costa', '23456789012', '1988-03-20', '81922223333', 'bruno.costa@email.com', 2),
(3, 'Carla Mendes Souza', '34567890123', '2000-11-02', '81933334444', 'carla.souza@email.com', 3),
(4, 'Diego Alves Lima', '45678901234', '1992-08-12', '81944445555', 'diego.lima@email.com', 3),
(5, 'Elena Cristina Martins', '56789012345', '1985-01-30', '81955556666', 'elena.martins@email.com', 2);

-- ===========================================
-- ENDEREÇOS
-- ===========================================
-- Localização dos pacientes (Região Metropolitana do Recife)

INSERT INTO endereco (cod_endereco, cep, rua, numero, bairro, cidade, estado, cod_paciente) VALUES
(1, '50010000', 'Praca da Republica', 10, 'Santo Antonio', 'Recife', 'PE', 1),
(2, '52060000', 'Avenida Norte', 1500, 'Casa Amarela', 'Recife', 'PE', 2),
(3, '50761000', 'Rua Benfica', 50, 'Madalena', 'Recife', 'PE', 3),
(4, '54400000', 'Avenida Bernardo Vieira de Melo', 200, 'Piedade', 'Jaboatao dos Guararapes', 'PE', 4),
(5, '53030000', 'Rua do Sol', 88, 'Carmo', 'Olinda', 'PE', 5);

-- ===========================================
-- DISPONIBILIDADE
-- ===========================================
-- Grade de horários dos dentistas para a semana

INSERT INTO disponibilidade (cod_disponibilidade, dia_semana, horario_inicio, horario_fim, cod_dentista) VALUES
(1, 'SEGUNDA', '08:00:00', '12:00:00', 1),
(2, 'TERCA', '14:00:00', '18:00:00', 1),
(3, 'QUARTA', '08:00:00', '17:00:00', 2),
(4, 'QUINTA', '09:00:00', '13:00:00', 3),
(5, 'SEXTA', '13:00:00', '19:00:00', 4);

-- ===========================================
-- CONSULTAS
-- ===========================================
-- Agendamentos realizados (Pendentes, Em Andamento, Concluídos e Cancelados)
-- Nota: Para status 'CANCELADO', o motivo_cancelamento é obrigatório.

INSERT INTO consulta (cod_consulta, data_consulta, hora_consulta, status_consulta, motivo_cancelamento, cod_dentista, cod_paciente, cod_procedimento) VALUES
-- Consultas Futuras (Pendentes)
(1, '2026-05-18', '09:00:00', 'PENDENTE', NULL, 1, 1, 3),
(2, '2026-05-19', '15:00:00', 'PENDENTE', NULL, 1, 2, 1),
(3, '2026-05-20', '14:00:00', 'PENDENTE', NULL, 2, 3, 2),

-- Atendimento Atual
(4, '2026-05-15', '16:00:00', 'EM ANDAMENTO', NULL, 4, 4, 14),

-- Histórico Antigo (Concluído)
(5, '2026-01-15', '10:00:00', 'CONCLUIDO', NULL, 3, 5, 5),

-- Consultas Canceladas (Com motivo obrigatório)
(6, '2026-05-18', '11:00:00', 'CANCELADO', 'PACIENTE APRESENTOU SINTOMAS DE GRIPE', 1, 1, 1),
(7, '2026-05-20', '09:30:00', 'CANCELADO', 'DENTISTA COM EMERGÊNCIA FAMILIAR', 2, 4, 2),

-- Registro Cancelado Antigo (Para fins de histórico)
(8, '2025-11-20', '10:00:00', 'CANCELADO', 'DESISTÊNCIA DO TRATAMENTO', 3, 2, 3);