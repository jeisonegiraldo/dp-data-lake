
CREATE OR REPLACE PROCEDURE `premium-guide-410714.silver_transaction.sp_load_product`(
vtable_silver_transaction_products STRING ,
vtable_source_products STRING ,
vtable_operation_tables STRING
)
BEGIN 

DECLARE v_sql STRING;

set v_sql = '''

MERGE `'''||vtable_silver_transaction_products||'''` AS target
USING (
  SELECT
    id,
    cost,
    category,
    name,
    brand,
    retail_price,
    department,
    sku,
    distribution_center_id,
    CURRENT_DATETIME('America/Lima') AS load_date,
    SESSION_USER() AS user_created  ,
    CURRENT_DATETIME('America/Lima') AS update_date,
    SESSION_USER() AS user_update  
  FROM `'''||vtable_source_products||'''`
) AS source
ON target.id = source.id
WHEN MATCHED THEN
  UPDATE SET
    target.cost = source.cost,
    target.category = source.category,
    target.name = source.name,
    target.brand = source.brand,
    target.retail_price = source.retail_price,
    target.department = source.department,
    target.sku = source.sku,
    target.distribution_center_id = source.distribution_center_id
WHEN NOT MATCHED THEN
  INSERT (
    id,
    cost,
    category,
    name,
    brand,
    retail_price,
    department,
    sku,
    distribution_center_id,
    load_date,
    user_created,
    update_date,
    user_update
  )
  VALUES (
    source.id,
    source.cost,
    source.category,
    source.name,
    source.brand,
    source.retail_price,
    source.department,
    source.sku,
    source.distribution_center_id,
    source.load_date,
    source.user_created ,
    source.update_date,
    source.user_update
  )
;
''';




execute immediate v_sql;

set v_sql = '''
DELETE FROM  `'''||vtable_operation_tables||'''`  WHERE process_date=CURRENT_DATE("America/Lima")  ;

''';


execute immediate v_sql;




set v_sql = '''
INSERT INTO   `'''||vtable_operation_tables||'''` 
(
process_date ,
table ,
type ,
_rows  ,
_rows_origin  ,
duplicates  
)

WITH  origin AS (
SELECT COUNT(1) cant
FROM `'''||vtable_source_products||'''`
)
,  destination AS
(

SELECT COUNT(1) cant,  COUNT(1) -count(distinct id) duplicates  
FROM  `'''||vtable_silver_transaction_products||'''`

)
select  
CURRENT_DATE("America/Lima") process_date ,
"'''||vtable_silver_transaction_products||'''" table ,
"master" type ,
b.cant  _rows  ,
a.cant  _rows_origin  ,
b.duplicates duplicates  
from origin a ,  destination b ;



''';

execute immediate v_sql;


END;


