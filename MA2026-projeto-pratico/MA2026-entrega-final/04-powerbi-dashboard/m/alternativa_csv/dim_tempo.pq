// dim_tempo -- ALTERNATIVA sem ODBC: lê dados\dim_tempo.csv (exportado do banco da Etapa IV)
// Pré-requisito: parâmetro pPasta (caminho da pasta dados\, terminado em barra).
let
    Fonte = Csv.Document(File.Contents(pPasta & "dim_tempo.csv"),
                [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Cab = Table.PromoteHeaders(Fonte, [PromoteAllScalars = true]),
    Tipos = Table.TransformColumnTypes(Cab, {
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
