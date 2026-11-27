# 02 – Banco de Dados & SQL (Etapa IV)

**Disciplina:** Microinformática Aplicada (ILP590) – FATEC São Paulo • **Equipe 17**
**Integrantes:** Nathan Campos Nagano, Matheus Guides Rubim Fonseca e João Wictor Leles Santos (RA 22106946 – Etapa IV)
**Projeto:** Painel de Decisão para Recrutamento de Entrada (O Fenômeno do "Falso Júnior")
**SGBD:** SQLite 3 (sintaxe compatível com MySQL 8) • **Entrega final (N2):** 27/11/2026

## O que o banco faz
Persiste em um modelo relacional os dados tratados na Etapa 2 (Power Query) e responde, com SQL, à pergunta central do projeto: *qual a discrepância entre as tecnologias exigidas e o salário oferecido nas vagas de entrada?* As regras de qualidade que antes eram conferidas depois (quantidade zero, empresa inexistente, data inválida) passam a ser **impostas pelo banco** (PK, FK, CHECK).

## Arquivos
| Arquivo | Conteúdo |
|---|---|
| `recrutamento.db` | Banco SQLite pronto (6 tabelas + `cotacao_dia`, 5 staging, 5 índices, 6 views) |
| `recrutamento_ddl.sql` | Estrutura: tabelas, `pk_`/`fk_`/`ck_`/`uq_` nomeadas, índices, staging |
| `recrutamento_carga.sql` | Carga (DML) staging → tabelas finais, reexecutável; calendário gerado em SQL |
| `recrutamento_consultas.sql` | 6 consultas de análise (C1–C6) |
| `recrutamento_views.sql` | Camada estrela para o Power BI (Etapa V) |
| `recrutamento_conferencia.sql` | Batimento com as Etapas 2 e 3 e testes de integridade |
| `executar.py` | Refaz tudo do zero (importa os CSVs, roda os 4 scripts, grava as saídas) |
| `csv/` | Tabelas da Etapa 2 exportadas de `Recrutamento_02_PowerQuery.xlsx` (UTF-8) |
| `docs/` | `modelo_relacional.md` e `diagrama_er.png` |
| `evidencias/` | Saídas reais da execução e `Evidencias_Etapa_IV.pdf` (hardcopy) |

## Como reproduzir
```bash
python3 executar.py          # cria recrutamento.db e grava evidencias/saida_*.txt
```
No DB Browser for SQLite: abrir `recrutamento.db`, ou criar um banco novo, executar `recrutamento_ddl.sql`, importar os 5 CSVs de `csv/` nas tabelas `stg_*` e executar `recrutamento_carga.sql` e `recrutamento_views.sql`.

## Resultado da conferência (resumo)
- **K1 (Etapa 2 × banco):** todas as diferenças = **0** (16 vagas válidas, 5 rejeitadas; 16 + 5 = 21 lidas).
- **K2 (FK):** `PRAGMA foreign_key_check` não devolve linhas. **K3 (órfãs):** tudo 0.
- **Regras impostas pelo banco:** 7 `INSERT` inválidos foram recusados (`evidencias/saida_testes_integridade.txt`).
- **Carga reexecutável:** segunda execução mantém os mesmos números.

## ⚠ Divergências encontradas nas etapas anteriores (precisam de decisão da equipe)
O banco foi montado **a partir dos dados da Etapa 2** (`fVagas`: 16 linhas). Ao conferir contra o painel da Etapa 3, quatro indicadores **Júnior** não batem (K4):

| Indicador | Painel Etapa 3 | Calculado dos dados (banco) |
|---|---|---|
| Vagas Júnior (denominador) | 11 | **12** (VAG-001, 003, 004, 005, 009, 011, 014, 016, 017, 019, 020, 021) |
| Média de techs Júnior | 4,54 | **4,33** |
| Salário médio Júnior | R$ 5.736,36 | **R$ 5.766,67** |
| Taxa de requisitos inflacionados | 54,5% | **50,0%** (6 de 12) |

Os indicadores gerais (16 vagas, salário médio R$ 6.075, 3,9375 techs, 6 falso júnior) **batem**. Também: a tabela cruzada do painel soma "15" vagas (o correto é 16), e o `README.md` da Etapa 2 declara 11 válidas / 9 rejeitadas / 20 lidas, enquanto a planilha tem **16 / 5 / 21**. Sugere-se corrigir o painel da Etapa 3, o README da Etapa 2 e `modelo_relacional.md` (que cita 4,54 e 54,5%) antes da entrega consolidada.

## Escopo respeitado
Sem dados corrigidos à mão; sem painel (Etapa V); `cotacao_dia` criada **vazia**, reservada para a API AwesomeAPI (USD/EUR → BRL). As evidências foram geradas por execução em linha de comando (Python `sqlite3`), não por capturas do DB4S.
