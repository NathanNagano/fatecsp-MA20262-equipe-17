-- =============================================================
-- recrutamento_ddl.sql -- estrutura do banco recrutamento (Etapa IV)
-- Projeto: Painel de Decisão para Recrutamento de Entrada ("Falso Júnior")
-- Equipe 17 -- ILP590 Microinformática Aplicada -- Fatec São Paulo
-- SGBD de referência: SQLite 3. Sintaxe compatível com MySQL 8
-- (AUTOINCREMENT não é usado; tipos e CHECK são padrão).
-- Ordem: tabelas "pai" (sem FK) primeiro, depois as "filhas".
-- =============================================================

PRAGMA foreign_keys = ON;

-- Recriação limpa: apaga na ordem inversa das dependências
DROP TABLE IF EXISTS vaga;
DROP TABLE IF EXISTS vaga_rejeitada;
DROP TABLE IF EXISTS cotacao_dia;
DROP TABLE IF EXISTS tecnologia;
DROP TABLE IF EXISTS cargo;
DROP TABLE IF EXISTS empresa;
DROP TABLE IF EXISTS calendario;
DROP TABLE IF EXISTS stg_vagas;
DROP TABLE IF EXISTS stg_cargo;
DROP TABLE IF EXISTS stg_tecnologia;
DROP TABLE IF EXISTS stg_empresa;
DROP TABLE IF EXISTS stg_rejeitados;

-- -------------------------------------------------------------
-- 1) Dimensões / cadastros
-- -------------------------------------------------------------
CREATE TABLE cargo (
  cod_cargo             VARCHAR(10)  NOT NULL,
  senioridade           VARCHAR(10)  NOT NULL,
  salario_piso          DECIMAL(10,2) NOT NULL,
  salario_teto          DECIMAL(10,2) NOT NULL,
  max_techs_recomendado INT          NOT NULL,
  descricao             VARCHAR(80),
  CONSTRAINT pk_cargo PRIMARY KEY (cod_cargo),
  CONSTRAINT uq_cargo_senioridade UNIQUE (senioridade),
  CONSTRAINT ck_cargo_faixa CHECK (salario_piso > 0 AND salario_teto >= salario_piso),
  CONSTRAINT ck_cargo_techs CHECK (max_techs_recomendado > 0)
);

CREATE TABLE tecnologia (
  cod_tech           VARCHAR(10)  NOT NULL,
  nome_tecnologia    VARCHAR(40)  NOT NULL,
  categoria          VARCHAR(30)  NOT NULL,
  nivel_complexidade VARCHAR(10)  NOT NULL,
  CONSTRAINT pk_tecnologia PRIMARY KEY (cod_tech),
  CONSTRAINT uq_tecnologia_nome UNIQUE (nome_tecnologia),
  CONSTRAINT ck_tecnologia_nivel
    CHECK (nivel_complexidade IN ('Básica', 'Média', 'Avançada'))
);

CREATE TABLE empresa (
  cod_empresa  VARCHAR(10) NOT NULL,
  nome_empresa VARCHAR(40) NOT NULL,
  porte        VARCHAR(20) NOT NULL,
  setor        VARCHAR(30) NOT NULL,
  estado       VARCHAR(10) NOT NULL,
  CONSTRAINT pk_empresa PRIMARY KEY (cod_empresa),
  CONSTRAINT uq_empresa_nome UNIQUE (nome_empresa)
);

CREATE TABLE calendario (
  data          DATE        NOT NULL,
  ano           INT         NOT NULL,
  mes           INT         NOT NULL,
  nome_mes      VARCHAR(10) NOT NULL,
  ano_mes       CHAR(7)     NOT NULL,
  trimestre     CHAR(2)     NOT NULL,
  dia_semana    INT         NOT NULL,   -- 1 = segunda ... 7 = domingo
  nome_dia      VARCHAR(15) NOT NULL,
  fim_de_semana CHAR(3)     NOT NULL,   -- 'Sim' / 'Não'
  feriado       VARCHAR(30) NOT NULL,   -- nome do feriado ou '-'
  CONSTRAINT pk_calendario PRIMARY KEY (data)
);

