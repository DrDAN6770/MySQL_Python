-- 3-1-1
select DISTINCT customer_unique_id,
        COUNT(DISTINCT order_id) as order_cnt
FROM `AC_eshop.customer` c
LEFT JOIN `AC_eshop.order` o USING (customer_id)
GROUP BY 1
ORDER BY 2 DESC;

-- 3-1-2
WITH Frequency AS (
    SELECT DISTINCT customer_unique_id AS cuid,
           COUNT(DISTINCT order_id) AS order_cnt
    FROM `AC_eshop.customer` c
    LEFT JOIN `AC_eshop.order` o USING (customer_id)
    GROUP BY 1
    )
SELECT order_cnt, 
        COUNT(cuid) AS cuid_cnt
FROM Frequency
GROUP BY 1
ORDER BY 2 DESC;

-- 3-2-1
SELECT DISTINCT c.customer_unique_id,
           SUM(IFNULL(oi.price, 0)) AS Monetary
FROM `AC_eshop.customer` c
LEFT JOIN `AC_eshop.order` o USING (customer_id)
LEFT JOIN `AC_eshop.order_item` oi using (order_id)
GROUP BY 1
ORDER BY 2 DESC

-- 3-2-2
WITH CTE AS (
    SELECT DISTINCT c.customer_unique_id AS cuid,
        SUM(IFNULL(oi.price, 0)) AS Monetary
    FROM `AC_eshop.customer` c
    LEFT JOIN `AC_eshop.order` o USING (customer_id)
    LEFT JOIN `AC_eshop.order_item` oi using (order_id)
    GROUP BY 1
)
SELECT
    CASE
    WHEN Monetary >= 10000 THEN '10000+'
    WHEN Monetary >= 5000 AND Monetary < 10000 THEN '5000 - 10000'
    WHEN Monetary >= 500 AND Monetary < 5000 THEN '500 - 5000'
    WHEN 500 > Monetary THEN '500-'
    END AS moneycase,
    COUNT(cuid) AS cnt
FROM CTE
GROUP BY 1
ORDER BY 2 DESC

-- 3-3-1
SELECT
    customer_unique_id AS cuid,
    MAX(DATE(o.order_purchase_timestamp)) as `last_order_date`,
    DATE_DIFF(DATE('2018-09-15'), MAX(DATE(o.order_purchase_timestamp)), DAY) AS day_diff
FROM `AC_eshop.customer` c
LEFT JOIN `AC_eshop.order` o USING(customer_id)
GROUP BY 1
ORDER BY 2 DESC

-- 3-3-2
WITH CTE AS (
SELECT
    customer_unique_id AS cuid,
    MAX(DATE(o.order_purchase_timestamp)) as `last_order_date`,
    DATE_DIFF(DATE('2018-09-15'), MAX(DATE(o.order_purchase_timestamp)), DAY) AS day_diff
FROM `AC_eshop.customer` c
LEFT JOIN `AC_eshop.order` o USING(customer_id)
GROUP BY 1
)
SELECT
CASE
    WHEN day_diff >= 400 THEN '400+ Days'
    WHEN day_diff >= 200 AND 400 > day_diff THEN '200 - 400 Days'
    WHEN day_diff >= 50 AND 200 > day_diff THEN '50 - 200 Days'
    ELSE '50- Days' END AS `case_days`,
COUNT(cuid) AS cuid
FROM CTE
GROUP BY 1
ORDER BY 2 DESC

-- 3-4-1
WITH Frequency AS (
SELECT DISTINCT customer_unique_id AS cuid,
        COUNT(DISTINCT order_id) AS order_cnt,
        ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT order_id)) AS row_num,
        COUNT(*) OVER () AS total_rows
FROM `AC_eshop.customer` c
LEFT JOIN `AC_eshop.order` o USING (customer_id)
GROUP BY 1
),
MedianFrequency AS (
SELECT 
    order_cnt,
    (total_rows + 1) / 2 AS median_row
FROM Frequency
WHERE row_num IN ((total_rows + 1) / 2, (total_rows + 2) / 2)
)
SELECT 
f.cuid,
mf.order_cnt as `medain order_cnt`,
f.order_cnt,
CASE 
    WHEN f.row_num = mf.median_row THEN 'MEDIAN'
    WHEN f.order_cnt <= mf.order_cnt THEN 'LOW'
    ELSE 'HIGH'
