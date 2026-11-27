// tst_Conexao -- diagnóstico (Habilitar carga DESMARCADO): contagens esperadas
// dim_cargo 4 | dim_tecnologia 15 | dim_empresa 15 | dim_tempo 181 | fato_vagas 16 | cotacao_dia 0 (até a API)
let
    Fonte = Odbc.Query(pConexaoODBC,
        "SELECT 'dim_cargo' AS tabela, COUNT(*) AS linhas FROM dim_cargo
         UNION ALL SELECT 'dim_tecnologia', COUNT(*) FROM dim_tecnologia
         UNION ALL SELECT 'dim_empresa', COUNT(*) FROM dim_empresa
         UNION ALL SELECT 'dim_tempo', COUNT(*) FROM dim_tempo
         UNION ALL SELECT 'fato_vagas', COUNT(*) FROM fato_vagas
         UNION ALL SELECT 'cotacao_dia', COUNT(*) FROM cotacao_dia"),
    Tipos = Table.TransformColumnTypes(Fonte, {{"tabela", type text}, {"linhas", Int64.Type}}, "en-US")
in
    Tipos
