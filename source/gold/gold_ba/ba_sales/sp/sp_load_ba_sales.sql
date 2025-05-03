CREATE OR REPLACE PROCEDURE `premium-guide-410714.gold_ba.sp_load_ba_sales`(
   v_period STRING ,
   vtable_gold_ba_ba_sales STRING ,
   vtable_silver_transaction_transaction STRING ,
   vtable_silver_transaction_product STRING 
)
BEGIN 


DECLARE v_transation_date_start STRING;
DECLARE v_transaction_date_end STRING;
DECLARE v_sql STRING;



SET v_transation_date_start=(select CAST(  DATE_TRUNC ( cast( v_period||'-01' as date),MONTH) AS STRING ) );
SET v_transaction_date_end=(select  CAST( LAST_DAY( cast( v_period||'-01' as date)) AS STRING ) );

set v_sql = '''
DELETE FROM `'''||vtable_gold_ba_ba_sales||'''`  WHERE process_date="'''||v_transation_date_start||'''";
''';

execute immediate v_sql;

set v_sql = '''
INSERT INTO  `'''||vtable_gold_ba_ba_sales||'''` 
(
  user_id,process_date ,sales_intimates,sales_jeans,sales_sweaters
) 
select a.user_id, CAST("'''||v_transation_date_start||'''"  AS DATE) process_date,
sum ( case when  b.category = ("Intimates") then  a.sale_price end )  sales_intimates,
sum ( case when  b.category = ("Jeans") then  a.sale_price end )  sales_jeans,
sum ( case when  b.category = ("Sweaters") then  a.sale_price end )  sales_sweaters
from   `'''||vtable_silver_transaction_transaction||'''`  a
inner join `'''||vtable_silver_transaction_product||'''` b
on a.product_id=b.id
where 
a.transaction_date between  "'''||v_transation_date_start||'''"  and  "'''||v_transaction_date_end||'''" 
and  b.category in ("Intimates","Jeans","Sweaters")
group by 1 ;
''';


execute immediate v_sql;


END
;