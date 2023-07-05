-- 2.1
SELECT p.product_category_name,
       COUNT(DISTINCT customer_unique_id),
       COUNT(DISTINCT order_id) AS order_cnt,
       SUM(price) AS sales
FROM `AC_eshop.customer` c
LEFT JOIN `AC_eshop.order` o USING (customer_id)
LEFT JOIN `AC_eshop.order_item` oi using (order_id)
LEFT JOIN `AC_eshop.product` p using (product_id)
GROUP BY 1
ORDER BY order_cnt DESC;

-- 2.1.1
    SELECT IFNULL(p.product_category_name, 'other'),
        COUNT(DISTINCT customer_unique_id),
        COUNT(DISTINCT order_id) AS order_cnt,
        SUM(price) AS sales
    FROM `AC_eshop.customer` c
    LEFT JOIN `AC_eshop.order` o USING (customer_id)
    LEFT JOIN `AC_eshop.order_item` oi using (order_id)
    LEFT JOIN `AC_eshop.product` p using (product_id)
    GROUP BY 1
    ORDER BY order_cnt DESC;

-- 2.2
SELECT CASE
  WHEN product_category_name in ('health_beauty', 'computers_accessories', 'toys', 'cool_stuff', 'garden_tools', 'drinks',
                                 'perfumery', 'baby', 'auto', 'pet_shop', 'luggage_accessories', 'books_general_interest',
                                 'market_place', 'books_technical', 'food_drink', 'christmas_supplies', 'dvds_blu_ray',
                                 'books_imported', 'party_supplies', 'music', 'flowers', 'diapers_and_hygiene', 'la_cuisine',
                                 'cds_dvds_musicals', 'fashion_childrens_clothes') THEN 'Consumables'

  WHEN product_category_name in ('sports_leisure', 'watches_gifts', 'telephony', 'fashion_bags_accessories', 'musical_instruments', 'fashion_shoes',
                                 'industry_commerce_and_business', 'costruction_tools_garden', 'fashion_underwear_beach', 'fashion_male_clothing',
                                 'tablets_printing_image', 'cine_photo', 'fashio_female_clothing', 'fashion_sport', 'fashion_childrens_clothes') THEN 'Softlines'

  WHEN product_category_name in ('bed_bath_table', 'furniture_decor', 'housewares', 'electronics', 'stationery', 'small_appliances',
                                 'office_furniture', 'consoles_games', 'home_appliances', 'construction_tools_construction', 'home_construction',
                                 'audio', 'air_conditioning', 'kitchen_dining_laundry_garden_furniture', 'construction_tools_lights', 'home_appliances_2',
                                 'fixed_telephony', 'art', 'costruction_tools_garden', 'computers', 'construction_tools_safety', 'signaling_and_security',
                                 'costruction_tools_tools', 'furniture_bedroom', 'small_appliances_home_oven_and_coffee', 'furniture_mattress_and_upholstery',
                                 'home_comfort_2', 'arts_and_craftmanship') THEN 'Hardlines'
  ELSE 'Other' END AS product_group,
  COUNT(DISTINCT customer_unique_id),
  COUNT(DISTINCT order_id) AS order_cnt,
  SUM(price) AS sales

FROM `AC_eshop.customer` c
LEFT JOIN `AC_eshop.order` o USING (customer_id)
LEFT JOIN `AC_eshop.order_item` oi using (order_id)
LEFT JOIN `AC_eshop.product` p using (product_id)
GROUP BY 1
ORDER BY sales DESC

