{{ config(materialized='view') }}

with src as (
    select
        order_id::bigint                         as order_id,
        customer_id::bigint                      as customer_id,
        order_date::date                         as order_date,
        product_category::text                   as product_category,
        product_name::text                       as product_name,
        quantity::int                            as quantity,
        price::numeric(10,2)                     as unit_price,
        (quantity * price)::numeric(12,2)        as gross_amount,
        payment_method::text                     as payment_method,
        country::text                            as country
    from {{ source('raw', 'orders') }}
),

validated as (
    select *
    from src
    where quantity > 0
      and unit_price >= 0
)

select * from validated
