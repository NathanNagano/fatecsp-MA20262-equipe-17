# Etapa V – Dashboard no Power BI (Painel de Decisão para Recrutamento de Entrada)

**Disciplina:** Microinformática Aplicada (ILP590) – FATEC São Paulo • **Equipe 17**
**Integrantes:** Nathan Campos Nagano, Matheus Guides Rubim Fonseca e João Wictor Leles Santos (RA 22106946)
**Entrega final (N2):** 27/11/2026 • **Arquivo do painel:** `Recrutamento_Dashboard.pbix` (a gerar no Power BI Desktop, ver "Status")

## Objetivo
Painel de três páginas que responde à pergunta central do projeto: *qual a discrepância entre as tecnologias exigidas e o salário oferecido nas vagas de entrada (Júnior e Estágio)?* Regra do projeto: **Falso Júnior = Cod_Cargo = CARG-JR e Qtd_Tecnologias > 3**.

| Página | Parte da pergunta | Observação |
|---|---|---|
| 1 – Visão Executiva | Como está o mercado de entrada e onde há mais Falso Júnior? | KPIs, mês, canal, real × esperado |
| 2 – Tecnologias & Salário | O que se exige e quanto se paga? | ranking, dispersão, contraste, empresas reincidentes |
| 3 – Câmbio & Salário | O salário em reais acompanha o câmbio? | fator externo (API, Etapa 6); **em branco até a API carregar dados** |
| Dica Vaga, Detalhe da Vaga, Conferência (oculta) | apoio | |

## Fonte e conexão
- Banco: `../02-bancodedados-sql/recrutamento.db` (SQLite), via ODBC (driver SQLite3, 64 bits); DSN de usuário `recrutamento`; parâmetros `pConexaoODBC` e `pMoeda`.
- Importado: views `dim_cargo`, `dim_tecnologia`, `dim_empresa`, `dim_tempo`, `fato_vagas` + tabela `cotacao_dia` (como `dim_cotacao`). Modo Importar. Nenhum dado digitado no Power BI.
- **Alternativa sem ODBC** (`m/alternativa_csv/` + `dados/`): usar somente se o driver não puder ser instalado, e registrar aqui a escolha feita: ☐ ODBC ☐ alternativa CSV.

## Modelo
6 tabelas + `_Medidas`; relacionamentos R1–R5 (N:1, direção única); `dim_tempo` marcada como tabela de datas. Diagrama: `docs/diagrama_modelo.png`; detalhes e correspondência de nomes Etapa III → banco → Power BI em `docs/modelo_powerbi.md`.

## Conteúdo da pasta
| Item | Conteúdo | Situação |
|---|---|---|
| `m/*.pq` | parâmetros, 6 consultas M e `tst_Conexao` (ODBC, `en-US`); `m/alternativa_csv/` | pronto |
| `dados/*.csv` | views exportadas (só para a alternativa sem ODBC); `cotacao_dia.csv` vazio | pronto |
| `dax/medidas_finais.dax` | 35 medidas DAX (`DEFINE MEASURE`) | pronto |
| `dax/validacao.dax` | 9 consultas DAX (V-K, V-C1 a V-C5, V-FJ, V-CAMBIO, V-CONF) | pronto |
| `tema/tema_recrutamento.json` | tema de cores e fontes | pronto |
| `docs/` | `modelo_powerbi.md`, `diagrama_modelo.png/.mmd`, `roteiro_painel.md` | pronto |
| `evidencias/valores_esperados_sql.txt` | gabarito gerado por SQL real | pronto |
| `evidencias/validacao_resultados.md`, `p1…p3.png`, `detalhe_vaga.png`, `conferencia.png` | resultados e capturas | **a produzir no Power BI** |
| `Recrutamento_Dashboard.pbix` e `.pdf` | painel e exportação | **a produzir no Power BI** |

## O que os dados mostram (gabarito SQL; não é conclusão final)
- 16 vagas válidas; 12 são Júnior e **6 (50,0%)** exigem mais de 3 tecnologias.
- Júnior pedem em média **4,33 tecnologias** contra o teto de 3; Estágio, Pleno e Sênior ficam abaixo do teto.
- Falso Júnior: **6,17 tecnologias** em média; Júnior dentro do limite: **2,50**.
- A média salarial Júnior (R$ 5.766,67) é puxada pela VAG-016 (R$ 25.000). Mediana Júnior: **R$ 4.150,00**. Sem essa vaga, Falso Júnior paga R$ 3.780,00 contra R$ 4.216,67 dos Júnior dentro do limite.
- Mercado Livre é a única empresa reincidente (2 vagas Falso Júnior). Base pequena: nada aqui indica tendência.

