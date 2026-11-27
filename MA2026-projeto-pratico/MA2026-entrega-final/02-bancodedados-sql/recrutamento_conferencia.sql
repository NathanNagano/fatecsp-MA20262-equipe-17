-- =============================================================
-- recrutamento_conferencia.sql -- o banco reproduz as Etapas 2 e 3?
-- Regra de ouro: a coluna "diferenca" tem de ser 0 (K1 e K3).
-- K4 compara com o painel da Etapa 3 e deve ser lido com atenção.
-- =============================================================

-- K1) Batimento staging (CSV da Etapa 2) x tabelas finais
SELECT 'Vagas válidas' AS indicador,
       (SELECT COUNT(*) FROM stg_vagas) AS staging,
       (SELECT COUNT(*) FROM vaga)      AS banco,
       (SELECT COUNT(*) FROM vaga) - (SELECT COUNT(*) FROM stg_vagas) AS diferenca
UNION ALL
SELECT 'Soma de tecnologias exigidas',
       (SELECT SUM(CAST(Qtd_Tecnologias AS INT)) FROM stg_vagas),
       (SELECT SUM(qtd_tecnologias) FROM vaga),
       (SELECT SUM(qtd_tecnologias) FROM vaga) - (SELECT SUM(CAST(Qtd_Tecnologias AS INT)) FROM stg_vagas)
UNION ALL
SELECT 'Soma dos salários oferecidos',
       (SELECT SUM(CAST(Salario_Oferecido AS DECIMAL(10,2))) FROM stg_vagas),
       (SELECT SUM(salario_oferecido) FROM vaga),
       (SELECT SUM(salario_oferecido) FROM vaga) - (SELECT SUM(CAST(Salario_Oferecido AS DECIMAL(10,2))) FROM stg_vagas)
UNION ALL
SELECT 'Cargos',      (SELECT COUNT(*) FROM stg_cargo),      (SELECT COUNT(*) FROM cargo),
       (SELECT COUNT(*) FROM cargo) - (SELECT COUNT(*) FROM stg_cargo)
UNION ALL
SELECT 'Tecnologias', (SELECT COUNT(*) FROM stg_tecnologia), (SELECT COUNT(*) FROM tecnologia),
       (SELECT COUNT(*) FROM tecnologia) - (SELECT COUNT(*) FROM stg_tecnologia)
UNION ALL
SELECT 'Empresas',    (SELECT COUNT(*) FROM stg_empresa),    (SELECT COUNT(*) FROM empresa),
       (SELECT COUNT(*) FROM empresa) - (SELECT COUNT(*) FROM stg_empresa)
UNION ALL
SELECT 'Rejeitadas',  (SELECT COUNT(*) FROM stg_rejeitados), (SELECT COUNT(*) FROM vaga_rejeitada),
       (SELECT COUNT(*) FROM vaga_rejeitada) - (SELECT COUNT(*) FROM stg_rejeitados)
UNION ALL
SELECT 'Dias no calendário', 181, (SELECT COUNT(*) FROM calendario),
       (SELECT COUNT(*) FROM calendario) - 181;

-- K1b) Reconciliação da Etapa 2: lidas (21) = válidas + rejeitadas
SELECT 'Lidas = válidas + rejeitadas' AS indicador,
       21 AS esperado_etapa2,
       (SELECT COUNT(*) FROM vaga) + (SELECT COUNT(*) FROM vaga_rejeitada) AS banco,
       (SELECT COUNT(*) FROM vaga) + (SELECT COUNT(*) FROM vaga_rejeitada) - 21 AS diferenca;

-- K2) Integridade referencial: não deve devolver NENHUMA linha
PRAGMA foreign_key_check;

