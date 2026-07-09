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

horas as (
    select generate_series(0, 23) as hora
),

calendario as (
    select
        d.date_day     as data_completa,        
        extract(year from d.date_day)::int      as ano,
        extract(quarter from d.date_day)::int    as trimestre,
        extract(month from d.date_day)::int      as mes,
        extract(day from d.date_day)::int        as dia,
        h.hora::int                              as hora
    from dias d
    cross join horas h
)

select
    (ano * 1000000 + mes * 10000 + dia * 100 + hora) as sk_tempo,
    data_completa,
    ano,
    trimestre,
    mes,
    dia,
    hora
from calendario
