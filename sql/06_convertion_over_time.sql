WITH sessions_by_day AS (
  SELECT
    DATE(created_at) AS event_date,
    COUNT(DISTINCT CASE 
      WHEN event_type IN ('home', 'department', 'product', 'cart', 'purchase') 
      THEN session_id 
    END) AS total_sessions,
    COUNT(DISTINCT CASE 
      WHEN event_type = 'purchase' 
      THEN session_id 
    END) AS purchasing_sessions
  FROM `bigquery-public-data.thelook_ecommerce.events`
  WHERE created_at >= '2025-01-01'
    AND event_type IN ('home', 'department', 'product', 'cart', 'purchase')
  GROUP BY 1
)

SELECT
  event_date,
  total_sessions,
  purchasing_sessions,
  SAFE_DIVIDE(purchasing_sessions, total_sessions) AS purchase_conversion_rate
FROM sessions_by_day
ORDER BY event_date