END AS Flag
FROM Frequency f
JOIN MedianFrequency mf ON 1=1
ORDER BY 3 DESC;

WITH Monetary AS (
SELECT DISTINCT c.customer_unique_id AS cuid,
        SUM(IFNULL(oi.price, 0)) AS moneysum,
        ROW_NUMBER() OVER (ORDER BY SUM(IFNULL(oi.price, 0))) AS row_num,
        COUNT(*) OVER () AS total_rows
FROM `AC_eshop.customer` c
LEFT JOIN `AC_eshop.order` o USING (customer_id)
LEFT JOIN `AC_eshop.order_item` oi using (order_id)
GROUP BY 1
),
MedianMonetary AS (
SELECT 
    moneysum,
    (total_rows + 1) / 2 AS median_row
FROM Monetary
WHERE row_num IN ((total_rows + 1) / 2, (total_rows + 2) / 2)
)
SELECT 
m.cuid,
mm.moneysum as `median moneysum`,
m.moneysum,
CASE 
    WHEN m.row_num = mm.median_row THEN 'MEDIAN'
    WHEN m.moneysum <= mm.moneysum THEN 'LOW'
    ELSE 'HIGH'
END AS Flag
FROM Monetary m
JOIN MedianMonetary mm ON 1=1
ORDER BY 3 DESC;

WITH Recency AS (
SELECT
    customer_unique_id AS cuid,
    MAX(DATE(o.order_purchase_timestamp)) as `last_order_date`,
    DATE_DIFF(DATE('2018-09-15'), MAX(DATE(o.order_purchase_timestamp)), DAY) AS day_diff,
    ROW_NUMBER() OVER (ORDER BY DATE_DIFF(DATE('2018-09-15'), MAX(DATE(o.order_purchase_timestamp)), DAY)) AS row_num,
    COUNT(*) OVER () AS total_rows
FROM `AC_eshop.customer` c
LEFT JOIN `AC_eshop.order` o USING(customer_id)
GROUP BY 1
),
MedianRecency AS (
SELECT 
    day_diff,
    (total_rows + 1) / 2 AS median_row
FROM Recency
WHERE row_num IN ((total_rows + 1) / 2, (total_rows + 2) / 2)
)
SELECT 
r.cuid,
mr.day_diff as `median day`,
r.day_diff,
CASE 
    WHEN r.row_num = mr.median_row THEN 'MEDIAN'
    WHEN r.day_diff <= mr.day_diff THEN 'LOW'
    ELSE 'HIGH'
END AS Flag
FROM Recency r
JOIN MedianRecency mr ON 1=1
ORDER BY 3 DESC;

