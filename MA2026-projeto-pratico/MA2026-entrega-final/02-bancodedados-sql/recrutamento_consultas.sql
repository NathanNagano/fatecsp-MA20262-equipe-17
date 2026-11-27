-- =============================================================
-- recrutamento_consultas.sql -- consultas analíticas (Etapa IV)
-- Cada consulta responde a uma pergunta de negócio da Proposta Técnica:
-- "Qual a discrepância entre as tecnologias exigidas e o salário
--  oferecido nas vagas de entrada (Júnior e Estágio)?"
-- =============================================================

-- C1 -- Ranking: as tecnologias principais mais exigidas (até 10) e o salário médio
-- Pergunta: que tecnologias dominam os anúncios e quanto pagam?
SELECT t.nome_tecnologia, t.nivel_complexidade,
       COUNT(*)                          AS vagas,
       ROUND(AVG(v.salario_oferecido),2) AS salario_medio
FROM vaga v
JOIN tecnologia t ON t.cod_tech = v.cod_tech
GROUP BY t.cod_tech, t.nome_tecnologia, t.nivel_complexidade
ORDER BY vagas DESC, salario_medio DESC
LIMIT 10;  -- a base tem 9 tecnologias em uso

-- C2 -- Real x esperado: cada senioridade contra a faixa e o limite de techs
-- Pergunta: o mercado respeita o teto de tecnologias recomendado por cargo?
SELECT c.senioridade,
       COUNT(*)                                   AS vagas,
       ROUND(AVG(v.qtd_tecnologias),2)            AS media_techs,
       c.max_techs_recomendado                    AS teto_techs,
       ROUND(AVG(v.qtd_tecnologias) - c.max_techs_recomendado, 2) AS excesso_medio,
       ROUND(AVG(v.salario_oferecido),2)          AS salario_medio,
       c.salario_piso || ' - ' || c.salario_teto  AS faixa_mercado
FROM vaga v
JOIN cargo c ON c.cod_cargo = v.cod_cargo
GROUP BY c.cod_cargo, c.senioridade, c.max_techs_recomendado, c.salario_piso, c.salario_teto
ORDER BY c.salario_piso;

-- C3 -- Razão por segmento: taxa de "Falso Júnior" por canal de divulgação
-- Pergunta: em que canais as vagas Júnior mais inflam os requisitos?
SELECT v.canal_divulgacao,
       COUNT(*)                                                   AS vagas_junior,
       SUM(CASE WHEN v.qtd_tecnologias > c.max_techs_recomendado THEN 1 ELSE 0 END) AS falso_junior,
       ROUND(100.0 * SUM(CASE WHEN v.qtd_tecnologias > c.max_techs_recomendado THEN 1 ELSE 0 END)
             / COUNT(*), 1)                                       AS taxa_pct
FROM vaga v
JOIN cargo c ON c.cod_cargo = v.cod_cargo
WHERE c.senioridade = 'Júnior'
GROUP BY v.canal_divulgacao
ORDER BY taxa_pct DESC, vagas_junior DESC;

-- C4 -- Evolução no tempo: vagas e "Falso Júnior" por mês (usa o calendário)
-- Pergunta: o fenômeno cresce ao longo do semestre?
SELECT cal.ano_mes, cal.nome_mes,
       COUNT(*)                                             AS vagas,
       SUM(CASE WHEN v.flag_falso_junior <> 'Não' THEN 1 ELSE 0 END) AS falso_junior,
       ROUND(AVG(v.qtd_tecnologias),2)                      AS media_techs
FROM vaga v
JOIN calendario cal ON cal.data = v.data_publicacao
GROUP BY cal.ano_mes, cal.nome_mes
ORDER BY cal.ano_mes;

-- C5 -- Exceções (HAVING): empresas com mais de uma vaga "Falso Júnior"
-- Pergunta: que empresas reincidem na inflação de requisitos?
SELECT e.nome_empresa, e.setor,
       COUNT(*)                          AS vagas_falso_junior,
       ROUND(AVG(v.qtd_tecnologias),1)   AS media_techs,
       ROUND(AVG(v.salario_oferecido),2) AS salario_medio
FROM vaga v
JOIN empresa e ON e.cod_empresa = v.cod_empresa
WHERE v.flag_falso_junior <> 'Não'
GROUP BY e.cod_empresa, e.nome_empresa, e.setor
HAVING COUNT(*) > 1
ORDER BY vagas_falso_junior DESC, e.nome_empresa;

-- C6 -- Qualidade da base: motivos de rejeição da Etapa 2
SELECT motivo_rejeicao, COUNT(*) AS linhas
FROM vaga_rejeitada
GROUP BY motivo_rejeicao
ORDER BY linhas DESC, motivo_rejeicao;
