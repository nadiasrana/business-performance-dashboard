DROP TABLE IF EXISTS bi.stg_orders;
CREATE TABLE bi.stg_orders AS
SELECT
  NULLIF(TRIM(row_id), '')::INT                       AS row_id,
  NULLIF(TRIM(order_id), '')                          AS order_id,
  TO_DATE(NULLIF(TRIM(order_date), ''), 'MM/DD/YYYY') AS order_date,
  TO_DATE(NULLIF(TRIM(ship_date), ''), 'MM/DD/YYYY')  AS ship_date,
  NULLIF(TRIM(ship_mode), '')                         AS ship_mode,

  NULLIF(TRIM(customer_id), '')                       AS customer_id,
  NULLIF(TRIM(customer_name), '')                     AS customer_name,
  NULLIF(TRIM(segment), '')                           AS segment,

  NULLIF(TRIM(country), '')                           AS country,
  NULLIF(TRIM(city), '')                              AS city,
  NULLIF(TRIM(state), '')                             AS state,
  NULLIF(TRIM(postal_code), '')                       AS postal_code,
  NULLIF(TRIM(region), '')                            AS region,

  NULLIF(TRIM(product_id), '')                        AS product_id,
  NULLIF(TRIM(category), '')                          AS category,
  NULLIF(TRIM(sub_category), '')                      AS sub_category,
  NULLIF(TRIM(product_name), '')                      AS product_name,

  NULLIF(TRIM(sales), '')::NUMERIC(12,2)              AS sales,
  NULLIF(TRIM(quantity), '')::INT                     AS quantity,
  NULLIF(TRIM(discount), '')::NUMERIC(6,4)            AS discount,
  NULLIF(TRIM(profit), '')::NUMERIC(12,2)              AS profit
FROM bi.raw_orders
WHERE NULLIF(TRIM(order_id), '') IS NOT NULL;
