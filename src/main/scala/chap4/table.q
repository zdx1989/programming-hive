DROP DATABASE IF EXISTS mydb;
CREATE DATABASE IF NOT EXISTS mydb;

DROP TABLE IF EXISTS mydb.employees;
CREATE TABLE IF NOT EXISTS mydb.employees (
    name STRING COMMENT 'employee name',
    salary STRING COMMENT 'employee salary',
    subordinates ARRAY<STRING> COMMENT 'names of subordinates',
    deductions Map<String, float> COMMENT '',
    address STRUCT<street: STRING, city: STRING, state: STRING, zip: INT> COMMENT 'home address'
)
COMMENT 'DESCRIPTION OF TABLE'
LOCATION '/user/hive/warehouse/mydb.db/employees';

CREATE TABLE IF NOT EXISTS mydb.employees2
LIKE mydb.employees;

--用户拷贝一张表的模式，而不拷贝表的数据

SHOW TABLES IN mydb;

--列出databases下面所有的表

SHOW TABLES  'empl.*';

-- 可以使用正则表达式来适配表名

DESCRIBE FORMATTED mydb.employees;

--  可以输出表的详细信息

-- 内部表，管理表，存储的路径为/user/hive/warehouse/xx.db/xxx，有hive控制器数据的生命周期，删除表的同时，会删除表中的数据
-- 外部表，hive和其他的工具例如pig共享的数据源，可以为表指定LOCATION，删除外部表，只是删除了表的元数据，表中的数据不会被删除

DROP TABLE IF EXISTS stocks;
CREATE EXTERNAL TABLE IF NOT EXISTS stocks (
    `exchange`  STRING,
    symbol     STRING,
    ymd        STRING,
    price_open FLOAT,
    price_high FLOAT,
    price_low  FLOAT,
    price_close FLOAT,
    volume      INT,
    price_adj_close FLOAT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/data/stocks';

CREATE TABLE IF NOT EXISTS mydb.employees3
LIKE mydb.employees
LOCATION '/path/to/data'

--复制外部表的模式，但是不会复制表的数据

DROP TABLE IF EXISTS employees;
CREATE TABLE IF NOT EXISTS employees (
    name         STRING,
    salary       FLOAT,
    subordinates ARRAY<STRING>,
    deductions   MAP<STRING, FLOAT>,
    address      STRUCT<street: STRING, city: STRING, state: STRING, zip: INT>
)
PARTITIONED BY (country STRING, state STRING);

-- 表分区可以缩小查询时数据集的范围，表分区改变数据的存储目录，对应的分区数据存储到对应的分区目录下