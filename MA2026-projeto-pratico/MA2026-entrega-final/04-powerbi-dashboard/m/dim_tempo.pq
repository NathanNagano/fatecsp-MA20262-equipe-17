// dim_tempo -- view dim_tempo da Etapa IV. Nenhuma regra de limpeza aqui.
let
    Fonte = Odbc.Query(pConexaoODBC,
        "SELECT data, ano, mes, nome_mes, ano_mes, trimestre, dia_semana, nome_dia, fim_de_semana, feriado
          FROM dim_tempo"),
    Tipos = Table.TransformColumnTypes(Fonte, {
        {"data", type date},
        {"ano", Int64.Type},
        {"mes", Int64.Type},
        {"nome_mes", type text},
        {"ano_mes", type text},
        {"trimestre", type text},
        {"dia_semana", Int64.Type},
        {"nome_dia", type text},
        {"fim_de_semana", type text},
        {"feriado", type text}
    }, "en-US")
in
    Tipos
