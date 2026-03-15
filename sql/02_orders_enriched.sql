WITH order_headers AS (
  SELECT 
    order_id,
    user_id,
    DATE(created_at) AS created_at,
    DATE(shipped_at) AS shipped_at,
    DATE(delivered_at) AS delivered_at,
    num_of_item
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status NOT IN ('Cancelled', 'Returned')
),

order_details AS (
  SELECT
    oi.order_id,
    oi.user_id,
    oi.product_id,
    oi.sale_price,
    i.cost
    FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
    LEFT JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` i
    ON oi.product_id = i.product_id
    AND i.id = oi.inventory_item_id
    WHERE status NOT IN ('Cancelled', 'Returned')
),

order_totals AS (
  SELECT
    order_id,
    user_id,
    SUM(sale_price) AS order_amount,
    SUM(IFNULL(cost, 0)) AS order_cost
  FROM order_details
  GROUP BY 1, 2
),

orders_enriched AS (
  SELECT 
    h.order_id,
    h.user_id,
    h.created_at,
    h.shipped_at,
    h.delivered_at,
    h.num_of_item,
    r.order_cost,
    r.order_amount,
    ROW_NUMBER() OVER (PARTITION BY h.user_id ORDER BY h.created_at) AS order_number
  FROM order_headers h
  JOIN order_totals r
    USING (order_id, user_id)
)

SELECT *
FROM orders_enriched
