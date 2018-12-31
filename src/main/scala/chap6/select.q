-- 对于符合类型的列如何筛选字段
-- 对于数组类型可以使用下标来操作
SELECT subordinates[1] FROM employees WHERE country = 'US';

-- 对Map类型使用key来检索value值
SELECT deductions["state taxes"] FROM employees WHERE country = 'US';

-- 对于Struct类型使用属性名来检索属性值
SELECT address.city FROM employees WHERE country = 'US';


-- 可以使用正则表达式来指定列
SELECT symbol, `price.*` FROM stocks;

-- 并没有生效？

-- 可以使用列值进行计算，用户不仅可以选择表中的列，还可以使用函数调用和算术运算来操作列值

-- 常用函数分类
-- 常用数学函数
-- round(Double d) 返回d的BigInt的近似值, floor(Double d)返回<= d的最大BigInt值, ceil(Double d) 返回>=d 的最小的BigInt值

-- 常用聚合函数
-- count(*) 计算总行数，包含null的行；count(expr)计算expr表达式的值非null的行
-- sum(col) 计算指定行的和；avg(col) 计算指定行的平均值
SET hive.map.aggr=true 设置该属性可以触发map阶段的预聚合，减少reduce时的数据量，提高性能，不过该设置会消耗更多的内存
SELECT count(*), avg(salary) FROM employees;

-- 常用表生成函数
-- 表生成函数和聚合函数相反，聚合函数将多行聚合成一行，表生成函数是将一行生成多行
-- explode(Array arr)返回0到多行的结果，每一行对应数组的一个元素
SELECT EXPLODE(subordinates) AS sub FROM employees;

-- 其他内置函数和时间处理有关的函数

-- LIMIT语句
-- 列别名
-- 嵌套SELECT语句
-- CASE WHEN THEN语句和if else语句很想，用于处理单个列的查询结果

SELECT name, salary,
    CASE
        WHEN salary < 10000 THEN 'low'
        WHEN salary >= 10000 AND salary < 20000 THEN 'middle'
        WHEN salary >= 20000 THEN 'high'
    END AS bracket FROM employees;

-- 如何避免进行MapReduce
-- 大部分查询都会触发一个mapreduce的job，但是hive对于有些查询时不会触发mapreduce，也就是所谓的本地模式
SET hive.exec.model.local.auto=true
-- 设置该属性hive还是尝试使用本地模式执行其他的操作

-- WHERE语句
-- 不能在WHERE语句中使用别名, 不过可以使用嵌套查询来处理
SELECT name, salary,
    CASE
        WHEN salary < 10000 THEN 'low'
        WHEN salary >= 10000 AND salary < 20000 THEN 'middle'
        WHEN salary >= 20000 THEN 'high'
    END AS bracket FROM employees
WHERE bracket = 'high';
-- 上面的SQL语句不能通过，因为不能再WHERE语句使用别名，不过可以使用嵌套查询来替换
SELECT e.* FROM
    (SELECT name, salary,
        CASE
            WHEN salary < 10000 THEN 'low'
            WHEN salary >= 10000 AND salary < 20000 THEN 'middle'
            WHEN salary >= 20000 THEN 'high'
        END AS bracket FROM employees) AS e
WHERE bracket = 'high';

-- 谓语操作符
-- LIKE和RELIKE

-- GROUP BY 语句
-- GROUP 通常会和聚合函数一起使用，按照一个或者多个列进行分组，然后对每个组进行聚合操作
SELECT avg(salary), country, state FROM employees
GROUP BY country, state;

-- HAVING 语句
-- HAVING 可以替代SELECT FROM GROUP BY WHERE，例如：

SELECT s2.avg, s2.country, s2.state FROM
    (SELECT avg(salary) AS avg, country, state
     FROM employees
     GROUP BY country, state) s2
WHERE avg >= 10000;

-- 上面嵌套查询可以使用HAVING来替换

SELECT avg(salary), country, state
FROM employees
GROUP BY country, state
WHERE avg(salary) >= 10000;

