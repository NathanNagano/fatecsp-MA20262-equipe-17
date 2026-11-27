// dim_cargo -- ALTERNATIVA sem ODBC: lê dados\dim_cargo.csv (exportado do banco da Etapa IV)
// Pré-requisito: parâmetro pPasta (caminho da pasta dados\, terminado em barra).
let
    Fonte = Csv.Document(File.Contents(pPasta & "dim_cargo.csv"),
                [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Cab = Table.PromoteHeaders(Fonte, [PromoteAllScalars = true]),
    Tipos = Table.TransformColumnTypes(Cab, {
        {"cod_cargo", type text},
        {"senioridade", type text},
        {"salario_piso", Currency.Type},
        {"salario_teto", Currency.Type},
        {"max_techs_recomendado", Int64.Type},
        {"descricao", type text}
    }, "en-US")
in
    Tipos
