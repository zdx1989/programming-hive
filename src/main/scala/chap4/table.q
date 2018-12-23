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