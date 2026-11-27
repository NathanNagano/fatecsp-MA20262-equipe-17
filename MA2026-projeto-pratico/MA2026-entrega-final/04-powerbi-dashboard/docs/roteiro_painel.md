# Roteiro para montar o painel no Power BI Desktop

Siga na ordem. Arquivo final: **`Recrutamento_Dashboard.pbix`** nesta pasta. Detalhes de cada etapa estão no guia da Etapa V (Seções 2 a 9); aqui estão os nomes e campos do nosso tema.

## 1. Preparar o ambiente (guia, Seção 2)
- Power BI Desktop atualizado; **desligar** detecção automática de relacionamentos e data/hora automática (Opções → Carregamento de dados).
- Instalar o driver *SQLite3 ODBC* (64 bits) e criar um **DSN de usuário** `recrutamento` (Fontes de Dados ODBC 64 bits) apontando para `02-bancodedados-sql/recrutamento.db`, com **No Creat** marcado.
- Sem permissão para instalar o driver: usar `m/alternativa_csv/` (guia, Seção 3.6) e **registrar a escolha no README**.

## 2. Importar (guia, Seção 3) — `m/`
1. Transformar dados → Gerenciar Parâmetros: criar `pConexaoODBC` (`dsn=recrutamento`) e `pMoeda` (`USD`).
2. Para cada arquivo de `m/` (`dim_cargo`, `dim_tecnologia`, `dim_empresa`, `dim_tempo`, `fato_vagas`, `dim_cotacao`, `tst_Conexao`): Nova Fonte → Consulta em Branco → Editor Avançado → colar → nomear a consulta com o nome exato do arquivo.
3. Grupos: `01_Parametros`, `02_Dimensoes`, `03_Fatos`, `99_Diagnostico` (`tst_Conexao`). Desmarcar *Habilitar carga* de `pConexaoODBC`, `pMoeda` e `tst_Conexao`.
4. Fechar e Aplicar. Exibição Tabela: **4 / 15 / 15 / 181 / 16 / 0** (`dim_cotacao` vazia até a API). Nenhuma `LocalDateTable_...`.

## 3. Modelo (guia, Seção 4) — ver `docs/modelo_powerbi.md`
Criar R1 a R5 (N:1, única, ativos), marcar `dim_tempo` como tabela de datas, classificar colunas, ocultar colunas técnicas, hierarquia Calendário, tabela `_Medidas` (Inserir dados, vazia). Teste de fumaça: tabela `dim_cargo[senioridade]` × contagem de `fato_vagas[id_vaga]` → total 16.

## 4. Medidas (guia, Seção 5)
Exibição de Consulta DAX → colar `dax/medidas_finais.dax` → executar → **Atualizar modelo com alterações**. Formatar (R$, `0,0%`, `0,00`) e organizar em pastas de exibição (Volume, Júnior, Falso Júnior, Real x Esperado, Tempo, Câmbio, Rótulos, Conferência). Tema: Exibição → Temas → `tema/tema_recrutamento.json`.

## 5. Páginas (guia, Seção 6)
### Página 1 – Visão Executiva ("Como está o mercado de entrada?")
| Visual | Configuração |
|---|---|
| V1 Cartão (5 KPIs) | `Total de Vagas`, `Salário Médio`, `Média Techs`, `Vagas Falso Júnior`, `Taxa Falso Júnior`. Título → fx → `[Título Executiva]`; subtítulo → `[Período Selecionado]` |
| V2 Colunas e linha | Eixo `dim_tempo[nome_mes]`; colunas `Total de Vagas`; linha `Vagas Falso Júnior`. *O fenômeno cresce ao longo do semestre?* |
| V3 Barras | Eixo `fato_vagas[canal_divulgacao]`; valor `Taxa Falso Júnior`; cor → campo `[Cor Taxa FJ]`. Linhas constantes 30% e 50%. *Em que canais as vagas Júnior mais inflam os requisitos?* |
| V4 Matriz (real × esperado) | Linhas `dim_cargo[senioridade]`; valores `Total de Vagas`, `Média Techs`, `Teto de Techs`, `Excesso Médio de Techs`, `Salário Médio`. Formatação condicional no excesso (> 0 vermelho) |
| V5 Matriz (mapa de calor) | Linhas `dim_empresa[setor]`, colunas `dim_tempo[nome_mes]`, valor `Vagas Falso Júnior`, gradiente |
| Segmentações | `dim_tempo[nome_mes]`, `fato_vagas[modalidade]`, `fato_vagas[canal_divulgacao]`; navegador de páginas |