-- 2.3
SELECT
  CASE
    WHEN customer_state in ('AC', 'AM', 'RR', 'RO', 'PA', 'AP', 'TO') THEN 'North Region'
    WHEN customer_state in ('MT', 'MS', 'GO', 'DF') THEN 'MidWest Region'
    WHEN customer_state in ('PR', 'SC', 'RS') THEN 'South Region'
    WHEN customer_state in ('SP', 'MG', 'ES', 'RJ') THEN 'SouthEast Region'
    WHEN customer_state in ('MA', 'PI', 'BA', 'CE', 'RN', 'PB', 'PE', 'SE', 'AL') THEN 'NorthEast Region'
    ELSE 'Brazilian States' END AS `Region`,
    
  CASE
    WHEN product_category_name IS NULL THEN 'Other'
    WHEN product_category_name in ('health_beauty', 'computers_accessories', 'toys', 'cool_stuff', 'garden_tools', 'drinks',
                                  'perfumery', 'baby', 'auto', 'pet_shop', 'luggage_accessories', 'books_general_interest',
                                  'market_place', 'books_technical', 'food_drink', 'christmas_supplies', 'dvds_blu_ray',
                                  'books_imported', 'party_supplies', 'music', 'flowers', 'diapers_and_hygiene', 'la_cuisine',
                                  'cds_dvds_musicals', 'fashion_childrens_clothes') THEN 'Consumables'

    WHEN product_category_name in ('sports_leisure', 'watches_gifts', 'telephony', 'fashion_bags_accessories', 'musical_instruments', 'fashion_shoes',
                                  'industry_commerce_and_business', 'costruction_tools_garden', 'fashion_underwear_beach', 'fashion_male_clothing',
                                  'tablets_printing_image', 'cine_photo', 'fashio_female_clothing', 'fashion_sport', 'fashion_childrens_clothes') THEN 'Softlines'

    ELSE 'Hardlines' END AS product_family,

  EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
  COUNT(DISTINCT customer_unique_id) AS cid_cnt,
  COUNT(DISTINCT order_id) AS order_cnt,
  SUM(price) AS sales
FROM `AC_eshop.customer` c
LEFT JOIN `AC_eshop.order` o USING (customer_id)
LEFT JOIN `AC_eshop.order_item` oi using (order_id)
LEFT JOIN `AC_eshop.product` p using (product_id)
WHERE EXTRACT(YEAR FROM order_purchase_timestamp) = 2017
GROUP BY Region, month, product_family

