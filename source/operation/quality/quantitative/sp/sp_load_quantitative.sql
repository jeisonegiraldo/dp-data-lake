
CREATE OR REPLACE PROCEDURE `premium-guide-410714.quality.sp_load_quantitative`(
vtable_quality_quantitative  STRING ,
vtable STRING ,
vprocess_date STRING 
)
BEGIN 

DECLARE v_sql STRING;



set v_sql = '''
DELETE FROM  `'''||vtable_quality_quantitative||'''`  WHERE process_date=  "'''||vprocess_date||'''"    ;

''';


execute immediate v_sql;




set v_sql = '''
INSERT INTO   `'''||vtable_quality_quantitative||'''` 
(
process_date ,
table ,
column  ,
cant  ,
_nulls ,
avg   ,
min  ,
max  ,
std  
)

SELECT process_date ,
"'''||vtable||'''"  table ,
"sales_intimates" column ,
COUNT(sales_intimates) cant ,
COUNT( CASE WHEN sales_intimates IS NULL THEN 1 END )_nulls ,
avg(sales_intimates) avg   ,
min(sales_intimates)  min,
max(sales_intimates)  max ,
stdDEV(sales_intimates) std  
FROM `'''||vtable||'''`
WHERE 
process_date=  "'''||vprocess_date||'''"
GROUP BY ALL  
UNION ALL  
SELECT process_date ,
"'''||vtable||'''"  table ,
"sales_jeans" column ,
COUNT(sales_jeans) cant ,
COUNT( CASE WHEN sales_jeans IS NULL THEN 1 END )_nulls ,
avg(sales_jeans) avg   ,
min(sales_jeans)  min,
max(sales_jeans)  max ,
stdDEV(sales_jeans) std  
FROM `'''||vtable||'''`
WHERE 
process_date=  "'''||vprocess_date||'''"
GROUP BY ALL  
UNION ALL  
SELECT process_date ,
"'''||vtable||'''"  table ,
"sales_sweaters" column ,
COUNT(sales_sweaters) cant ,
COUNT( CASE WHEN sales_sweaters IS NULL THEN 1 END )_nulls ,
avg(sales_sweaters) avg   ,
min(sales_sweaters)  min,
max(sales_sweaters)  max ,
stdDEV(sales_sweaters) std  
FROM `'''||vtable||'''`
WHERE 
process_date=  "'''||vprocess_date||'''"
GROUP BY ALL  

;

''';

execute immediate v_sql;


END;


