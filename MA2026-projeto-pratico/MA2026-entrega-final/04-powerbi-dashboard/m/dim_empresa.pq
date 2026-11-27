// dim_empresa -- view dim_empresa da Etapa IV. Nenhuma regra de limpeza aqui.
let
    Fonte = Odbc.Query(pConexaoODBC,
        "SELECT cod_empresa, nome_empresa, porte, setor, estado
          FROM dim_empresa"),
    Tipos = Table.TransformColumnTypes(Fonte, {
        {"cod_empresa", type text},
        {"nome_empresa", type text},
        {"porte", type text},
        {"setor", type text},
        {"estado", type text}
    }, "en-US")
in
    Tipos
