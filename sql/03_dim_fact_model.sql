/* =========================
   DATE DIMENSION
   ========================= */

DROP TABLE IF EXISTS bi.dim_date;
CREATE TABLE bi.dim_date AS
WITH dates AS (
  SELECT generate_series(
    (SELECT MIN(order_date) FROM bi.stg_orders),
    (SELECT MAX(order_date) FROM bi.stg_orders),
    INTERVAL '1 day'
  )::date AS d
)
SELECT
  d                                 AS date_key,
  EXTRACT(YEAR FROM d)::INT         AS year,
  EXTRACT(QUARTER FROM d)::INT      AS quarter,
  EXTRACT(MONTH FROM d)::INT        AS month,
  TO_CHAR(d, 'Mon')                 AS month_name,
  EXTRACT(DAY FROM d)::INT          AS day,
  TO_CHAR(d, 'YYYY-MM')             AS year_month,
  EXTRACT(ISODOW FROM d)::INT       AS iso_day_of_week,
  TO_CHAR(d, 'Dy')                  AS day_name
FROM dates;


/* =========================
   CUSTOMER DIMENSION
   ========================= */

DROP TABLE IF EXISTS bi.dim_customer;
CREATE TABLE bi.dim_customer AS
SELECT DISTINCT
  customer_id,
  customer_name,
  segment
FROM bi.stg_orders;


/* =========================
   PRODUCT DIMENSION
   ========================= */

DROP TABLE IF EXISTS bi.dim_product;
CREATE TABLE bi.dim_product AS
SELECT DISTINCT
  product_id,
  product_name,
  category,
  sub_category
FROM bi.stg_orders;


/* =========================
   GEOGRAPHY DIMENSION
   ========================= */

DROP TABLE IF EXISTS bi.dim_geo;
CREATE TABLE bi.dim_geo AS
SELECT DISTINCT
  country,
  state,
  city,
  postal_code,
  region
FROM bi.stg_orders;


/* =========================
   SALES FACT TABLE
   ========================= */

DROP TABLE IF EXISTS bi.fact_sales;
CREATE TABLE bi.fact_sales AS
SELECT
  o.order_id,
  o.row_id,
  o.order_date        AS order_date_key,
  o.ship_date,
  o.ship_mode,

  o.customer_id,
  o.product_id,

  o.country,
  o.state,
  o.city,
  o.postal_code,
  o.region,

  o.quantity,
  o.sales,
  o.discount,
  o.profit,

  (o.sales - o.profit) AS estimated_cost,

  CASE 
    WHEN o.sales = 0 THEN NULL
    ELSE o.profit / o.sales
  END AS profit_margin

FROM bi.stg_orders o;


/* =========================
   OPTIONAL PERFORMANCE INDEXES
   ========================= */

CREATE INDEX IF NOT EXISTS idx_fact_sales_order_date
  ON bi.fact_sales(order_date_key);

CREATE INDEX IF NOT EXISTS idx_fact_sales_customer
  ON bi.fact_sales(customer_id);

CREATE INDEX IF NOT EXISTS idx_fact_sales_product
  ON bi.fact_sales(product_id);
