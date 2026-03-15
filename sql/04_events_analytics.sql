WITH base_counts AS (
  SELECT
    COUNT(DISTINCT CASE WHEN event_type IN ('home', 'department', 'product', 'cart', 'purchase') THEN session_id END) as total_visitors,
    COUNT(DISTINCT CASE WHEN event_type IN ('product', 'cart', 'purchase') THEN session_id END) as product_viewers,
    COUNT(DISTINCT CASE WHEN event_type IN ('cart', 'purchase') THEN session_id END) as cart_adders,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN session_id END) as purchasers
  FROM `bigquery-public-data.thelook_ecommerce.events`
  WHERE created_at >= '2025-01-01'
  AND event_type IN ('home', 'department', 'product', 'cart', 'purchase')
)
SELECT '1. All Visitors' as step, total_visitors as sessions FROM base_counts
UNION ALL
SELECT '2. Product Viewers' as step, product_viewers FROM base_counts
UNION ALL
SELECT '3. Add to Cart' as step, cart_adders FROM base_counts
UNION ALL
SELECT '4. Purchase' as step, purchasers FROM base_counts