## Batimento (preencher com os valores do seu arquivo)
| Indicador | Etapa III (painel) | Etapa IV (SQL) | Power BI | Diferença |
|---|---|---|---|---|
| Total de vagas | 16 | K4 16 | ☐ | ☐ |
| Salário médio | R$ 6.075,00 | K4 6075,00 | ☐ | ☐ |
| Média de tecnologias | 3,9375 | K4 3,9375 | ☐ | ☐ |
| Vagas Falso Júnior | 6 | C3 6 | ☐ | ☐ |
| Vagas Júnior | 11 ⚠ | C2 12 | ☐ | ☐ |
| Média techs Júnior | 4,54 ⚠ | C2 4,33 | ☐ | ☐ |
| Salário médio Júnior | R$ 5.736,36 ⚠ | C2 5.766,67 | ☐ | ☐ |
| Taxa Falso Júnior | 54,5% ⚠ | C3 50,0% | ☐ | ☐ |

⚠ A divergência está na Etapa III (painel e `modelo_relacional.md`), não no banco; o banco foi conferido com a Etapa 2 (K1 = 0). O Power BI deve bater com a **coluna SQL**. Os resultados de cada bloco de `dax/validacao.dax` vão em `evidencias/validacao_resultados.md`.

## Decisões registradas
- Falso Júnior calculado pela regra explícita (`CARG-JR` e mais de 3 tecnologias); `[Conf FJ Regra x Flag]` prova que bate com `is_falso_junior`.
- Medidas "Júnior" da Etapa III reescritas: o `RELATED()` dentro do filtro do `CALCULATE` não filtrava.
- Salário médio acompanhado do **mediano** por causa de um valor atípico (VAG-016); a vaga não é removida.
- `dim_cotacao` carrega uma moeda por vez (`pMoeda`, padrão USD) e liga-se à fato pela chave `chave_cambio`, sem relação com `dim_tempo`; `[Cotação Média]` usa `TREATAS`.
- Linhas rejeitadas na Etapa 2 ficam fora do painel (C6 só no banco).
- Câmbio **sem dados**: página 3 com faixa de aviso (`[Aviso Câmbio]`); nenhuma conclusão sobre salário × câmbio até a API (Etapa 6).

## Pendências herdadas
- Painel da Etapa 3, README da Etapa 2 (11/9/20 × 16/5/21) e `modelo_relacional.md` com números diferentes do banco (ver `../02-bancodedados-sql/README.md`).
- API AwesomeAPI (`03-api-web`) ainda não carregou `cotacao_dia`.

## Tabela de conferência da entrega (guia, Seção 9.7)
Só marcar **Concluído** depois de executar a verificação no arquivo.

| # | Item | Como verificar | Status |
|---|---|---|---|
| 1 | `Recrutamento_Dashboard.pbix` na pasta | Explorador de Arquivos | Não iniciado |
| 2 | Fonte única: banco via `pConexaoODBC` | Transformar dados → parâmetro | Não iniciado |
| 3 | Tipos com localidade `en-US` | Editor Avançado | Pronto no código (`m/`); verificar no arquivo |
| 4 | 6 tabelas + `_Medidas`, sem `LocalDateTable` | painel Dados | Não iniciado |
| 5 | Contagens 4 / 15 / 15 / 181 / 16 / 0 | exibição Tabela e `tst_Conexao` | Não iniciado |
| 6 | Relacionamentos R1–R5 ativos, N:1, única | Gerenciar relações | Não iniciado |
| 7 | `dim_tempo` como tabela de datas | ícone de calendário | Não iniciado |
| 8 | Medidas da especificação | `dax/medidas_finais.dax` | Pronto (35 medidas); gravar no modelo |
| 9 | Conferência zerada | página Conferência, V-CONF | Não iniciado (`Conf Vagas sem Cotação` = 16 até a API) |
| 10 | Batimento com o SQL | V-K, V-C1 a V-C5 | Não iniciado |
| 11 | Três páginas | navegar | Não iniciado |
| 12 | Interatividade (segmentações sincronizadas, interações) | checklist 9.5 | Não iniciado |
| 13 | Dica de ferramenta e detalhamento | mouse e botão direito | Não iniciado |
| 14 | Linhagem funciona | Seção 9.4 | Não iniciado |
| 15 | PDF, `docs/`, `evidencias/`, README | pasta | Parcial (falta PDF e capturas) |
| 16 | Escopo respeitado | ler consultas e medidas | Pronto: nada digitado no Power BI; câmbio sinalizado como sem dados |

**Observação:** os números do gabarito vêm de execução SQL real; as consultas DAX ainda não foram executadas no Power BI Desktop. Pelo guia, o painel também deve abrir no computador de outro integrante (DSN `recrutamento` criada na máquina dele).