-- WHERE字句中不能含有函数，也不能使用表的别名？

-- hive支持通常的SQL JOIN 但是只支持等值连接？

-- 内连接（INNNER JOIN）
LOAD DATA LOCAL INPATH '/Users/zhoudunxiong/Code/programming-hive/data/stocks'
OVERWRITE INTO TABLE stocks;

SELECT a.ymd, a.price_close, b.price_close
FROM stocks a JOIN stocks b ON a.ymd <= b.ymd
WHERE a.symbol = 'AAPL' AND b.symbol = 'IBM'
LIMIT 10;

-- 非自连接
SELECT s.ymd, s.symbol, s.price_close, d.dividend
FROM stocks s JOIN dividends_import d ON s.ymd = d.ymd AND s.symbol = d.symbol
WHERE s.symbol = 'AAPL';

-- hive 中不支持等值连接，目前版本已经支持？

-- 可以对多张表进行JOIN连接，理论上每对JOIN都会启动一个MapReduce Job，JOIN的顺序总是从左到右的

SELECT a.ymd, a.price_close, b.price_close, c.price_close
FROM stocks a JOIN stocks b ON a.ymd = b.ymd JOIN stocks c ON b.ymd = c.ymd
WHERE a.symbol = 'AAPL' AND b.symbol = 'IBM' AND c.symbol = 'GE'
LIMIT 10;

-- JOIN 的优化

-- JOIN表的顺序，保证连接的表从左到右是依次增大的，也就是先连接最小的表，最后连接最大的表

-- 应该将小表dividends_import放在JOIN的前面

SELECT s.ymd, s.symbol, s.price_close, d.dividend
FROM  dividends_import d JOIN stocks s ON s.ymd = d.ymd AND s.symbol = d.symbol
WHERE s.symbol = 'AAPL';

-- LEFT OUTER JOIN
-- 一左表的记录为准，右表找不到匹配字段的时候返回NULL值

DROP TABLE IF EXISTS dividends_import;
CREATE EXTERNAL TABLE IF NOT EXISTS dividends_import (
    `exchange` STRING,
    symbol   STRING,
    ymd      STRING,
    dividend FLOAT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/data/dividends_import';

LOAD DATA LOCAL INPATH '/Users/zhoudunxiong/Code/programming-hive/data/dividends'
OVERWRITE INTO TABLE dividends_import;

DROP TABLE IF EXISTS dividends;
CREATE EXTERNAL TABLE IF NOT EXISTS dividends (
    ymd      STRING,
    dividend FLOAT
)
PARTITIONED BY (`exchange` STRING, symbol STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/data/dividends';

INSERT OVERWRITE TABLE dividends
PARTITION (`exchange`, symbol)
SELECT e.ymd, e.dividend, e.`exchange`, e.symbol
FROM dividends_import e;

SELECT s.ymd, s.symbol, s.price_close, d.dividend
FROM stocks s LEFT OUTER JOIN dividends_import d ON s.ymd = d.ymd AND s.symbol = d.symbol
WHERE s.symbol = 'AAPL';

-- OUTER JOIN
-- 将分区过滤的内容放在JOIN ON的字句中， 在LEFT OUTER JOIN 中是不可用的，但是在INNER JOIN中是可用的
-- 可以使用嵌套查询来完成，先分区过滤，在JOIN连接的操作

-- RIGHT OUTER JOIN 右连接
-- FULL OUTER JOIN 全连接

-- LEFT SEMI-JOIN
-- 左半开连接会返回左边表的记录，记录需要匹配ON右边的条件
-- SQL方言中会使用IN EXISTS这种结构来处理

SELECT s.ymd, s.symbol, s.price_close
FROM stocks s
WHERE s.ymd, s.symbol IN
(SELECT d.ymd, d.symbol FROM dividends_import d);

-- 使用 LEFT SEMI JOIN 来代替

SELECT s.ymd, s.symbol, s.price_close
FROM stocks s LEFT SEMI JOIN dividends_import d ON s.ymd = d.ymd AND s.symbol = d.symbol;

