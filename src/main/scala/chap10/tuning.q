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