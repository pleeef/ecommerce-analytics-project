  SELECT 
  CASE WHEN status IN ('Complete', 'Processing', 'Shipped') THEN 'processed_orders'
  WHEN status = 'Cancelled' THEN 'cancelled_orders'
  WHEN status = 'Returned' THEN 'returned_orders'
  END AS ststus, 
  COUNT(DISTINCT order_id) AS num_orders
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE  DATE(created_at) >= '2025-01-01'
  GROUP BY 1
  