### Página 2 – Tecnologias & Salário ("O que se exige e quanto se paga?")
| Visual | Configuração |
|---|---|
| V1 Barras | `dim_tecnologia[nome_tecnologia]` × `Total de Vagas`, filtro Top 10; dica `Salário Médio` (= C1) |
| V2 Treemap | `dim_tecnologia[categoria]` × `Total de Vagas` |
| V3 Dispersão | X `fato_vagas[qtd_tecnologias]`, Y `fato_vagas[salario_oferecido]` (sem agregar), detalhes `id_vaga`, legenda `situacao_salarial`; linha de tendência. Destaca o ponto de R$ 25.000 |
| V4 Barras agrupadas | Eixo `dim_tempo[nome_mes]`: `Salário Médio Falso Júnior` × `Salário Médio Júnior Dentro do Limite` |
| V5 Tabela | `dim_empresa[nome_empresa]`, `setor`, `Vagas Falso Júnior`, `Média Techs`; filtro do visual `Vagas Falso Júnior` ≥ 2 (= C5; aparece Mercado Livre) |
| V6 Cartões | `Média Techs Falso Júnior` (6,17), `Média Techs Júnior Dentro do Limite` (2,50), `Salário Mediano Júnior` (R$ 4.150) |

### Página 3 – Câmbio & Salário (fator externo; análoga a "Clima & Consumo")
Responde: *o salário oferecido em reais acompanha o câmbio?* Dados da API AwesomeAPI (Etapa 6).
| Visual | Configuração |
|---|---|
| Faixa de aviso | Caixa de texto âmbar-claro com o valor de `[Aviso Câmbio]` (some sozinho quando houver cotações) |
| V1 Linha (dois eixos) | Eixo `dim_tempo[data]`; Y `Salário Médio`; Y secundário `Cotação Média` |
| V2 Dispersão | Detalhes `dim_tempo[nome_mes]`; X `Cotação Média`; Y `Salário Médio em Moeda Estrangeira` |
| V3 Cartões | `Cotação Média`, `Salário Médio em Moeda Estrangeira`, `Salário Médio Júnior em Moeda Estrangeira` |
| Segmentações | `dim_tempo[nome_mes]`, `fato_vagas[modalidade]` (sincronizadas) |

**Não tirar conclusões da página 3 antes de a API carregar dados reais** (guia, Seção 6.4). Com `dim_cotacao` vazia, os visuais ficam em branco e a faixa de aviso aparece.

### Apoio: Dica de ferramenta, Detalhe e Conferência (guia, Seções 6.5, 7.7 e 9.3)
- **Dica Vaga** (tooltip, 320×240): `Total de Vagas`, `Salário Médio`, `Média Techs`, `Taxa Falso Júnior`; associar aos visuais V3 da página 1 e V1 da página 2.
- **Detalhe da Vaga** (drill-through por `fato_vagas[id_vaga]`): `data`, `dim_empresa[nome_empresa]`, `modalidade`, `canal_divulgacao`, `qtd_tecnologias`, `salario_oferecido`, `situacao_salarial`, `turno`.
- **Conferência** (oculta): cartões das 6 medidas `Conf ...` e de `Total de Vagas` (16) e `Vagas Falso Júnior` (6). Todas 0, exceto `Conf Vagas sem Cotação` (= 16 até a API).

## 6. Interatividade (guia, Seção 7)
Segmentações sincronizadas nas 3 páginas (Exibição → Sincronizar segmentações); editar interações (V2 da página 1 não filtra a matriz V4); painel Filtros com bloqueio; drill-down na hierarquia Calendário; botões de navegação e indicador de "limpar filtros".

## 7. Conferência (guia, Seção 9)
1. Executar cada bloco de `dax/validacao.dax` e comparar com `evidencias/valores_esperados_sql.txt`; registrar em `evidencias/validacao_resultados.md`.
2. Teste de linhagem (Seção 9.4): alterar um valor na origem (cópia), Atualizar, ver mudar no painel; desfazer.
3. Checklist de integridade visual (Seção 9.5).
4. Evidências em `evidencias/`: `p1_visao_executiva.png`, `p2_tecnologias_salario.png`, `p3_cambio_salario.png`, `detalhe_vaga.png`, `conferencia.png`, `validacao_resultados.md`.
5. Arquivo → Exportar → PDF → `Recrutamento_Dashboard.pdf`; `docs/diagrama_modelo.png` já está pronto.
6. Fechar o Power BI e fazer o commit (cada integrante com commits próprios).

## 8. Erros comuns
| Sintoma | Causa e correção |
|---|---|
| ODBC `IM002` | DSN criada no administrador de 32 bits ou como DSN de sistema/outro usuário: recriar em 64 bits, DSN de usuário `recrutamento` |
| Salário 10× maior | conversão sem localidade `en-US` (ponto decimal lido como milhar); manter `"en-US"` em todas as consultas |
| Meses fora de ordem | `nome_mes` sem classificar por `mes` |
| Medida Júnior vazia | texto diferente: em `dim_cargo[senioridade]` é `Júnior` (com acento) |
| Relação tracejada (inativa) | ligação extra entre `dim_cotacao[data_ref]` e `dim_tempo[data]`: apagar; a ligação correta é só `chave_cambio` |
| Cartões diferentes do gabarito | segmentação ativa ou filtro de página esquecido |
| Maio/junho vazios | normal: calendário até 30/06, vagas só de janeiro a abril |
