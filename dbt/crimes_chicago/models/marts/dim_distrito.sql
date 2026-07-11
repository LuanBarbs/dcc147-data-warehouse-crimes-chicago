{{
    config(
        materialized='table'
    )
}}

with distritos as (

    select distinct
        district
    from {{ ref('stg_crimes') }}
    where district is not null

)

select

    {{ dbt_utils.generate_surrogate_key(['district']) }} as sk_distrito,
    district

from distritos
order by district