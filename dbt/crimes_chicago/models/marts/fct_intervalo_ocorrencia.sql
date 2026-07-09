{{
  config(
    materialized='table'
  )
}}

with eventos as (

    select
        fc.sk_local,
        fc.sk_tipo_crime,
        fc.date,
        lag(fc.date) over (
            partition by fc.sk_local, fc.sk_tipo_crime, fc.date::date
            order by fc.date
        ) as data_anterior
    from {{ ref('fct_crime') }} fc

),

com_intervalo as (

    select
        sk_local,
        sk_tipo_crime,
        date::date                                              as data_ocorrencia,
        date,
        extract(epoch from (date - data_anterior)) / 60.0 as intervalo_minutos
    from eventos
    where data_anterior is not null

),

por_dia as (

    select
        sk_local,
        sk_tipo_crime,
        data_ocorrencia,
        avg(intervalo_minutos)                                          as media_intervalo,
        -- lag_ocorrencia = intervalo referente à última ocorrência do dia
        (array_agg(intervalo_minutos order by date desc))[1]     as lag_ocorrencia
    from com_intervalo
    group by 1, 2, 3

)

select
    {{ dbt_utils.generate_surrogate_key(['sk_local', 'sk_tipo_crime', 'data_ocorrencia']) }} as id,
    dt.sk_tempo,
    p.sk_local,
    p.sk_tipo_crime,
    p.lag_ocorrencia,
    p.media_intervalo
from por_dia p
inner join {{ ref('dim_tempo') }} dt
    on dt.data_completa = p.data_ocorrencia
    and dt.hora = 0
