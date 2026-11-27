// dim_cargo -- view dim_cargo da Etapa IV. Nenhuma regra de limpeza aqui.
let
    Fonte = Odbc.Query(pConexaoODBC,
        "SELECT cod_cargo, senioridade, salario_piso, salario_teto, max_techs_recomendado, descricao
          FROM dim_cargo"),
    Tipos = Table.TransformColumnTypes(Fonte, {
        {"cod_cargo", type text},
        {"senioridade", type text},
        {"salario_piso", Currency.Type},
        {"salario_teto", Currency.Type},
        {"max_techs_recomendado", Int64.Type},
        {"descricao", type text}
    }, "en-US")
in
    Tipos
