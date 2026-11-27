# Modelo relacional – Banco `recrutamento` (Etapa IV)

Diagrama: `diagrama_er.png`. Evento medido: **vaga publicada** (sem itens → uma única tabela de fato, conforme o Apêndice F do guia).

| Tabela | Chave primária | Chaves estrangeiras | Restrições |
|---|---|---|---|
| `cargo` | `cod_cargo` | – | `senioridade` única; piso > 0 e teto ≥ piso; `max_techs_recomendado` > 0 |
| `tecnologia` | `cod_tech` | – | `nome_tecnologia` única; `nivel_complexidade` ∈ {Básica, Média, Avançada} |
| `empresa` | `cod_empresa` | – | `nome_empresa` única |
| `calendario` | `data` | – | 181 dias contínuos (01/01 a 30/06/2026); 6 feriados |
| `vaga` (fato) | `id_vaga` | `cod_empresa`, `cod_cargo`, `cod_tech`, `data_publicacao` → `calendario` | `qtd_tecnologias` > 0; `salario_oferecido` > 0; modalidade ∈ {Remoto, Híbrido, Presencial}; flag ∈ {Não, SIM (Falso Jr)} |
| `vaga_rejeitada` | `id_vaga` | – (de propósito) | guarda o motivo das 5 linhas descartadas na Etapa 2 |
| `cotacao_dia` | `moeda` + `data_ref` | – | vazia; recebe a API de câmbio (Etapa VI) |

**Normalização:** as dimensões guardam atributos do cargo/tecnologia/empresa uma única vez; `vaga` só tem fatos e chaves (3FN). A regra "Falso Júnior" (cargo Júnior e mais de 3 tecnologias) é conferida em K3.

**Views para o Power BI:** `dim_cargo`, `dim_tecnologia`, `dim_empresa`, `dim_tempo`, `fato_vagas` (com `is_falso_junior`, `excesso_techs`, `situacao_salarial`, `turno`) e `fato_rejeitadas`.
