{{
  config(
    materialized='table'
  )
}}

with base as (
    select
        fc.sk_tempo,
        dd.sk_distrito,
        fc.quant_crime
    from {{ ref('fct_crime') }} fc

    inner join {{ ref('dim_local') }} dl
        on dl.sk_local = fc.sk_local
    inner join {{ ref('dim_distrito') }} dd
        on dd.district = dl.district
),

com_mes_ano as (
    select
        b.sk_distrito,
        b.quant_crime,
        dt.ano,
        dt.mes
    from base b
    inner join {{ ref('dim_tempo') }} dt
        on dt.sk_tempo = b.sk_tempo
),

agregado as (
    select
        ano,
        mes,
        sk_distrito,
        sum(quant_crime) as qtd_total_crimes
    from com_mes_ano
    group by
        ano,
        mes,
        sk_distrito
),

ultimo_dia_mes as (
    select
        ano,
        mes,
        max(data_completa) as data_fim_mes
    from {{ ref('dim_tempo') }}
    group by
        ano,
        mes
)

select

    {{ dbt_utils.generate_surrogate_key(['a.ano','a.mes','a.sk_distrito'])}} as id,
    dt.sk_tempo,
    a.sk_distrito,
    a.qtd_total_crimes

from agregado a
inner join ultimo_dia_mes u
    on a.ano = u.ano
   and a.mes = u.mes
inner join {{ ref('dim_tempo') }} dt
    on dt.data_completa = u.data_fim_mes
   and dt.hora = 0