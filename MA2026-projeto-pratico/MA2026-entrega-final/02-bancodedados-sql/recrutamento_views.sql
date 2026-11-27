-- =============================================================
-- recrutamento_views.sql -- camada analítica em estrela (Etapa IV)
-- Estas VIEWS são o que o Power BI vai importar (Etapa V).
-- Reproduzem o modelo estrela da Etapa 3:
--   dim_cargo (= dCargo)  dim_tecnologia (= dTecnologia)
--   dim_empresa (= dEmpresa)  dim_tempo (= dCalendario)
--   fato_vagas (= fVagas)  fato_rejeitadas (= Rejeitados)
-- =============================================================
DROP VIEW IF EXISTS fato_rejeitadas;
DROP VIEW IF EXISTS fato_vagas;
DROP VIEW IF EXISTS dim_tempo;
DROP VIEW IF EXISTS dim_empresa;
DROP VIEW IF EXISTS dim_tecnologia;
DROP VIEW IF EXISTS dim_cargo;

CREATE VIEW dim_cargo AS
SELECT cod_cargo, senioridade, salario_piso, salario_teto,
       max_techs_recomendado, descricao
FROM cargo;

CREATE VIEW dim_tecnologia AS
SELECT cod_tech, nome_tecnologia, categoria, nivel_complexidade
FROM tecnologia;

CREATE VIEW dim_empresa AS
SELECT cod_empresa, nome_empresa, porte, setor, estado
FROM empresa;

CREATE VIEW dim_tempo AS
SELECT data, ano, mes, nome_mes, ano_mes, trimestre, dia_semana,
       nome_dia, fim_de_semana, feriado
FROM calendario;

-- Grão: uma vaga (igual a fVagas), com colunas derivadas para o Power BI
CREATE VIEW fato_vagas AS
SELECT v.id_vaga,
       v.data_publicacao                          AS data,
       v.hora_publicacao                          AS hora,
       v.cod_empresa,
       v.cod_cargo,
       v.cod_tech,
       v.qtd_tecnologias,
       v.salario_oferecido,
       v.modalidade,
       v.canal_divulgacao,
       v.flag_falso_junior,
       CASE WHEN v.flag_falso_junior = 'Não' THEN 0 ELSE 1 END AS is_falso_junior,
       c.max_techs_recomendado,
       v.qtd_tecnologias - c.max_techs_recomendado AS excesso_techs,
       CASE WHEN v.salario_oferecido < c.salario_piso THEN 'Abaixo da faixa'
            WHEN v.salario_oferecido > c.salario_teto THEN 'Acima da faixa'
            ELSE 'Dentro da faixa' END            AS situacao_salarial,
       CASE WHEN v.hora_publicacao < '12:00:00' THEN 'Manhã'
            WHEN v.hora_publicacao < '18:00:00' THEN 'Tarde'
            ELSE 'Noite' END                      AS turno
FROM vaga v
JOIN cargo c ON c.cod_cargo = v.cod_cargo;

CREATE VIEW fato_rejeitadas AS
SELECT id_vaga, data_anuncio, empresa, titulo_vaga, motivo_rejeicao
FROM vaga_rejeitada;
