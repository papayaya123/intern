USE test_for_intern;

-- 1.

SELECT *
FROM default_table
WHERE address IS NOT NULL                      -- 排除 NULL
  AND address LIKE '%市%' OR address LIKE '%縣%'   -- 縣市
  AND (address LIKE '%區%' OR address LIKE '%鄉%' OR address LIKE '%鎮%' OR address LIKE '%市%') -- 區/鄉/鎮/市
  AND (address LIKE '%路%' OR address LIKE '%街%' OR address LIKE '%段%')  -- 路/街/段
  AND address LIKE '%號%';                     -- 必須有門牌號


-- 2.

-- (1) 小型車計時 > 200 元/小時

SELECT name, address, payex
FROM default_table
WHERE payex LIKE '%小型車計時%'
  AND CAST(
        REPLACE(
          SUBSTRING_INDEX(
            SUBSTRING_INDEX(payex, '小型車計時', -1),
            '元', 1
          ),
        ',', '')
      AS UNSIGNED
  ) > 200;


-- 2) 專屬月租場站（有月租、無計時/計次）

SELECT name, address, payex
FROM default_table
WHERE payex LIKE '%月租%'
  AND payex NOT LIKE '%計時%'
  AND payex NOT LIKE '%計次%';


-- 專屬機車停車場（僅機車位 > 0）

SELECT name, address, payex
FROM default_table
WHERE COALESCE(TOTALCAR, 0) = 0
  AND COALESCE(TOTALBIKE, 0) = 0
  AND COALESCE(TOTALMOTOR, 0) > 0
  AND payex LIKE '%機車%'
  AND payex NOT LIKE '%小型車%';


-- 4) 總車位數為 0 或空值

select * 
FROM default_table 
where (TOTALCAR = 0 or TOTALCAR is NULL) 
and (TOTALMOTOR = 0 or TOTALMOTOR is NULL) 
and (TOTALBIKE = 0 or TOTALBIKE IS NULL) ;



-- 合起來的

SELECT '小型車計時>200' AS category, name, address, payex
FROM default_table
WHERE payex LIKE '%小型車計時%'
  AND CAST(
        REPLACE(
          SUBSTRING_INDEX(
            SUBSTRING_INDEX(payex, '小型車計時', -1),  
            '元', 1                                     
          ),
        ',', '')
      AS UNSIGNED
  ) > 200

UNION ALL

SELECT '專屬月租' AS category, name, address, payex
FROM default_table
WHERE payex LIKE '%月租%'  
  AND NOT (payex LIKE '%時%' OR payex LIKE '%次%')

UNION ALL

SELECT '專屬機車' AS category, name, address, payex
FROM default_table
WHERE 
  TOTALCAR = 0 
  AND TOTALMOTOR > 0 
  AND (TOTALBIKE = 0 OR TOTALBIKE IS NULL) 
  AND payex LIKE '%機%'

UNION ALL

SELECT '總車位=0或空' AS category, name, address, payex
FROM default_table
WHERE (TOTALCAR = 0 OR TOTALCAR IS NULL)
  AND (TOTALMOTOR = 0 OR TOTALMOTOR IS NULL)
  AND (TOTALBIKE = 0 OR TOTALBIKE IS NULL);


-- 3. 缺漏比例

-- 每一列是一個欄位的缺漏統計
SELECT 'name' AS field,
       COUNT(*) AS total_rows,
       SUM(CASE WHEN name IS NULL OR TRIM(name) = '' THEN 1 ELSE 0 END) AS missing_rows,
       ROUND(100.0 * SUM(CASE WHEN name IS NULL OR TRIM(name) = '' THEN 1 ELSE 0 END) / COUNT(*), 2) AS missing_pct
FROM default_table

UNION ALL
SELECT 'address',
       COUNT(*),
       SUM(CASE WHEN address IS NULL OR TRIM(address) = '' THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN address IS NULL OR TRIM(address) = '' THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM default_table

UNION ALL
SELECT 'tel',
       COUNT(*),
       SUM(CASE WHEN tel IS NULL OR TRIM(tel) = '' THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN tel IS NULL OR TRIM(tel) = '' THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM default_table

UNION ALL
SELECT 'payex',
       COUNT(*),
       SUM(CASE WHEN payex IS NULL OR TRIM(payex) = '' THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN payex IS NULL OR TRIM(payex) = '' THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM default_table

UNION ALL
SELECT 'servicetime',
       COUNT(*),
       SUM(CASE WHEN servicetime IS NULL OR TRIM(servicetime) = '' THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN servicetime IS NULL OR TRIM(servicetime) = '' THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM default_table

UNION ALL
SELECT 'tw97x',
       COUNT(*),
       SUM(CASE WHEN tw97x IS NULL THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN tw97x IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM default_table

UNION ALL
SELECT 'tw97y',
       COUNT(*),
       SUM(CASE WHEN tw97y IS NULL THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN tw97y IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM default_table

UNION ALL
SELECT 'totalcar',
       COUNT(*),
       SUM(CASE WHEN totalcar IS NULL THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN totalcar IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM default_table

UNION ALL
SELECT 'totalmotor',
       COUNT(*),
       SUM(CASE WHEN totalmotor IS NULL THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN totalmotor IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM default_table

UNION ALL
SELECT 'totalbike',
       COUNT(*),
       SUM(CASE WHEN totalbike IS NULL THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN totalbike IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM default_table;

