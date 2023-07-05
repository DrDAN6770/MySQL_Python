-- 1.1
select customer_state
       , COUNT(distinct customer_unique_id) as cid_cnt 
       , COUNT(distinct order_id) order_cnt 
       , sum(price) as sales
FROM `AC_eshop.customer` C
LEFT JOIN `AC_eshop.order` O USING (customer_id)
LEFT JOIN `AC_eshop.order_item` oi using (order_id)
GROUP BY 1
ORDER BY cid_cnt DESC;

-- 1.1
SELECT
    CASE
      WHEN customer_state in ('AC', 'AM', 'RR', 'RO', 'PA', 'AP', 'TO') THEN 'North Region'
      WHEN customer_state in ('MT', 'MS', 'GO', 'DF') THEN 'MidWest Region'
      WHEN customer_state in ('PR', 'SC', 'RS') THEN 'South Region'
      WHEN customer_state in ('SP', 'MG', 'ES', 'RJ') THEN 'SouthEast Region'
      WHEN customer_state in ('MA', 'PI', 'BA', 'CE', 'RN', 'PB', 'PE', 'SE', 'AL') THEN 'NorthEast Region'
      ELSE 'Brazilian States'
      END AS `Region`,
    COUNT(distinct customer_unique_id) as cid_cnt,
    COUNT(distinct order_id) order_cnt,
    SUM(price) as sales
FROM `AC_eshop.customer` C
LEFT JOIN `AC_eshop.order` O USING (customer_id)
LEFT JOIN `AC_eshop.order_item` oi using (order_id)
GROUP BY 1
ORDER BY cid_cnt DESC;

-- 1.3
SELECT
    CASE
      WHEN customer_state in ('AC', 'AM', 'RR', 'RO', 'PA', 'AP', 'TO') THEN 'North Region'
      WHEN customer_state in ('MT', 'MS', 'GO', 'DF') THEN 'MidWest Region'
      WHEN customer_state in ('PR', 'SC', 'RS') THEN 'South Region'
      WHEN customer_state in ('SP', 'MG', 'ES', 'RJ') THEN 'SouthEast Region'
      WHEN customer_state in ('MA', 'PI', 'BA', 'CE', 'RN', 'PB', 'PE', 'SE', 'AL') THEN 'NorthEast Region'
      ELSE 'Brazilian States'
      END AS `Region`,
    EXTRACT(month from O.order_purchase_timestamp) AS Month,
    COUNT(distinct customer_unique_id) as cid_cnt,
    COUNT(distinct order_id) order_cnt,
    SUM(price) as sales
FROM `AC_eshop.customer` C
LEFT JOIN `AC_eshop.order` O USING (customer_id)
LEFT JOIN `AC_eshop.order_item` oi using (order_id)
WHERE EXTRACT(year from O.order_purchase_timestamp) = 2017
GROUP BY 1,2
ORDER BY cid_cnt DESC;

-- 1.4
WITH CTE AS (
  SELECT
    CASE
      WHEN customer_state in ('AC', 'AM', 'RR', 'RO', 'PA', 'AP', 'TO') THEN 'North Region'
      WHEN customer_state in ('MT', 'MS', 'GO', 'DF') THEN 'MidWest Region'
      WHEN customer_state in ('PR', 'SC', 'RS') THEN 'South Region'
      WHEN customer_state in ('SP', 'MG', 'ES', 'RJ') THEN 'SouthEast Region'
      WHEN customer_state in ('MA', 'PI', 'BA', 'CE', 'RN', 'PB', 'PE', 'SE', 'AL') THEN 'NorthEast Region'
      ELSE 'Brazilian States'
      END AS `Region`,
    EXTRACT(month from O.order_purchase_timestamp) AS Month,
    COUNT(distinct customer_unique_id) as cid_cnt,
    COUNT(distinct order_id) order_cnt,
    SUM(price) as sales
  FROM `AC_eshop.customer` C
  LEFT JOIN `AC_eshop.order` O USING (customer_id)
  LEFT JOIN `AC_eshop.order_item` oi using (order_id)
  WHERE EXTRACT(year from O.order_purchase_timestamp) = 2017
  GROUP BY 1,2
)

SELECT Region,
       SUM(CASE WHEN Month in (1,2,3) THEN cid_cnt END) as Q1_cid_cnt,
       SUM(CASE WHEN Month in (1,2,3) THEN order_cnt END) as Q1_order_cnt,
       SUM(CASE WHEN Month in (1,2,3) THEN sales END) as Q1_sales,
       SUM(CASE WHEN Month in (4,5,6) THEN cid_cnt END) as Q2_cid_cnt,
       SUM(CASE WHEN Month in (4,5,6) THEN order_cnt END) as Q2_order_cnt,
       SUM(CASE WHEN Month in (4,5,6) THEN sales END) as Q2_sales,
       SUM(CASE WHEN Month in (7,8,9) THEN cid_cnt END) as Q3_cid_cnt,
       SUM(CASE WHEN Month in (7,8,9) THEN order_cnt END) as Q3_order_cnt,
       SUM(CASE WHEN Month in (7,8,9) THEN sales END) as Q3_sales,
       SUM(CASE WHEN Month in (10,11,12) THEN cid_cnt END) as Q4_cid_cnt,
       SUM(CASE WHEN Month in (10,11,12) THEN order_cnt END) as Q4_order_cnt,
       SUM(CASE WHEN Month in (10,11,12) THEN sales END) as Q4_sales,
FROM CTE
GROUP BY 1