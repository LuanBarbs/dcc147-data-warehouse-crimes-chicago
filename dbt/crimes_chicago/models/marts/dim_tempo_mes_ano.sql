{{
  config(
    materialized='table'
  )
}}

with dias as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('" ~ var('data_inicio_dw') ~ "' as date)",
        end_date="cast('" ~ var('data_fim_dw') ~ "' as date)"
    ) }}
),

calendario as (
    select
        extract(year from d.date_day)::int      as ano,
        extract(month from d.date_day)::int      as mes
    from dias d
    group by ano, mes
)

select
    (ano * 1000000 + mes * 10000) as sk_tempo,
    ano,
    mes
from calendario
