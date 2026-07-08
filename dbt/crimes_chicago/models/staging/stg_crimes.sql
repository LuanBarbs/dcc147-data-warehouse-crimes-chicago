-- models/staging/stg_crimes.sql
-- Limpeza e tipagem da fonte transacional. Nenhuma regra de negócio aqui,
-- apenas normalização de nomes e tipos de coluna.

{{
  config(
    materialized='view'
  )
}}

with source as (
    select * from {{ source('raw', 'crimes_raw') }}
),

cleaned as (

    select
        nullif(trim("ID"::text), 'NaN')                              as crime_id,
        nullif(trim("Case Number"::text), 'NaN')                     as case_number,
        nullif(trim("Date"::text), 'NaN')                             as date_txt,
        nullif(trim("Updated On"::text), 'NaN')                       as updated_on_txt,
        nullif(trim("Block"::text), 'NaN')                            as block,
        nullif(trim("IUCR"::text), 'NaN')                             as iucr,
        nullif(trim("Primary Type"::text), 'NaN')                     as primary_type,
        nullif(trim("Description"::text), 'NaN')                      as description,
        nullif(trim("Location Description"::text), 'NaN')             as location_description,
        nullif(trim("Arrest"::text), 'NaN')                           as arrest_txt,
        nullif(trim("Domestic"::text), 'NaN')                         as domestic_txt,
        nullif(trim("Beat"::text), 'NaN')                             as beat,
        split_part(nullif(trim("District"::text), 'NaN'), '.', 1)     as district,
        split_part(nullif(trim("Ward"::text), 'NaN'), '.', 1)         as ward,
        split_part(nullif(trim("Community Area"::text), 'NaN'), '.', 1) as community_area,
        nullif(trim("FBI Code"::text), 'NaN')                         as fbi_code,
        nullif(trim("Latitude"::text), 'NaN')                        as latitude_txt,
        nullif(trim("Longitude"::text), 'NaN')                       as longitude_txt
    from source

),

typed as (

    select
        crime_id::bigint                                              as id,
        case_number,
        to_timestamp(date_txt, 'MM/DD/YYYY HH12:MI:SS AM')          as date,
        to_timestamp(updated_on_txt, 'MM/DD/YYYY HH12:MI:SS AM')    as updated_on,
        block,
        iucr,
        primary_type,
        description,
        location_description,
        (lower(arrest_txt) = 'true')                                as is_arrest,--verificar o boolean
        (lower(domestic_txt) = 'true')                              as is_domestic,
        beat,
        district,
        ward,
        community_area,
        fbi_code,
        latitude_txt::numeric                                       as latitude,
        longitude_txt::numeric                                      as longitude
    from cleaned
    where crime_id is not null
      and date_txt is not null

),

deduplicado as (

    select
        *,
        row_number() over (
            partition by id
            order by updated_on desc nulls last
        ) as rn
    from typed

)

select
    id,
    case_number,
    date,
    updated_on,
    block,
    iucr,
    primary_type,
    description,
    location_description,
    is_arrest,
    is_domestic,
    beat,
    district,
    ward,
    community_area,
    fbi_code,
    latitude,
    longitude
from deduplicado
where rn = 1
