// dim_tecnologia -- view dim_tecnologia da Etapa IV. Nenhuma regra de limpeza aqui.
let
    Fonte = Odbc.Query(pConexaoODBC,
        "SELECT cod_tech, nome_tecnologia, categoria, nivel_complexidade
          FROM dim_tecnologia"),
    Tipos = Table.TransformColumnTypes(Fonte, {
        {"cod_tech", type text},
        {"nome_tecnologia", type text},
        {"categoria", type text},
        {"nivel_complexidade", type text}
    }, "en-US")
in
    Tipos
