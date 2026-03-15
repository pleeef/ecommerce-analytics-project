SELECT 
  p.name AS product_name,
  p.category, 
  COUNT(oi.id) AS units_sold,
  SUM(oi.sale_price) AS revenue,
  SUM(oi.sale_price) - SUM(i.cost) AS profit,
  ROUND(SUM(oi.sale_price) / SUM(SUM(oi.sale_price)) OVER() * 100, 2) AS revenue_share_pct
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id
JOIN `bigquery-public-data.thelook_ecommerce.inventory_items` i ON oi.inventory_item_id = i.id
WHERE DATE(oi.created_at) >= '2025-01-01'
  AND oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY 1, 2
ORDER BY revenue DESC