-- 3-4-2
WITH Frequency AS (
  SELECT DISTINCT customer_unique_id AS cuid,
         COUNT(DISTINCT order_id) AS order_cnt,
         ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT order_id)) AS row_num,
         COUNT(*) OVER () AS total_rows
  FROM `AC_eshop.customer` c
  LEFT JOIN `AC_eshop.order` o USING (customer_id)
  GROUP BY 1
),
MedianFrequency AS (
  SELECT 
    order_cnt,
    (total_rows + 1) / 2 AS median_row
  FROM Frequency
  WHERE row_num IN ((total_rows + 1) / 2, (total_rows + 2) / 2)
),
Monetary AS (
  SELECT DISTINCT c.customer_unique_id AS cuid,
        SUM(IFNULL(oi.price, 0)) AS moneysum,
        ROW_NUMBER() OVER (ORDER BY SUM(IFNULL(oi.price, 0))) AS row_num,
        COUNT(*) OVER () AS total_rows
  FROM `AC_eshop.customer` c
  LEFT JOIN `AC_eshop.order` o USING (customer_id)
  LEFT JOIN `AC_eshop.order_item` oi using (order_id)
  GROUP BY 1
),
MedianMonetary AS (
  SELECT 
    moneysum,
    (total_rows + 1) / 2 AS median_row
  FROM Monetary
  WHERE row_num IN ((total_rows + 1) / 2, (total_rows + 2) / 2)
),
Recency AS (
  SELECT
    customer_unique_id AS cuid,
    MAX(DATE(o.order_purchase_timestamp)) as `last_order_date`,
    DATE_DIFF(DATE('2018-09-15'), MAX(DATE(o.order_purchase_timestamp)), DAY) AS day_diff,
    ROW_NUMBER() OVER (ORDER BY DATE_DIFF(DATE('2018-09-15'), MAX(DATE(o.order_purchase_timestamp)), DAY)) AS row_num,
    COUNT(*) OVER () AS total_rows
  FROM `AC_eshop.customer` c
  LEFT JOIN `AC_eshop.order` o USING(customer_id)
  GROUP BY 1
),
MedianRecency AS (
  SELECT 
    day_diff,
    (total_rows + 1) / 2 AS median_row
  FROM Recency
  WHERE row_num IN ((total_rows + 1) / 2, (total_rows + 2) / 2)
),
RMF AS (
  SELECT
    c.customer_unique_id AS cuid,
    COUNT(DISTINCT o.order_id) AS frequency,
    SUM(IFNULL(oi.price, 0)) AS monetary,
    DATE_DIFF(DATE('2018-09-15'), MAX(DATE(o.order_purchase_timestamp)), DAY) AS recency
  FROM `AC_eshop.customer` c
  LEFT JOIN `AC_eshop.order` o USING (customer_id)
  LEFT JOIN `AC_eshop.order_item` oi USING (order_id)
  GROUP BY c.customer_unique_id
)
SELECT
  RMF.cuid,
  RMF.frequency,
  CASE
    WHEN RMF.frequency <= (SELECT order_cnt FROM MedianFrequency) THEN 'LOW'
    WHEN RMF.frequency = (SELECT order_cnt FROM MedianFrequency) THEN 'MEDIAN'
    ELSE 'HIGH'
  END AS F_Flag,
  RMF.monetary,
  CASE
    WHEN RMF.monetary <= (SELECT moneysum FROM MedianMonetary) THEN 'LOW'
    WHEN RMF.monetary = (SELECT moneysum FROM MedianMonetary) THEN 'MEDIAN'
    ELSE 'HIGH'
  END AS M_Flag,
  RMF.recency,
  CASE
    WHEN RMF.recency <= (SELECT day_diff FROM MedianRecency) THEN 'LOW'
    WHEN RMF.recency = (SELECT day_diff FROM MedianRecency) THEN 'MEDIAN'
    ELSE 'HIGH'
  END AS R_Flag
FROM RMF
ORDER BY 3,5 ASC ,7 DESC

