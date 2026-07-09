{{
  config(
    materialized='table'
  )
}}

-- Dimensão final de tipo de crime, construída sobre o snapshot SCD2.
-- Cada IUCR pode ter várias linhas aqui (uma por versão histórica).
-- O fato sempre referencia a linha vigente no momento do crime através de
-- sk_tipo_crime; para consultas "olhar como é hoje", filtre is_current = true.

select
    {{ dbt_utils.generate_surrogate_key(['iucr', 'dbt_valid_from']) }} as sk_tipo_crime,
    iucr,
    primary_type,
    description,
    fbi_code,
    dbt_valid_from                                     as vigente_desde,
    dbt_valid_to                                        as vigente_ate,
    (dbt_valid_to is null)                               as is_current
from {{ ref('dim_tipo_crime_snapshot') }}
