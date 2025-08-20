{{ config(materialized='table') }}

with base as (
    select distinct
        product_name,
        product_category
    from {{ ref('stg_orders') }}
),

mapped as (
    select
        b.product_name,
        b.product_category,
        pc.category_group
    from base b
    left join {{ ref('product_categories') }} pc
      on b.product_category = pc.product_category
)

select
    md5(coalesce(product_name, '')) as product_sk,
    product_name,
    product_category,
    coalesce(category_group, 'Unknown') as category_group
from mapped