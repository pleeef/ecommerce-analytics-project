WITH user_first_order AS (
  SELECT
    user_id,
    DATE_TRUNC(DATE(MIN(created_at)), MONTH) AS first_order_month
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE DATE(created_at) BETWEEN DATE '2025-01-01' AND DATE '2025-12-31'
    AND status NOT IN ('Cancelled', 'Returned')
  GROUP BY user_id
),

user_orders AS (
  SELECT DISTINCT
    user_id,
    DATE_TRUNC(DATE(created_at), MONTH) AS order_month
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status NOT IN ('Cancelled', 'Returned')
    AND DATE(created_at) >= DATE '2025-01-01'
),

cohort_data AS (
  SELECT
    u.user_id,
    f.first_order_month,
    u.order_month,
    DATE_DIFF(u.order_month, f.first_order_month, MONTH) AS month_index
  FROM user_orders u
  JOIN user_first_order f
    USING (user_id)
),

cohort_size AS (
  SELECT
    first_order_month,
    COUNT(DISTINCT user_id) AS cohort_size
  FROM cohort_data
  WHERE month_index = 0
  GROUP BY 1
),

retention AS (
  SELECT
    first_order_month,
    month_index,
    COUNT(DISTINCT user_id) AS users
  FROM cohort_data
  GROUP BY 1, 2
)

SELECT
  r.first_order_month,
  r.month_index,
  r.users AS active_users,
  c.cohort_size,
  ROUND(SAFE_DIVIDE(r.users, c.cohort_size), 4) AS retention_rate,
  ROUND(SAFE_DIVIDE(r.users, c.cohort_size) * 100, 1) AS retention_rate_pct
FROM retention r
JOIN cohort_size c
  USING (first_order_month)
WHERE r.month_index BETWEEN 0 AND 18
ORDER BY r.first_order_month, r.month_index;
