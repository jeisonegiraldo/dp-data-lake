CREATE OR REPLACE PROCEDURE `premium-guide-410714.silver_transaction.sp_load_transaction`(
v_transation_date_start STRING,
v_transaction_date_end STRING,
vtable_silver_transaction_transaction STRING ,
vtable_source_transaction STRING 
)
BEGIN 

DECLARE v_sql STRING;

set v_sql = '''

DELETE FROM  `'''||vtable_silver_transaction_transaction||'''`
WHERE transaction_date between "'''||v_transation_date_start||'''" and "'''||v_transaction_date_end||'''" ;

''';

execute immediate v_sql;

set v_sql = '''

INSERT INTO  `'''||vtable_silver_transaction_transaction||'''`
  (
  id ,
  order_id ,
  user_id ,
  product_id ,
  inventory_item_id ,
  status ,
  transaction_date ,
  created_at ,
  shipped_at ,
  delivered_at ,
  returned_at ,
  sale_price 
  )
  SELECT 
  id ,
  order_id ,
  user_id ,
  product_id ,
  inventory_item_id ,
  status ,
  CAST(created_at AS DATE) transaction_date ,
  created_at ,
  shipped_at ,
  delivered_at ,
  returned_at ,
  sale_price   
 FROM
  `bigquery-public-data.thelook_ecommerce.order_items`
  where created_at >= "'''||v_transation_date_start||'''"  
  and created_at< CAST( (CAST( "'''||v_transaction_date_end||'''" AS DATE)+1) AS TIMESTAMP)
  ;



''';

execute immediate v_sql;



END;


