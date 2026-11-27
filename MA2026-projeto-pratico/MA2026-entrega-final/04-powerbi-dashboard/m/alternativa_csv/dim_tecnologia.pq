// dim_tecnologia -- ALTERNATIVA sem ODBC: lê dados\dim_tecnologia.csv (exportado do banco da Etapa IV)
// Pré-requisito: parâmetro pPasta (caminho da pasta dados\, terminado em barra).
let
    Fonte = Csv.Document(File.Contents(pPasta & "dim_tecnologia.csv"),
                [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Cab = Table.PromoteHeaders(Fonte, [PromoteAllScalars = true]),
    Tipos = Table.TransformColumnTypes(Cab, {
        {"cod_tech", type text},
        {"nome_tecnologia", type text},
        {"categoria", type text},
        {"nivel_complexidade", type text}
    }, "en-US")
in
    Tipos
