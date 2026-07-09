{{
  config(
    materialized='table'
  )
}}

with base as (
    select
        fc.sk_tempo,
        dl.district,
        fc.sk_tipo_crime,
        fc.quant_crime
    from {{ ref('fct_crime') }} fc
    inner join {{ ref('dim_local') }} dl
        on dl.sk_local = fc.sk_local
),

com_mes_ano as (
    select
        b.*,
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
        district,
        sk_tipo_crime,
        sum(quant_crime) as qtd_total_crimes
    from com_mes_ano
    group by 1, 2, 3, 4
)

select
    {{ dbt_utils.generate_surrogate_key(['a.ano', 'a.mes', 'a.district', 'a.sk_tipo_crime']) }} as id,
    dt_mes.sk_tempo,
    a.district,
    a.sk_tipo_crime,
    a.qtd_total_crimes
from agregado a
inner join {{ ref('dim_tempo') }} dt_mes
    on dt_mes.ano = a.ano
    and dt_mes.mes = a.mes
    and dt_mes.dia = 1
    and dt_mes.hora = 0
