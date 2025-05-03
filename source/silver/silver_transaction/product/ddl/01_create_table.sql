CREATE TABLE IF NOT EXISTS `premium-guide-410714.silver_transaction.product`
(
  id INT64,
  cost FLOAT64,
  category STRING,
  name STRING,
  brand STRING,
  retail_price FLOAT64,
  department STRING,
  sku STRING,
  distribution_center_id INT64 ,
  load_date DATETIME ,
  user_created  STRING,
  update_date DATETIME ,
  user_update STRING 
);