{{ 
  config(
    materialized='incremental',
    unique_key='order_id',
    on_schema_change='sync_all_columns'
  ) 
}}

with base as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        o.product_name,
        o.product_category,
        o.quantity,
        o.unit_price,
        o.gross_amount,
        o.payment_method,
        o.country
    from {{ ref('stg_orders') }} o
    {% if is_incremental() %}
      where o.order_date > (select coalesce(max(order_date), '1900-01-01') from {{ this }})
    {% endif %}
),

with_product as (
    select
        b.*,
        p.product_sk
    from base b
    left join {{ ref('dim_products') }} p
      on b.product_name = p.product_name
)

select * from with_product
