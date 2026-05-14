CREATE DATABASE clinica_odontologica;

USE clinica_odontologica;

CREATE TABLE IF NOT EXISTS usuario_sistema (
  cod_usuario_sistema INT UNSIGNED NOT NULL AUTO_INCREMENT,
  email VARCHAR(255) NOT NULL,
  senha VARCHAR(255) NOT NULL,
  tipo_usuario CHAR(1) NOT NULL COMMENT '(1) Administrador | (2) Recepcionista',
  data_cadastro DATE DEFAULT (CURRENT_DATE) NOT NULL,
  status BOOLEAN DEFAULT 1 COMMENT 'Ativo (1) ou Inativo (0)',
  PRIMARY KEY (cod_usuario_sistema),
  
UNIQUE (email),
CONSTRAINT chk_usuario_sistema_tipo CHECK (tipo_usuario IN (1, 2)),
CONSTRAINT chk_usuario_sistema_status CHECK (status IN (1, 0))
) COMMENT = 'Armazena os dados de acesso e perfis dos usuarios do sistema.';

CREATE TABLE IF NOT EXISTS paciente (
  cod_paciente INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(150) NOT NULL,
  cpf VARCHAR(14) NOT NULL COMMENT 'CPF sem pontos ou tracos, exatamente 11 digitos numericos',
  data_nascimento DATE NOT NULL,
  telefone VARCHAR(15) NOT NULL COMMENT 'Telefone celular sem formatacao, 11 digitos: DDD + número',
  email VARCHAR(255) NOT NULL,
  cod_usuario_sistema INT UNSIGNED NOT NULL,
  data_cadastro DATE DEFAULT (CURRENT_DATE) NOT NULL,
  status BOOLEAN DEFAULT 1 COMMENT 'Ativo (1) ou Inativo (0)',
  PRIMARY KEY (cod_paciente),

UNIQUE (cpf),
UNIQUE (telefone),
UNIQUE (email),
CONSTRAINT chk_paciente_cpf CHECK (cpf REGEXP '^[0-9]{11}$'),
CONSTRAINT chk_paciente_telefone CHECK (telefone REGEXP '^[0-9]{11}$'),
CONSTRAINT chk_paciente_status CHECK (status IN (1, 0))
) COMMENT = 'Registra as informacoes pessoais e de contato dos pacientes.';

CREATE TABLE IF NOT EXISTS endereco (
  cod_endereco INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cep VARCHAR(15) NOT NULL COMMENT 'Sem tracos ou pontos, exatamente 8 digitos numericos',
  rua VARCHAR(150) NOT NULL,
  numero INT NULL,
  complemento VARCHAR(100) NULL,
  bairro VARCHAR(100) NOT NULL,
  cidade VARCHAR(150) NOT NULL,
  estado VARCHAR(50) NOT NULL,
  cod_paciente INT UNSIGNED NOT NULL,
  data_cadastro DATE DEFAULT (CURRENT_DATE) NOT NULL,
  status BOOLEAN DEFAULT 1 COMMENT 'Ativo (1) ou Inativo (0)',
  PRIMARY KEY (cod_endereco),

UNIQUE (cod_paciente),
CONSTRAINT chk_endereco_cep CHECK (cep REGEXP '^[0-9]{8}$'),
CONSTRAINT chk_endereco_status CHECK (status IN (1, 0))
) COMMENT = 'Armazena os endereços residenciais vinculados a cada paciente.';

CREATE TABLE IF NOT EXISTS dentista (
  cod_dentista INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(150) NOT NULL,
  cro VARCHAR(30) NOT NULL,
  telefone VARCHAR(15) NOT NULL COMMENT 'Telefone celular sem formatacao, 11 digitos: DDD + numero',
  especialidade VARCHAR(100) NOT NULL,
  data_cadastro DATE DEFAULT (CURRENT_DATE) NOT NULL,
  status BOOLEAN DEFAULT 1 COMMENT 'Ativo (1) ou Inativo (0)',
  PRIMARY KEY (cod_dentista),
  
UNIQUE (cro),
UNIQUE (telefone),
CONSTRAINT chk_dentista_telefone CHECK (telefone REGEXP '^[0-9]{11}$'),
CONSTRAINT chk_dentista_status CHECK (status IN (1, 0))
) COMMENT = 'Registra os dados profissionais e de contato dos dentistas.';

