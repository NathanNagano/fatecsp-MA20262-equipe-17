"""Executa a Etapa IV do zero: cria o banco, importa os CSVs da Etapa 2 para
as tabelas de staging (o que o DB4S faz com Arquivo > Importar), roda DDL,
carga, views, conferência e consultas, e grava a saída em evidencias/.
Uso:  python3 executar.py
"""
import csv, sqlite3, pathlib, sys, io

AQUI = pathlib.Path(__file__).parent
DB = AQUI / "recrutamento.db"
STG = {"stg_vagas": "fvagas", "stg_cargo": "dcargo", "stg_tecnologia": "dtecnologia",
       "stg_empresa": "dempresa", "stg_rejeitados": "rejeitados"}

def rodar(con, arquivo):
    return con.executescript((AQUI / arquivo).read_text(encoding="utf-8"))

def mostrar(con, sql, out):
    """Executa cada instrução do script e imprime o resultado em tabela."""
    buf = []
    for stmt in [s.strip() for s in sql.split(";") if s.strip()]:
        # remove linhas de comentário antes do SQL
        linhas = [l for l in stmt.splitlines()]
        comentarios = [l for l in linhas if l.strip().startswith("--")]
        corpo = "\n".join(l for l in linhas if not l.strip().startswith("--")).strip()
        if not corpo: continue
        for c in comentarios: buf.append(c)
        cur = con.execute(corpo)
        if cur.description:
            cols = [d[0] for d in cur.description]
            rows = cur.fetchall()
            larg = [max(len(str(x)) for x in [c] + [r[i] for r in rows]) for i, c in enumerate(cols)]
            buf.append(" | ".join(str(c).ljust(larg[i]) for i, c in enumerate(cols)))
            buf.append("-+-".join("-" * w for w in larg))
            for r in rows:
                buf.append(" | ".join(str("" if x is None else x).ljust(larg[i]) for i, x in enumerate(r)))
            buf.append(f"({len(rows)} linha(s))\n")
        else:
            buf.append("(sem linhas)\n")
    out.write("\n".join(buf) + "\n")

def main():
    if DB.exists(): DB.unlink()
    con = sqlite3.connect(DB)
    con.execute("PRAGMA foreign_keys = ON")
    rodar(con, "recrutamento_ddl.sql")
    for tab, arq in STG.items():
        with open(AQUI / "csv" / f"{arq}.csv", encoding="utf-8", newline="") as f:
            r = csv.reader(f); next(r)
            linhas = [row for row in r]
        con.executemany(f"INSERT INTO {tab} VALUES ({','.join('?' * len(linhas[0]))})", linhas)
    con.commit()
    rodar(con, "recrutamento_carga.sql")
    rodar(con, "recrutamento_views.sql")
    con.commit()
    ev = AQUI / "evidencias"; ev.mkdir(exist_ok=True)
    for nome in ("conferencia", "consultas"):
        with open(ev / f"saida_{nome}.txt", "w", encoding="utf-8") as out:
            sql = (AQUI / f"recrutamento_{nome}.sql").read_text(encoding="utf-8")
            if nome == "conferencia":
                # PRAGMA foreign_key_check e EXPLAIN também devolvem linhas
                pass
            mostrar(con, sql, out)
    con.close()
    print("OK ->", DB)

if __name__ == "__main__":
    main()
