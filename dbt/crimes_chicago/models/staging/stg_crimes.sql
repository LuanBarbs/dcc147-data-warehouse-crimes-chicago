-- models/staging/stg_crimes.sql
-- Limpeza e tipagem da fonte transacional. Nenhuma regra de negócio aqui,
-- apenas normalização de nomes e tipos de coluna.

with source as (
    select * from {{ source('raw', 'crimes_raw') }}
),

cleaned as (
    select
        "ID"::bigint                                                  as crime_id,
        "Case Number"::text                                           as case_number,
        to_timestamp(nullif(trim("Date"), ''), 'MM/DD/YYYY HH12:MI:SS AM') as date, -- comverte '09/15/2023 08:30:15 PM' para 2023-09-15 20:30:15
                                                                        
        "Block"::text                                                 as block,
        "IUCR"::text                                                  as iucr_code,
        "Primary Type"::text                                          as primary_type,
        "Description"::text                                           as crime_description,
        "Location Description"::text                                  as location_description,
        lower(trim("Arrest"))::boolean                                as arrest_flag,
        lower(trim("Domestic"))::boolean                              as domestic_flag,

        case when trim("Beat") in ('', 'NaN') then null
             else trim("Beat") end::numeric::int                      as beat,

        case when trim("District") in ('', 'NaN') then null
             else trim("District") end::numeric::int                  as district,

        case when trim("Ward") in ('', 'NaN') then null
             else trim("Ward") end::numeric::int                      as ward,

        case when trim("Community Area") in ('', 'NaN') then null
             else trim("Community Area") end::numeric::int            as community_area,

        "FBI Code"::text                                              as fbi_code,

        case when trim("X Coordinate") in ('', 'NaN') then null
             else trim("X Coordinate") end::numeric                   as x_coordinate,

        case when trim("Y Coordinate") in ('', 'NaN') then null
             else trim("Y Coordinate") end::numeric                   as y_coordinate,

        case when trim("Year") in ('', 'NaN') then null
             else trim("Year") end::numeric::int                      as year,

        to_timestamp(nullif(trim("Updated On"), ''), 'MM/DD/YYYY HH12:MI:SS AM')  as updated_on,  -- comverte '09/15/2023 08:30:15 PM' para 2023-09-15 20:30:15
                                                                       
        case when trim("Latitude") in ('', 'NaN') then null
             else trim("Latitude") end::numeric                       as latitude,

        case when trim("Longitude") in ('', 'NaN') then null
             else trim("Longitude") end::numeric                      as longitude
    from source
    where "Date" is not null
      and "ID" is not null
)

select * from cleaned