CREATE TABLE IF NOT EXISTS disponibilidade (
  cod_disponibilidade INT UNSIGNED NOT NULL AUTO_INCREMENT,
  dia_semana VARCHAR(50) NOT NULL,
  horario_inicio TIME NOT NULL,
  horario_fim TIME NOT NULL,
  cod_dentista INT UNSIGNED NOT NULL,
  data_cadastro DATE DEFAULT (CURRENT_DATE) NOT NULL,
  status BOOLEAN DEFAULT 1 COMMENT 'Ativo (1) ou Inativo (0)',
  PRIMARY KEY (cod_disponibilidade),

CONSTRAINT chk_dia_semana CHECK (dia_semana IN ('SEGUNDA', 'TERCA', 'QUARTA', 'QUINTA', 'SEXTA', 'SABADO', 'DOMINGO')),
UNIQUE (dia_semana, horario_inicio, horario_fim, cod_dentista),
CONSTRAINT chk_disponibilidade_status CHECK (status IN (1, 0))
) COMMENT = 'Armazena os horarios de atendimento semanais de cada dentista.';

CREATE TABLE IF NOT EXISTS procedimento (
  cod_procedimento INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  data_cadastro DATE DEFAULT (CURRENT_DATE) NOT NULL,
  status BOOLEAN DEFAULT 1 COMMENT 'Ativo (1) ou Inativo (0)',
  PRIMARY KEY (cod_procedimento),

UNIQUE (nome),
CONSTRAINT chk_procedimento_status CHECK (status IN (1, 0))
) COMMENT = 'Catalogo de procedimentos odontologicos realizados na clinica.';

CREATE TABLE IF NOT EXISTS consulta (
  cod_consulta INT UNSIGNED NOT NULL AUTO_INCREMENT,
  data_consulta DATE NOT NULL,
  hora_consulta TIME NOT NULL,
  status_consulta VARCHAR(20) DEFAULT 'PENDENTE',
  motivo_cancelamento VARCHAR(80) DEFAULT NULL COMMENT 'Preenchido apenas se a consulta for CANCELADO',
  cod_dentista INT UNSIGNED NOT NULL,
  cod_paciente INT UNSIGNED NOT NULL,
  cod_procedimento INT UNSIGNED NOT NULL,
  data_cadastro DATE DEFAULT (CURRENT_DATE) NOT NULL,
  status BOOLEAN DEFAULT 1 COMMENT 'Ativo (1) ou Inativo (0)',
  PRIMARY KEY (cod_consulta),

CONSTRAINT chk_status_consulta CHECK (status_consulta IN ('PENDENTE', 'EM ANDAMENTO', 'CONCLUIDO', 'CANCELADO')),

CONSTRAINT chk_motivo_cancelamento_obrigatorio 
CHECK (
    (status_consulta = 'CANCELADO' AND motivo_cancelamento IS NOT NULL)
    OR
    (status_consulta <> 'CANCELADO')
),

CONSTRAINT chk_consulta_status CHECK (status IN (1, 0))
) COMMENT = 'Gerencia o agendamento e o historico de consultas clinicas do paciente.';

# ===========================================
#                 FOREIGN KEY
# ===========================================

# ===========================================
#              TABLE - PACIENTE
# ===========================================

ALTER TABLE paciente
ADD CONSTRAINT fk_paciente_usuario_sistema
FOREIGN KEY (cod_usuario_sistema)
REFERENCES usuario_sistema(cod_usuario_sistema)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

# ===========================================
#              TABLE - ENDERECO
# ===========================================

ALTER TABLE endereco
ADD CONSTRAINT fk_endereco_paciente
FOREIGN KEY (cod_paciente)
REFERENCES paciente(cod_paciente)
ON DELETE CASCADE
ON UPDATE NO ACTION;

# ===========================================
#          TABLE - DISPONIBILIDADE
# ===========================================

ALTER TABLE disponibilidade
ADD CONSTRAINT fk_disponibilidade_dentista
FOREIGN KEY (cod_dentista)
REFERENCES dentista(cod_dentista)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

# ===========================================
#              TABLE - CONSULTA
# ===========================================

ALTER TABLE consulta
ADD CONSTRAINT fk_consulta_dentista
FOREIGN KEY (cod_dentista)
REFERENCES dentista(cod_dentista)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE consulta
ADD CONSTRAINT fk_consulta_paciente
FOREIGN KEY (cod_paciente)
REFERENCES paciente(cod_paciente)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE consulta
ADD CONSTRAINT fk_consulta_procedimento
FOREIGN KEY (cod_procedimento)
REFERENCES procedimento(cod_procedimento)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

# ================================================================
# == TRIGGERS DE PADRONIZAÇÃO DE DADOS
# ================================================================

# =============================================================
# POLÍTICA DE PADRONIZAÇÃO DE TEXTO (UPPERCASE)
# =============================================================
# Estas triggers são responsáveis por garantir a consistência dos dados
# automaticamente, convertendo colunas específicas para MAIÚSCULO (UPPERCASE)
# antes de cada inserção ou atualização.
# =============================================================

