// dim_cotacao -- ALTERNATIVA sem ODBC: lê dados\cotacao_dia.csv (exportado do banco da Etapa IV)
// Pré-requisito: parâmetro pPasta (caminho da pasta dados\, terminado em barra).
let
    Fonte = Csv.Document(File.Contents(pPasta & "cotacao_dia.csv"),
                [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Cab = Table.PromoteHeaders(Fonte, [PromoteAllScalars = true]),
    Moeda = Table.SelectRows(Cab, each [moeda] = pMoeda),
    Tipos = Table.TransformColumnTypes(Moeda, {
        {"moeda", type text},
        {"data_ref", type date},
        {"cotacao_compra", Currency.Type},
        {"cotacao_venda", Currency.Type}
    }, "en-US"),
    ComChave = Table.AddColumn(Tipos, "chave_cambio",
        each Date.ToText([data_ref], [Format = "yyyy-MM-dd", Culture = "en-US"]), type text)
in
    ComChave
