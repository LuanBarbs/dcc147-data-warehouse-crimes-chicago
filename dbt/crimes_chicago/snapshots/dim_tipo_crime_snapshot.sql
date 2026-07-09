{% snapshot dim_tipo_crime_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='iucr',
        strategy='check',
        check_cols=['primary_type', 'description', 'fbi_code'],
        invalidate_hard_deletes=True
    )
}}

-- SCD Tipo 2 nativo do dbt: a cada "dbt snapshot" executado, o dbt compara
-- as colunas em check_cols contra a última versão salva. Se algo mudou,
-- fecha a linha antiga (dbt_valid_to = agora) e insere uma nova linha
-- (dbt_valid_from = agora). Isso satisfaz o requisito do enunciado de
-- "mudanças em dimensões via snapshots do dbt".

select
    iucr,
    primary_type,
    description,
    fbi_code
from {{ ref('int_tipo_crime_atual') }}

{% endsnapshot %}
