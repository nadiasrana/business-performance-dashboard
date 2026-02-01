/* =========================
   EXECUTIVE KPI SUMMARY
   ========================= */

SELECT
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit,
  AVG(profit_margin) AS avg_profit_margin
FROM bi.fact_sales;


/* =========================
   MONTHLY SALES & PROFIT TREND
   ========================= */

SELECT
  d.year_month,
  SUM(f.sales) AS monthly_sales,
  SUM(f.profit) AS monthly_profit
FROM bi.fact_sales f
JOIN bi.dim_date d
  ON f.order_date_key = d.date_key
GROUP BY d.year_month
ORDER BY d.year_month;


/* =========================
   MONTH-OVER-MONTH SALES GROWTH
   ========================= */

WITH monthly AS (
  SELECT
    d.year_month,
    SUM(f.sales) AS sales
  FROM bi.fact_sales f
  JOIN bi.dim_date d
    ON f.order_date_key = d.date_key
  GROUP BY d.year_month
)
SELECT
  year_month,
  sales,
  sales - LAG(sales) OVER (ORDER BY year_month) AS mom_change,
  CASE
    WHEN LAG(sales) OVER (ORDER BY year_month) = 0 THEN NULL
    ELSE (sales / LAG(sales) OVER (ORDER BY year_month)) - 1
  END AS mom_growth_rate
FROM monthly
ORDER BY year_month;


/* =========================
   PRODUCT PERFORMANCE
   ========================= */

SELECT
  p.category,
  p.sub_category,
  p.product_name,
  SUM(f.sales) AS sales,
  SUM(f.profit) AS profit,
  AVG(f.profit_margin) AS avg_margin
FROM bi.fact_sales f
JOIN bi.dim_product p
  ON f.product_id = p.product_id
GROUP BY p.category, p.sub_category, p.product_name
ORDER BY profit DESC;


/* =========================
   REGIONAL PERFORMANCE
   ========================= */

SELECT
  f.region,
  SUM(f.sales) AS sales,
  SUM(f.profit) AS profit,
  AVG(f.profit_margin) AS avg_margin
FROM bi.fact_sales f
GROUP BY f.region
ORDER BY sales DESC;


/* =========================
   DISCOUNT VS MARGIN ANALYSIS
   ========================= */

SELECT
  CASE
    WHEN discount = 0 THEN '0%'
    WHEN discount <= 0.1 THEN '0–10%'
    WHEN discount <= 0.2 THEN '10–20%'
    WHEN discount <= 0.3 THEN '20–30%'
    ELSE '30%+'
  END AS discount_band,
  COUNT(*) AS order_lines,
  SUM(sales) AS sales,
  AVG(profit_margin) AS avg_margin
FROM bi.fact_sales
GROUP BY discount_band
ORDER BY discount_band;