DELIMITER //

-- =========================
-- PACIENTE
-- =========================
CREATE TRIGGER tg_paciente_insert_upper
BEFORE INSERT ON paciente
FOR EACH ROW
BEGIN
  SET NEW.nome = UPPER(NEW.nome);
END //

CREATE TRIGGER tg_paciente_update_upper
BEFORE UPDATE ON paciente
FOR EACH ROW
BEGIN
  SET NEW.nome = UPPER(NEW.nome);
END //

-- =========================
-- ENDERECO
-- =========================
CREATE TRIGGER tg_endereco_insert_upper
BEFORE INSERT ON endereco
FOR EACH ROW
BEGIN
  SET NEW.rua = UPPER(NEW.rua);
  SET NEW.bairro = UPPER(NEW.bairro);
  SET NEW.cidade = UPPER(NEW.cidade);
  SET NEW.estado = UPPER(NEW.estado);
END //

CREATE TRIGGER tg_endereco_update_upper
BEFORE UPDATE ON endereco
FOR EACH ROW
BEGIN
  SET NEW.rua = UPPER(NEW.rua);
  SET NEW.bairro = UPPER(NEW.bairro);
  SET NEW.cidade = UPPER(NEW.cidade);
  SET NEW.estado = UPPER(NEW.estado);
END //

-- =========================
-- DENTISTA
-- =========================
CREATE TRIGGER tg_dentista_insert_upper
BEFORE INSERT ON dentista
FOR EACH ROW
BEGIN
  SET NEW.nome = UPPER(NEW.nome);
  SET NEW.especialidade = UPPER(NEW.especialidade);
END //

CREATE TRIGGER tg_dentista_update_upper
BEFORE UPDATE ON dentista
FOR EACH ROW
BEGIN
  SET NEW.nome = UPPER(NEW.nome);
  SET NEW.especialidade = UPPER(NEW.especialidade);
END //

-- =========================
-- DISPONIBILIDADE
-- =========================
CREATE TRIGGER tg_disponibilidade_insert_upper
BEFORE INSERT ON disponibilidade
FOR EACH ROW
BEGIN
  SET NEW.dia_semana = UPPER(NEW.dia_semana);
END //

CREATE TRIGGER tg_disponibilidade_update_upper
BEFORE UPDATE ON disponibilidade
FOR EACH ROW
BEGIN
  SET NEW.dia_semana = UPPER(NEW.dia_semana);
END //

-- =========================
-- PROCEDIMENTO
-- =========================
CREATE TRIGGER tg_procedimento_insert_upper
BEFORE INSERT ON procedimento
FOR EACH ROW
BEGIN
  SET NEW.nome = UPPER(NEW.nome);
END //

CREATE TRIGGER tg_procedimento_update_upper
BEFORE UPDATE ON procedimento
FOR EACH ROW
BEGIN
  SET NEW.nome = UPPER(NEW.nome);
END //

-- =========================
-- CONSULTA
-- =========================
CREATE TRIGGER tg_consulta_insert_upper
BEFORE INSERT ON consulta
FOR EACH ROW
BEGIN
  SET NEW.status_consulta = UPPER(NEW.status_consulta);
  SET NEW.motivo_cancelamento = UPPER(NEW.motivo_cancelamento);
END //

CREATE TRIGGER tg_consulta_update_upper
BEFORE UPDATE ON consulta
FOR EACH ROW
BEGIN
  SET NEW.status_consulta = UPPER(NEW.status_consulta);
  SET NEW.motivo_cancelamento = UPPER(NEW.motivo_cancelamento);
END //

DELIMITER ;

-- PROCEDIMENTOS
INSERT INTO procedimento (cod_procedimento, nome)
VALUES
(1, 'LIMPEZA'									                           ),
(2, 'CLAREAMENTO'								                         ),
(3, 'APARELHOS ORTODÔNTICOS' 			                   	   ),
(4, 'TRATAMENTO DE GENGIVAS' 			                   		 ),
(5, 'FACETAS'									                           ),
(6, 'MANUTENÇÃO' 								                         ),
(7, 'FRENECTOMIA' 								                       ),
(8, 'REMOÇÃO DE LESÃO PATOLÓGICA'                    		 ),
(9, 'CIRURGIA DE REGULARIZAÇÃO DE REBORDO ALVEOLAR'      ),
(10, 'PRÓTESE ADESIVA'  				                    	   ),
(11, 'AUMENTO DE COROA CLÍNICA'	                    		 ),
(12, 'GENGIVOPLASTIA'						                         ),
(13, 'PROVISÓRIO'								                         ),
(14, 'PLACA PARA BRUXISMO'			                    	   ),
(15, 'CONTENÇÃO' 								                         );