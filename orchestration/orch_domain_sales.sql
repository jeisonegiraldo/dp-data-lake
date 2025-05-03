
CALL `premium-guide-410714.silver_transaction.sp_load_product`
(
  'premium-guide-410714.silver_transaction.product',
  'bigquery-public-data.thelook_ecommerce.products' ,
  'premium-guide-410714.operation.tables'
);

CALL `premium-guide-410714.silver_transaction.sp_load_transaction`
(
  '2025-04-01',
  '2025-04-30',
  'premium-guide-410714.silver_transaction.transaction',
  'bigquery-public-data.thelook_ecommerce.order_items'
) ;


CALL `premium-guide-410714.gold_ba.sp_load_ba_sales`
(
  '2025-04' ,
  'premium-guide-410714.gold_ba.ba_sales',
  'premium-guide-410714.silver_transaction.transaction',
  'premium-guide-410714.silver_transaction.product'
) ;

CALL `premium-guide-410714.quality.sp_load_quantitative`
(
   'premium-guide-410714.quality.quantitative',
  'premium-guide-410714.gold_ba.ba_sales',
  '2025-04-01'
) ;