-- -------------------------------------------------------------
-- 2) Fatos
-- Grão de vaga: UMA linha por vaga válida (a Etapa 2 já eliminou as
-- inválidas). O evento "vaga publicada" não tem itens: tabela única.
-- -------------------------------------------------------------
CREATE TABLE vaga (
  id_vaga           VARCHAR(10)   NOT NULL,
  data_publicacao   DATE          NOT NULL,
  hora_publicacao   TIME          NOT NULL,
  cod_empresa       VARCHAR(10)   NOT NULL,
  cod_cargo         VARCHAR(10)   NOT NULL,
  cod_tech          VARCHAR(10)   NOT NULL,   -- tecnologia principal
  qtd_tecnologias   INT           NOT NULL,   -- total exigido no anúncio
  salario_oferecido DECIMAL(10,2) NOT NULL,
  modalidade        VARCHAR(12)   NOT NULL,
  canal_divulgacao  VARCHAR(15)   NOT NULL,
  flag_falso_junior VARCHAR(15)   NOT NULL,
  CONSTRAINT pk_vaga PRIMARY KEY (id_vaga),
  CONSTRAINT fk_vaga_empresa  FOREIGN KEY (cod_empresa)     REFERENCES empresa (cod_empresa),
  CONSTRAINT fk_vaga_cargo    FOREIGN KEY (cod_cargo)       REFERENCES cargo (cod_cargo),
  CONSTRAINT fk_vaga_tech     FOREIGN KEY (cod_tech)        REFERENCES tecnologia (cod_tech),
  CONSTRAINT fk_vaga_calendario FOREIGN KEY (data_publicacao) REFERENCES calendario (data),
  CONSTRAINT ck_vaga_qtd      CHECK (qtd_tecnologias > 0),
  CONSTRAINT ck_vaga_salario  CHECK (salario_oferecido > 0),
  CONSTRAINT ck_vaga_modalidade CHECK (modalidade IN ('Remoto', 'Híbrido', 'Presencial')),
  CONSTRAINT ck_vaga_flag     CHECK (flag_falso_junior IN ('Não', 'SIM (Falso Jr)'))
);

-- Linhas descartadas pela Etapa 2: o banco as guarda com o motivo.
-- (sem FK de propósito: são exatamente os registros que NÃO casam)
CREATE TABLE vaga_rejeitada (
  id_vaga          VARCHAR(10)  NOT NULL,
  data_anuncio     VARCHAR(12),             -- texto: pode ser data inválida
  empresa          VARCHAR(40),
  titulo_vaga      VARCHAR(60),
  motivo_rejeicao  VARCHAR(80)  NOT NULL,
  CONSTRAINT pk_vaga_rejeitada PRIMARY KEY (id_vaga)
);

-- Reservada para a Etapa VI (API AwesomeAPI -- cotação USD/EUR):
-- recebe os dados reais depois; aqui só a estrutura.
CREATE TABLE cotacao_dia (
  moeda         CHAR(3)       NOT NULL,
  data_ref      DATE          NOT NULL,
  cotacao_compra DECIMAL(8,4),
  cotacao_venda  DECIMAL(8,4),
  CONSTRAINT pk_cotacao_dia PRIMARY KEY (moeda, data_ref)
);

-- -------------------------------------------------------------
-- 3) Índices nas chaves estrangeiras (JOINs mais rápidos)
-- -------------------------------------------------------------
CREATE INDEX ix_vaga_cargo_data ON vaga (cod_cargo, data_publicacao);
CREATE INDEX ix_vaga_empresa    ON vaga (cod_empresa);
CREATE INDEX ix_vaga_tech       ON vaga (cod_tech);
CREATE INDEX ix_vaga_data       ON vaga (data_publicacao);
CREATE INDEX ix_calendario_mes  ON calendario (ano_mes);

-- -------------------------------------------------------------
-- 4) Staging: recebem os CSVs exatamente como vieram (só TEXT)
--    Mesmas colunas, na mesma ordem, dos CSVs exportados da Etapa 2.
-- -------------------------------------------------------------
CREATE TABLE stg_vagas (
  ID_Vaga TEXT, Data_Publicacao TEXT, Hora_Publicacao TEXT, Cod_Empresa TEXT,
  Cod_Cargo TEXT, Cod_Tech TEXT, Qtd_Tecnologias TEXT, Salario_Oferecido TEXT,
  Modalidade TEXT, Canal_Divulgacao TEXT, Flag_Falso_Junior TEXT
);
CREATE TABLE stg_cargo (
  Cod_Cargo TEXT, Senioridade TEXT, Salario_Piso TEXT, Salario_Teto TEXT,
  Max_Techs_Recomendado TEXT, Descricao TEXT
);
CREATE TABLE stg_tecnologia (
  Cod_Tech TEXT, Nome_Tecnologia TEXT, Categoria TEXT, Nivel_Complexidade TEXT
);
CREATE TABLE stg_empresa (
  Cod_Empresa TEXT, Nome_Empresa TEXT, Porte TEXT, Setor TEXT, Estado TEXT
);
CREATE TABLE stg_rejeitados (
  ID_Vaga TEXT, Data_Anuncio TEXT, Empresa TEXT, Titulo_Vaga TEXT, Motivo_Rejeicao TEXT
);
