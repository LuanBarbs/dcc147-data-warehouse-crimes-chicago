{{
  config(
    materialized='view'
  )
}}

-- Estado atual de cada IUCR, na visão da carga mais recente.
-- É esta view que o snapshot (snapshots/dim_tipo_crime_snapshot.sql) observa
-- a cada execução do dbt para detectar mudanças de primary_type/description/fbi_code e gerar histórico (SCD Tipo 2).

with combinacoes as (

    select
        iucr,
        primary_type,
        description,
        fbi_code,
        count(*)            as qtd_ocorrencias,
        max(date)    as ultima_ocorrencia
    from {{ ref('stg_crimes') }}
    where iucr is not null
    group by 1, 2, 3, 4

),

ranqueado as (

    select
        *,
        row_number() over (
            partition by iucr
            order by ultima_ocorrencia desc, qtd_ocorrencias desc
        ) as rn
    from combinacoes

)

select
    iucr,
    primary_type,
    description,
    fbi_code
from ranqueado
where rn = 1
