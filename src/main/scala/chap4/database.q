-- hive中database的概念仅仅表示一个目录或者明明空间
-- 用户没有显示指database的话，使用的是默认的default

CREATE DATABASE financials;

CREATE DATABASE IF NOT EXISTS financials;

SHOW DATABASES;
CREATE DATABASE human_resources;
SHOW DATABASES;

-- 可以使用正则表达式来匹配筛选出需要的database

SHOW DATABASES LIKE 'h.*';

-- database的存储位置是hive.metastore.warehouse.dir所配置，默认为/user/hive/warehouse/xxxx.db
-- 注意default database在warehouse下没有对应的目录，其下的表的目录直接放在warehouse下
-- 创建其他的database的目录以db结尾，例如/user/hive/warehouse/human_resources.db

DROP DATABASE IF EXISTS financials;
CREATE DATABASE IF NOT EXISTS financials
LOCATION '/user/zhoudunxiong/financials.db';

-- 用户可以为database指定任意的location，存储目录

DROP DATABASE IF EXISTS financials;
CREATE DATABASE IF NOT EXISTS financials
COMMENT 'Hello all financial tables';
DESCRIBE DATABASES financials;

--用户可以为database添加描述

DROP DATABASE IF EXISTS financials;
CREATE DATABASE IF NOT EXISTS financials
with DBPROPERTIES ('creator' = 'zdx', 'date' = '2018-12-23');
DESCRIBE DATABASE financials;
DESCRIBE DATABASE EXTENDED financials;

USE fincancials;

-- 可以为database添加键值对属性

ALTER DATABASE financials SET DBPROPERTIES ('edited-by' = 'Joe Dba');

-通过ALTER DATABASE可以修改database的键值属性，但是database得名字和位置是不能被修改的
