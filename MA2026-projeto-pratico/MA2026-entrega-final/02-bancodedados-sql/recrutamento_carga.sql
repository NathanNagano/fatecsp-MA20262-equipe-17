-- =============================================================
-- recrutamento_carga.sql -- carga (DML) das staging para as tabelas finais
-- PRÉ-REQUISITO: as 5 tabelas stg_* já importadas dos CSVs da Etapa 2
-- (DB4S: Arquivo > Importar > Tabela de arquivo CSV; ou executar.py).
-- Reexecutável: apaga as tabelas finais e recarrega (ordem pai -> filha).
-- Nenhum dado de vaga é digitado aqui: tudo vem do staging.
-- =============================================================
PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

DELETE FROM vaga;
DELETE FROM vaga_rejeitada;
DELETE FROM cargo;
DELETE FROM tecnologia;
DELETE FROM empresa;
DELETE FROM calendario;

-- 1) Calendário contínuo 01/01/2026 a 30/06/2026 (181 dias), gerado em SQL
WITH RECURSIVE dias(d) AS (
  SELECT DATE('2026-01-01')
  UNION ALL
  SELECT DATE(d, '+1 day') FROM dias WHERE d < '2026-06-30'
)
INSERT INTO calendario
SELECT
  d,
  CAST(SUBSTR(d, 1, 4) AS INT),
  CAST(SUBSTR(d, 6, 2) AS INT),
  CASE CAST(SUBSTR(d, 6, 2) AS INT)
    WHEN 1 THEN 'janeiro'  WHEN 2 THEN 'fevereiro' WHEN 3 THEN 'março'
    WHEN 4 THEN 'abril'    WHEN 5 THEN 'maio'      WHEN 6 THEN 'junho' END,
  SUBSTR(d, 1, 7),
  'T' || ((CAST(SUBSTR(d, 6, 2) AS INT) + 2) / 3),
  CASE STRFTIME('%w', d) WHEN '0' THEN 7 ELSE CAST(STRFTIME('%w', d) AS INT) END,
  CASE STRFTIME('%w', d)
    WHEN '1' THEN 'segunda-feira' WHEN '2' THEN 'terça-feira'
    WHEN '3' THEN 'quarta-feira'  WHEN '4' THEN 'quinta-feira'
    WHEN '5' THEN 'sexta-feira'   WHEN '6' THEN 'sábado' ELSE 'domingo' END,
  CASE WHEN STRFTIME('%w', d) IN ('0', '6') THEN 'Sim' ELSE 'Não' END,
  '-'
FROM dias;

-- Feriados nacionais do recorte (mesma lista da dCalendario da Etapa 3)
UPDATE calendario SET feriado = 'Confraternização Universal' WHERE data = '2026-01-01';
UPDATE calendario SET feriado = 'Carnaval'                   WHERE data = '2026-02-17';
UPDATE calendario SET feriado = 'Sexta-feira Santa'          WHERE data = '2026-04-03';
UPDATE calendario SET feriado = 'Tiradentes'                 WHERE data = '2026-04-21';
UPDATE calendario SET feriado = 'Dia do Trabalho'            WHERE data = '2026-05-01';
UPDATE calendario SET feriado = 'Corpus Christi'             WHERE data = '2026-06-04';

-- 2) Cadastros (staging -> tipos do banco)
INSERT INTO cargo
SELECT TRIM(Cod_Cargo), TRIM(Senioridade), CAST(Salario_Piso AS DECIMAL(10,2)),
       CAST(Salario_Teto AS DECIMAL(10,2)), CAST(Max_Techs_Recomendado AS INT), TRIM(Descricao)
FROM stg_cargo;

INSERT INTO tecnologia
SELECT TRIM(Cod_Tech), TRIM(Nome_Tecnologia), TRIM(Categoria), TRIM(Nivel_Complexidade)
FROM stg_tecnologia;

INSERT INTO empresa
SELECT TRIM(Cod_Empresa), TRIM(Nome_Empresa), TRIM(Porte), TRIM(Setor), TRIM(Estado)
FROM stg_empresa;

-- 3) Fato: vagas válidas (a Etapa 2 já filtrou; o banco revalida com CHECK/FK)
INSERT INTO vaga
SELECT TRIM(ID_Vaga), Data_Publicacao, Hora_Publicacao, TRIM(Cod_Empresa),
       TRIM(Cod_Cargo), TRIM(Cod_Tech), CAST(Qtd_Tecnologias AS INT),
       CAST(Salario_Oferecido AS DECIMAL(10,2)), TRIM(Modalidade),
       TRIM(Canal_Divulgacao), TRIM(Flag_Falso_Junior)
FROM stg_vagas;

-- 4) Rejeitados da Etapa 2 (prova de que nenhuma linha sumiu)
INSERT INTO vaga_rejeitada
SELECT TRIM(ID_Vaga), Data_Anuncio, TRIM(Empresa), TRIM(Titulo_Vaga), TRIM(Motivo_Rejeicao)
FROM stg_rejeitados;

COMMIT;
