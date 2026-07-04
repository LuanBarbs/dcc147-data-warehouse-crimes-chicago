import os
import psycopg2
import pandas as pd
from psycopg2 import sql
from dotenv import load_dotenv

load_dotenv()

DB = dict(
    host=os.getenv("DB_HOST"),
    port=os.getenv("DB_PORT"),
    dbname=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD")
)
CSV_PATH = "data/Crimes_-_2001_to_Present.csv"
TABELA = "crimes_raw"
CHUNKSIZE = 500_000

total_linhas = sum(1 for _ in open(CSV_PATH, encoding="utf-8")) - 1
print(f"Total de linhas no CSV: {total_linhas:,}")

conn = psycopg2.connect(**DB)
cur = conn.cursor()

primeiro_chunk = next(pd.read_csv(CSV_PATH, chunksize=1))
colunas = primeiro_chunk.columns.tolist()

cols_sql = ", ".join(f'"{c}" TEXT' for c in colunas)
cur.execute(f'DROP TABLE IF EXISTS {TABELA}; CREATE TABLE {TABELA} ({cols_sql});')
conn.commit()
print("Tabela criada.")

for i, chunk in enumerate(pd.read_csv(CSV_PATH, chunksize=CHUNKSIZE, low_memory=False)):
    chunk = chunk.where(pd.notnull(chunk), None)  # NaN → NULL
    rows = [tuple(r) for r in chunk.itertuples(index=False)]
    placeholders = "(" + ",".join(["%s"] * len(colunas)) + ")"
    cur.executemany(f'INSERT INTO {TABELA} VALUES {placeholders}', rows)
    conn.commit()
    print(f"Chunk {i+1} carregado ({(i+1)*CHUNKSIZE:,} linhas aprox.)")

cur.close()
conn.close()
print("Carga concluída.")