-- 2.4
WITH CTE AS (
  SELECT
    CASE
      WHEN customer_state in ('AC', 'AM', 'RR', 'RO', 'PA', 'AP', 'TO') THEN 'North Region'
      WHEN customer_state in ('MT', 'MS', 'GO', 'DF') THEN 'MidWest Region'
      WHEN customer_state in ('PR', 'SC', 'RS') THEN 'South Region'
      WHEN customer_state in ('SP', 'MG', 'ES', 'RJ') THEN 'SouthEast Region'
      WHEN customer_state in ('MA', 'PI', 'BA', 'CE', 'RN', 'PB', 'PE', 'SE', 'AL') THEN 'NorthEast Region'
      ELSE 'Brazilian States' END AS `Region`,
      
    CASE
      WHEN product_category_name IS NULL THEN 'Other'
      WHEN product_category_name in ('health_beauty', 'computers_accessories', 'toys', 'cool_stuff', 'garden_tools', 'drinks',
                                    'perfumery', 'baby', 'auto', 'pet_shop', 'luggage_accessories', 'books_general_interest',
                                    'market_place', 'books_technical', 'food_drink', 'christmas_supplies', 'dvds_blu_ray',
                                    'books_imported', 'party_supplies', 'music', 'flowers', 'diapers_and_hygiene', 'la_cuisine',
                                    'cds_dvds_musicals', 'fashion_childrens_clothes') THEN 'Consumables'

      WHEN product_category_name in ('sports_leisure', 'watches_gifts', 'telephony', 'fashion_bags_accessories', 'musical_instruments', 'fashion_shoes',
                                    'industry_commerce_and_business', 'costruction_tools_garden', 'fashion_underwear_beach', 'fashion_male_clothing',
                                    'tablets_printing_image', 'cine_photo', 'fashio_female_clothing', 'fashion_sport', 'fashion_childrens_clothes') THEN 'Softlines'

      ELSE 'Hardlines' END AS product_family,

    EXTRACT(year FROM o.order_purchase_timestamp) AS year,
    EXTRACT(quarter FROM o.order_purchase_timestamp) AS quarter,
    COUNT(DISTINCT c.customer_unique_id) AS cid_cnt,
    SUM(price) AS sales
  
  FROM `AC_eshop.customer` c
  LEFT JOIN `AC_eshop.order` o USING (customer_id)
  LEFT JOIN `AC_eshop.order_item` oi USING (order_id)
  LEFT JOIN `AC_eshop.product` p USING (product_id)
  GROUP BY Region, product_Family, year, quarter
  ORDER BY Region, product_Family, year, quarter
)
SELECT product_family,
       SUM(CASE WHEN year = 2017 AND quarter = 1 THEN cid_cnt END) as Q1_2017_UserCnt,
       SUM(CASE WHEN year = 2017 AND quarter = 1 THEN sales END) as Q1_2017_Sales,
       SUM(CASE WHEN year = 2017 AND quarter = 2 THEN cid_cnt END) as Q2_2017_UserCnt,
       SUM(CASE WHEN year = 2017 AND quarter = 2 THEN sales END) as Q2_2017_Sales,
       SUM(CASE WHEN year = 2017 AND quarter = 3 THEN cid_cnt END) as Q3_2017_UserCnt,
       SUM(CASE WHEN year = 2017 AND quarter = 3 THEN sales END) as Q3_2017_Sales,
       SUM(CASE WHEN year = 2017 AND quarter = 4 THEN cid_cnt END) as Q4_2017_UserCnt,
       SUM(CASE WHEN year = 2017 AND quarter = 4 THEN sales END) as Q4_2017_Sales,

       SUM(CASE WHEN year = 2018 AND quarter = 1 THEN cid_cnt END) as Q1_2018_UserCnt,
       SUM(CASE WHEN year = 2018 AND quarter = 1 THEN sales END) as Q1_2018_Sales,
       SUM(CASE WHEN year = 2018 AND quarter = 2 THEN cid_cnt END) as Q2_2018_UserCnt,
       SUM(CASE WHEN year = 2018 AND quarter = 2 THEN sales END) as Q2_2018_Sales,
       SUM(CASE WHEN year = 2018 AND quarter = 3 THEN cid_cnt END) as Q3_2018_UserCnt,
       SUM(CASE WHEN year = 2018 AND quarter = 3 THEN sales END) as Q3_2018_Sales
FROM CTE
WHERE Region = 'SouthEast Region'
GROUP BY 1
ORDER BY 1

