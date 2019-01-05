-- hive 调优

DROP TABLE IF EXISTS onecol;
CREATE TABLE IF NOT EXISTS onecol (number INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

LOAD DATA LOCAL INPATH '/Users/zhoudunxiong/Code/programming-hive/src/main/scala/chap10/data.txt'
OVERWRITE INTO TABLE onecol;

DESCRIBE onecol;

SELECT * FROM onecol;

SELECT sum(number) FROM onecol;

EXPLAIN SELECT sum(number) FROM onecol;

-- 可以使用explain和explain extented来显示查询计划

-- 限制调整，limit语句可以限制查询的结果，但是大部分情况下，使用了limit还是需要执行这个查询再来筛选出限制的数据，这样会造成浪费
-- 但是hive可以配置一些属性，使用limit的时候，可以对查询的数据进行抽样

set hive.limit.optimize.enable = true
set hive.limit.row.max.size = 100000
set hive.limit.optimize.limit.file = 10
因为limit使用的是抽样，所以抽样的数据可能不包含用户想要的数据

