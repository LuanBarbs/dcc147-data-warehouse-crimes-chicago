{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='id'
  )
}}

with crimes as (

    select *
    from {{ ref('stg_crimes') }}

    {% if is_incremental() %}
    where updated_on > (select coalesce(max(updated_on), '1900-01-01') from {{ this }})
    {% endif %}

),

com_tipo_crime as (

    select
        c.*,
        coalesce(dtc_vigente.sk_tipo_crime, dtc_mais_antiga.sk_tipo_crime) as sk_tipo_crime
    from crimes c
    left join lateral (
        select dtc.sk_tipo_crime
        from {{ ref('dim_tipo_crime') }} dtc
        where dtc.iucr = c.iucr
          and c.date >= dtc.vigente_desde
          and (c.date < dtc.vigente_ate or dtc.vigente_ate is null)
        order by dtc.vigente_desde desc
        limit 1
    ) dtc_vigente on true
    left join lateral (
        select dtc.sk_tipo_crime
        from {{ ref('dim_tipo_crime') }} dtc
        where dtc.iucr = c.iucr
        order by dtc.vigente_desde asc
        limit 1
    ) dtc_mais_antiga on true

)

select
    c.id,
    c.case_number,
    dt.sk_tempo,
    dl.sk_local,
    dle.sk_local_evento,
    c.sk_tipo_crime,
    1                                        as quant_crime,        -- 1 por linha
    (c.updated_on > date)           as teve_atualizacao,
    c.is_domestic,
    c.is_arrest,
    c.date,
    c.updated_on
from com_tipo_crime c
left join {{ ref('dim_tempo') }} dt
    on dt.data_completa = c.date::date
    and dt.hora = extract(hour from c.date)::int
left join {{ ref('dim_local') }} dl
    on dl.beat = c.beat
left join {{ ref('dim_local_evento') }} dle
    on dle.location_description = c.location_description
