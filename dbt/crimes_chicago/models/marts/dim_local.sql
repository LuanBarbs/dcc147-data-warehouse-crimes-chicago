{{
  config(
    materialized='table'
  )
}}

with combinacoes as (
    select
        beat,
        district,
        community_area,
        count(*)                 as qtd_ocorrencias,
        max(date)         as ultima_ocorrencia
    from {{ ref('stg_crimes') }}
    where beat is not null
    group by 1, 2, 3
),

ranqueado as (
    select
        *,
        row_number() over (
            partition by beat
            order by qtd_ocorrencias desc, ultima_ocorrencia desc
        ) as rn
    from combinacoes
),

beats as (
    select beat, district, community_area
    from ranqueado
    where rn = 1
)

select
    {{ dbt_utils.generate_surrogate_key(['beat']) }} as sk_local,
    beat,
    district,
    community_area
from beats