-- K3) Órfãs e inconsistências, uma a uma: todas devem ser 0
SELECT 'Vagas sem cargo' AS teste, COUNT(*) AS ocorrencias
FROM vaga v LEFT JOIN cargo c ON c.cod_cargo = v.cod_cargo WHERE c.cod_cargo IS NULL
UNION ALL
SELECT 'Vagas sem tecnologia', COUNT(*)
FROM vaga v LEFT JOIN tecnologia t ON t.cod_tech = v.cod_tech WHERE t.cod_tech IS NULL
UNION ALL
SELECT 'Vagas sem empresa', COUNT(*)
FROM vaga v LEFT JOIN empresa e ON e.cod_empresa = v.cod_empresa WHERE e.cod_empresa IS NULL
UNION ALL
SELECT 'Vagas fora do calendário', COUNT(*)
FROM vaga v LEFT JOIN calendario c ON c.data = v.data_publicacao WHERE c.data IS NULL
UNION ALL
SELECT 'Flag Falso Júnior divergente da regra (Júnior e techs > 3)', COUNT(*)
FROM vaga v
WHERE (v.cod_cargo = 'CARG-JR' AND v.qtd_tecnologias > 3) <> (v.flag_falso_junior <> 'Não')
UNION ALL
SELECT 'IDs rejeitados que também estão em vaga', COUNT(*)
FROM vaga_rejeitada r JOIN vaga v ON v.id_vaga = r.id_vaga;

-- K4) Batimento com a Etapa 3 (painel Validacao_Recrutamento do .xlsx)
-- Os valores de referência abaixo foram LIDOS do painel da Etapa 3.
SELECT 'Total de vagas' AS indicador, 16 AS etapa3,
       (SELECT COUNT(*) FROM vaga) AS banco,
       ROUND((SELECT COUNT(*) FROM vaga) - 16, 4) AS diferenca
UNION ALL
SELECT 'Salário médio geral', 6075,
       (SELECT ROUND(AVG(salario_oferecido),2) FROM vaga),
       ROUND((SELECT AVG(salario_oferecido) FROM vaga) - 6075, 4)
UNION ALL
SELECT 'Média de techs geral', 3.9375,
       (SELECT ROUND(AVG(qtd_tecnologias),4) FROM vaga),
       ROUND((SELECT AVG(qtd_tecnologias) FROM vaga) - 3.9375, 4)
UNION ALL
SELECT 'Vagas Falso Júnior', 6,
       (SELECT COUNT(*) FROM vaga WHERE flag_falso_junior <> 'Não'),
       (SELECT COUNT(*) FROM vaga WHERE flag_falso_junior <> 'Não') - 6
UNION ALL
SELECT 'Vagas Júnior (denominador da taxa)', 11,
       (SELECT COUNT(*) FROM vaga WHERE cod_cargo = 'CARG-JR'),
       (SELECT COUNT(*) FROM vaga WHERE cod_cargo = 'CARG-JR') - 11
UNION ALL
SELECT 'Média de techs Júnior', 4.54,
       (SELECT ROUND(AVG(qtd_tecnologias),2) FROM vaga WHERE cod_cargo = 'CARG-JR'),
       ROUND((SELECT AVG(qtd_tecnologias) FROM vaga WHERE cod_cargo = 'CARG-JR') - 4.54, 2)
UNION ALL
SELECT 'Salário médio Júnior', 5736.36,
       (SELECT ROUND(AVG(salario_oferecido),2) FROM vaga WHERE cod_cargo = 'CARG-JR'),
       ROUND((SELECT AVG(salario_oferecido) FROM vaga WHERE cod_cargo = 'CARG-JR') - 5736.36, 2)
UNION ALL
SELECT 'Taxa de requisitos inflacionados (%)', 54.5,
       (SELECT ROUND(100.0 * SUM(flag_falso_junior <> 'Não') / COUNT(*), 1) FROM vaga WHERE cod_cargo = 'CARG-JR'),
       ROUND((SELECT 100.0 * SUM(flag_falso_junior <> 'Não') / COUNT(*) FROM vaga WHERE cod_cargo = 'CARG-JR') - 54.5, 1);

-- K5) Índice em uso (plano de execução de uma consulta por cargo e data)
EXPLAIN QUERY PLAN
SELECT * FROM vaga WHERE cod_cargo = 'CARG-JR' AND data_publicacao >= '2026-03-01';
