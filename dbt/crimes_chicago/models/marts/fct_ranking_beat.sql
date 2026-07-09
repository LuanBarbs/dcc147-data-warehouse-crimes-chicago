{{
  config(
    materialized='table'
  )
}}

with base as (
    select
        fc.sk_local,
        dt.ano,
        dt.mes,
        sum(fc.quant_crime) as qtd_crimes_mes
    from {{ ref('fct_crime') }} fc
    inner join {{ ref('dim_tempo') }} dt
        on dt.sk_tempo = fc.sk_tempo
    group by 1, 2, 3
),

ranqueado as (
    select
        *,
        rank() over (
            partition by ano, mes
            order by qtd_crimes_mes desc
        ) as ranking_posicao
    from base
),

com_variacao as (
    select
        r.*,
        lag(r.ranking_posicao) over (
            partition by r.sk_local
            order by r.ano, r.mes
        ) as ranking_posicao_mes_anterior
    from ranqueado r
)

select
    {{ dbt_utils.generate_surrogate_key(['c.sk_local', 'c.ano', 'c.mes']) }} as id,
    dt_mes.sk_tempo,
    c.sk_local,
    c.qtd_crimes_mes,
    c.ranking_posicao,
    (c.ranking_posicao_mes_anterior - c.ranking_posicao) as variacao_ranking
from com_variacao c
inner join {{ ref('dim_tempo') }} dt_mes
    on dt_mes.ano = c.ano
    and dt_mes.mes = c.mes
    and dt_mes.dia = 1
    and dt_mes.hora = 0
