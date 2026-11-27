// fato_vagas -- ALTERNATIVA sem ODBC: lê dados\fato_vagas.csv (exportado do banco da Etapa IV)
// Pré-requisito: parâmetro pPasta (caminho da pasta dados\, terminado em barra).
let
    Fonte = Csv.Document(File.Contents(pPasta & "fato_vagas.csv"),
                [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Cab = Table.PromoteHeaders(Fonte, [PromoteAllScalars = true]),
    Tipos = Table.TransformColumnTypes(Cab, {
        {"id_vaga", type text},
        {"data", type date},
        {"hora", type time},
        {"cod_empresa", type text},
        {"cod_cargo", type text},
        {"cod_tech", type text},
        {"qtd_tecnologias", Int64.Type},
        {"salario_oferecido", Currency.Type},
        {"modalidade", type text},
        {"canal_divulgacao", type text},
        {"flag_falso_junior", type text},
        {"is_falso_junior", Int64.Type},
        {"max_techs_recomendado", Int64.Type},
        {"excesso_techs", Int64.Type},
        {"situacao_salarial", type text},
        {"turno", type text}
    }, "en-US"),
    // chave_cambio = aaaa-mm-dd (liga a vaga à cotação do dia; mesma regra de dim_cotacao)
    ComChave = Table.AddColumn(Tipos, "chave_cambio",
        each Date.ToText([data], [Format = "yyyy-MM-dd", Culture = "en-US"]), type text)
in
    ComChave
