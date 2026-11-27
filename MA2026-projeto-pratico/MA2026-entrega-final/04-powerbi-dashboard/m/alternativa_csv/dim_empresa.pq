// dim_empresa -- ALTERNATIVA sem ODBC: lê dados\dim_empresa.csv (exportado do banco da Etapa IV)
// Pré-requisito: parâmetro pPasta (caminho da pasta dados\, terminado em barra).
let
    Fonte = Csv.Document(File.Contents(pPasta & "dim_empresa.csv"),
                [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Cab = Table.PromoteHeaders(Fonte, [PromoteAllScalars = true]),
    Tipos = Table.TransformColumnTypes(Cab, {
        {"cod_empresa", type text},
        {"nome_empresa", type text},
        {"porte", type text},
        {"setor", type text},
        {"estado", type text}
    }, "en-US")
in
    Tipos
