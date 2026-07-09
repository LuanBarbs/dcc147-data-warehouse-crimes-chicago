{{
  config(
    materialized='table'
  )
}}

with location as (
    select distinct location_description
    from {{ref('stg_crimes')}}
    where location_description is not null
)

select 
    {{ dbt_utils.generate_surrogate_key(['location_description'])}} as sk_local_evento,
    location_description
from location