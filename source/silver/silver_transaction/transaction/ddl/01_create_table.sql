CREATE TABLE IF NOT EXISTS `premium-guide-410714.silver_transaction.transaction`
(
  id INT64,
  order_id INT64,
  user_id INT64,
  product_id INT64,
  inventory_item_id INT64,
  status STRING,
  transaction_date DATE,
  created_at TIMESTAMP,
  shipped_at TIMESTAMP,
  delivered_at TIMESTAMP,
  returned_at TIMESTAMP,
  sale_price FLOAT64
)
PARTITION BY transaction_date
;