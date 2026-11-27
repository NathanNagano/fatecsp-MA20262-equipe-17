// dim_cotacao -- tabela cotacao_dia da Etapa IV (API AwesomeAPI, Etapa 6): uma moeda por vez
// pMoeda (padrão "USD") garante uma linha por data, requisito do lado 1 do relacionamento R5.
// Enquanto a API não carrega dados, a tabela chega VAZIA (0 linhas) e o painel mostra o aviso.
let
    Fonte = Odbc.Query(pConexaoODBC,
        "SELECT moeda, data_ref, cotacao_compra, cotacao_venda
          FROM cotacao_dia WHERE moeda = '" & pMoeda & "'"),
    Tipos = Table.TransformColumnTypes(Fonte, {
        {"moeda", type text},
        {"data_ref", type date},
        {"cotacao_compra", Currency.Type},
        {"cotacao_venda", Currency.Type}
    }, "en-US"),
    // chave_cambio = aaaa-mm-dd (idêntica à de fato_vagas)
    ComChave = Table.AddColumn(Tipos, "chave_cambio",
        each Date.ToText([data_ref], [Format = "yyyy-MM-dd", Culture = "en-US"]), type text)
in
    ComChave
