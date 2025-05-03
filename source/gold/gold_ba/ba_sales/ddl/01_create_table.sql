CREATE TABLE IF NOT EXISTS`premium-guide-410714.gold_ba.ba_sales`
(
  user_id INT64,
  process_date DATE,
  sales_intimates FLOAT64,
  sales_jeans FLOAT64,
  sales_sweaters FLOAT64
)
PARTITION BY process_date
;