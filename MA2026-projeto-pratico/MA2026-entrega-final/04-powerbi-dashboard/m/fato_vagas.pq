// fato_vagas -- view fato_vagas da Etapa IV. Nenhuma regra de limpeza aqui.
let
    Fonte = Odbc.Query(pConexaoODBC,
        "SELECT id_vaga, data, hora, cod_empresa, cod_cargo, cod_tech, qtd_tecnologias, salario_oferecido, modalidade, canal_divulgacao, flag_falso_junior, is_falso_junior, max_techs_recomendado, excesso_techs, situacao_salarial, turno
          FROM fato_vagas"),
    Tipos = Table.TransformColumnTypes(Fonte, {
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