-- 2.5
WITH CTE AS (
  SELECT
    CASE
      WHEN customer_state in ('AC', 'AM', 'RR', 'RO', 'PA', 'AP', 'TO') THEN 'North Region'
      WHEN customer_state in ('MT', 'MS', 'GO', 'DF') THEN 'MidWest Region'
      WHEN customer_state in ('PR', 'SC', 'RS') THEN 'South Region'
      WHEN customer_state in ('SP', 'MG', 'ES', 'RJ') THEN 'SouthEast Region'
      WHEN customer_state in ('MA', 'PI', 'BA', 'CE', 'RN', 'PB', 'PE', 'SE', 'AL') THEN 'NorthEast Region'
      ELSE 'Brazilian States' END AS `Region`,
      
    CASE
      WHEN product_category_name IS NULL THEN 'Other'
      WHEN product_category_name in ('health_beauty', 'computers_accessories', 'toys', 'cool_stuff', 'garden_tools', 'drinks',
                                    'perfumery', 'baby', 'auto', 'pet_shop', 'luggage_accessories', 'books_general_interest',
                                    'market_place', 'books_technical', 'food_drink', 'christmas_supplies', 'dvds_blu_ray',
                                    'books_imported', 'party_supplies', 'music', 'flowers', 'diapers_and_hygiene', 'la_cuisine',
                                    'cds_dvds_musicals', 'fashion_childrens_clothes') THEN 'Consumables'

      WHEN product_category_name in ('sports_leisure', 'watches_gifts', 'telephony', 'fashion_bags_accessories', 'musical_instruments', 'fashion_shoes',
                                    'industry_commerce_and_business', 'costruction_tools_garden', 'fashion_underwear_beach', 'fashion_male_clothing',
                                    'tablets_printing_image', 'cine_photo', 'fashio_female_clothing', 'fashion_sport', 'fashion_childrens_clothes') THEN 'Softlines'

      ELSE 'Hardlines' END AS product_family,

    EXTRACT(year FROM o.order_purchase_timestamp) AS year,
    EXTRACT(quarter FROM o.order_purchase_timestamp) AS quarter,
    COUNT(DISTINCT c.customer_unique_id) AS cid_cnt,
    SUM(price) AS sales
  
  FROM `AC_eshop.customer` c
  LEFT JOIN `AC_eshop.order` o USING (customer_id)
  LEFT JOIN `AC_eshop.order_item` oi USING (order_id)
  LEFT JOIN `AC_eshop.product` p USING (product_id)
  GROUP BY Region, product_Family, year, quarter
  ORDER BY Region, product_Family, year, quarter
)
SELECT product_family,
       SUM(CASE WHEN year = 2017 AND quarter = 1 THEN cid_cnt END) AS Q1_2017_UserCnt,
       SUM(CASE WHEN year = 2018 AND quarter = 1 THEN cid_cnt END) AS Q1_2018_UserCnt,
       ROUND((SUM(CASE WHEN year = 2018 AND quarter = 1 THEN cid_cnt END)/SUM(CASE WHEN year = 2017 AND quarter = 1 THEN cid_cnt END)-1), 2) AS YOY_Q1_UserCnt,

       SUM(CASE WHEN year = 2017 AND quarter = 1 THEN sales END) AS Q2_2017_Sales,
       SUM(CASE WHEN year = 2018 AND quarter = 1 THEN sales END) AS Q2_2018_Sales,
       ROUND((SUM(CASE WHEN year = 2018 AND quarter = 1 THEN sales END)/SUM(CASE WHEN year = 2017 AND quarter = 1 THEN sales END)-1), 2) AS YOY_Q1_Sales,

       SUM(CASE WHEN year = 2017 AND quarter = 2 THEN cid_cnt END) AS Q2_2017_UserCnt,
       SUM(CASE WHEN year = 2018 AND quarter = 2 THEN cid_cnt END) AS Q2_2018_UserCnt,
       ROUND((SUM(CASE WHEN year = 2018 AND quarter = 2 THEN cid_cnt END)/SUM(CASE WHEN year = 2017 AND quarter = 2 THEN cid_cnt END)-1), 2) AS YOY_Q2_UserCnt,

       SUM(CASE WHEN year = 2017 AND quarter = 2 THEN sales END) AS Q2_2017_Sales,
       SUM(CASE WHEN year = 2018 AND quarter = 2 THEN sales END) AS Q2_2018_Sales,
       ROUND((SUM(CASE WHEN year = 2018 AND quarter = 2 THEN sales END)/SUM(CASE WHEN year = 2017 AND quarter = 2 THEN sales END)-1), 2) AS YOY_Q2_Sales,

       SUM(CASE WHEN year = 2017 AND quarter = 3 THEN cid_cnt END) AS Q3_2017_UserCnt,
       SUM(CASE WHEN year = 2018 AND quarter = 3 THEN cid_cnt END) AS Q3_2018_UserCnt,
       ROUND((SUM(CASE WHEN year = 2018 AND quarter = 3 THEN cid_cnt END)/SUM(CASE WHEN year = 2017 AND quarter = 3 THEN cid_cnt END)-1), 2) AS YOY_Q3_UserCnt,

       SUM(CASE WHEN year = 2017 AND quarter = 3 THEN sales END) AS Q3_2017_Sales,
       SUM(CASE WHEN year = 2018 AND quarter = 3 THEN sales END) AS Q3_2018_Sales,
       ROUND((SUM(CASE WHEN year = 2018 AND quarter = 3 THEN sales END)/SUM(CASE WHEN year = 2017 AND quarter = 3 THEN sales END)-1), 2) AS YOY_Q3_Sales, 
FROM CTE
WHERE Region = 'SouthEast Region'
GROUP BY 1
ORDER BY 1