-- 3-4-3
WITH RFM_Clusters AS (
  WITH Frequency AS (
    SELECT DISTINCT customer_unique_id AS cuid,
      COUNT(DISTINCT order_id) AS order_cnt,
      ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT order_id)) AS row_num,
      COUNT(*) OVER () AS total_rows
    FROM `AC_eshop.customer` c
    LEFT JOIN `AC_eshop.order` o USING (customer_id)
    GROUP BY 1
  ),
  MedianFrequency AS (
    SELECT 
      order_cnt,
      (total_rows + 1) / 2 AS median_row
    FROM Frequency
    WHERE row_num IN ((total_rows + 1) / 2, (total_rows + 2) / 2)
  ),
  Monetary AS (
    SELECT DISTINCT c.customer_unique_id AS cuid,
      SUM(IFNULL(oi.price, 0)) AS moneysum,
      ROW_NUMBER() OVER (ORDER BY SUM(IFNULL(oi.price, 0))) AS row_num,
      COUNT(*) OVER () AS total_rows
    FROM `AC_eshop.customer` c
    LEFT JOIN `AC_eshop.order` o USING (customer_id)
    LEFT JOIN `AC_eshop.order_item` oi USING (order_id)
    GROUP BY 1
  ),
  MedianMonetary AS (
    SELECT 
      moneysum,
      (total_rows + 1) / 2 AS median_row
    FROM Monetary
    WHERE row_num IN ((total_rows + 1) / 2, (total_rows + 2) / 2)
  ),
  Recency AS (
    SELECT
      customer_unique_id AS cuid,
      MAX(DATE(o.order_purchase_timestamp)) as last_order_date,
      DATE_DIFF(DATE('2018-09-15'), MAX(DATE(o.order_purchase_timestamp)), DAY) AS day_diff,
      ROW_NUMBER() OVER (ORDER BY DATE_DIFF(DATE('2018-09-15'), MAX(DATE(o.order_purchase_timestamp)), DAY)) AS row_num,
      COUNT(*) OVER () AS total_rows
    FROM `AC_eshop.customer` c
    LEFT JOIN `AC_eshop.order` o USING(customer_id)
    GROUP BY 1
  ),
  MedianRecency AS (
    SELECT 
      day_diff,
      (total_rows + 1) / 2 AS median_row
    FROM Recency
    WHERE row_num IN ((total_rows + 1) / 2, (total_rows + 2) / 2)
  ),
  RMF AS (
    SELECT
      c.customer_unique_id AS cuid,
      COUNT(DISTINCT o.order_id) AS frequency,
      SUM(IFNULL(oi.price, 0)) AS monetary,
      DATE_DIFF(DATE('2018-09-15'), MAX(DATE(o.order_purchase_timestamp)), DAY) AS recency
    FROM `AC_eshop.customer` c
    LEFT JOIN `AC_eshop.order` o USING (customer_id)
    LEFT JOIN `AC_eshop.order_item` oi USING (order_id)
    GROUP BY c.customer_unique_id
  )
  SELECT
    RMF.cuid,
    RMF.frequency,
    CASE
      WHEN RMF.frequency <= (SELECT order_cnt FROM MedianFrequency) THEN 'LOW'
      WHEN RMF.frequency = (SELECT order_cnt FROM MedianFrequency) THEN 'MEDIAN'
      ELSE 'HIGH'
    END AS F_Flag,
    RMF.monetary,
    CASE
      WHEN RMF.monetary <= (SELECT moneysum FROM MedianMonetary) THEN 'LOW'
      WHEN RMF.monetary = (SELECT moneysum FROM MedianMonetary) THEN 'MEDIAN'
      ELSE 'HIGH'
    END AS M_Flag,
    RMF.recency,
    CASE
      WHEN RMF.recency <= (SELECT day_diff FROM MedianRecency) THEN 'LOW'
      WHEN RMF.recency = (SELECT day_diff FROM MedianRecency) THEN 'MEDIAN'
      ELSE 'HIGH'
    END AS R_Flag
  FROM RMF
),
ClusterSummary AS (
  SELECT
    CASE
      WHEN F_Flag = 'HIGH' AND M_Flag = 'HIGH' AND R_Flag = 'HIGH' THEN 'Cluster1'
      WHEN F_Flag = 'HIGH' AND M_Flag = 'HIGH' AND R_Flag = 'LOW' THEN 'Cluster2'
      WHEN F_Flag = 'HIGH' AND M_Flag = 'LOW' AND R_Flag = 'HIGH' THEN 'Cluster3'
      WHEN F_Flag = 'HIGH' AND M_Flag = 'LOW' AND R_Flag = 'LOW' THEN 'Cluster4'
      WHEN F_Flag = 'LOW' AND M_Flag = 'HIGH' AND R_Flag = 'HIGH' THEN 'Cluster5'
      WHEN F_Flag = 'LOW' AND M_Flag = 'HIGH' AND R_Flag = 'LOW' THEN 'Cluster6'
      WHEN F_Flag = 'LOW' AND M_Flag = 'LOW' AND R_Flag = 'HIGH' THEN 'Cluster7'
      WHEN F_Flag = 'LOW' AND M_Flag = 'LOW' AND R_Flag = 'LOW' THEN 'Cluster8'
    END AS Clusters,
    F_Flag,
    M_Flag,
    R_Flag,
    cuid,
    frequency,
    monetary,
    recency
  FROM RFM_Clusters
)
SELECT
  Clusters,
  F_Flag,
  M_Flag,
  R_Flag,
  COUNT(cuid) AS user_count,
  ROUND(AVG(frequency),2) AS F_mean,
  ROUND(AVG(monetary),2) AS M_mean,
  ROUND(AVG(recency),2) AS R_mean
FROM ClusterSummary
GROUP BY 1, 2, 3, 4
ORDER BY 1
