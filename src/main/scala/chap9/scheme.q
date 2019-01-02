--按天划分的表
--在关系数据库中，经常会有在表名中加入一个时间戳的方式，例如supply_2011_01_01, supply_2011_01_02每天生成一张表
--在hive中，使用分区表来代替这种情况
CREATE TABLE IF NOT EXISTS supply (
    id INT,
    part STRING,
    quantity INT
)
PARTITIONED BY (day INT);

ALTER TABLE supply ADD PARTITION(day = 20111001);
ALTER TABLE supply ADD PARTITION(day = 20111002);
ALTER TABLE supply ADD PARTITION(day = 20111003);

LOAD DATA INPATH 'XXXXX' OVERWRITE INTO TABLE supply PARTITION(day = 20111001);
LOAD DATA INPATH 'XXXXX' OVERWRITE INTO TABLE supply PARTITION(day = 20111002);
LOAD DATA INPATH 'XXXXX' OVERWRITE INTO TABLE supply PARTITION(day = 20111003);

SELECT part, quantity FROM supply
WHERE day >= 20111002 AND day <= 20111003 AND quantity < 4;

-- 先使用分区字段过滤，然后在使用普通字段过滤

-- 关于分区
-- hive默认情况下进行全盘扫描来满足查询条件（先忽略掉hive的索引功能），通过创建分区可以缩小扫描的数据量
-- 这在一些查询中可以提高性能，但是使用分区也可能在一些不利的因素
-- hive底层使用HDFS来存储数据，HDFS被设计来存储大文件而不是存储大量的小文件，一个分区就对应着一个文件夹
-- 和大量的文件，所以过多的分区必然会给NameNode带来压力，因为HDFS中的元数据都存在HDFS的内存中。

CREATE TABLE weblogs(url STRING, time LONG)
PARTITIONED BY (day INT, state STRING, city STRING);

SELECT * FROM weblog WHERE day = 20110102;

例如上面的表的分区字段就显得过多了，时间维度的分区字段day和两个地区维度分区字段state、city
可以使用一个时间维度的分区字段或者一个时间维度的分区字段加一个地区维度的字段

CREATE TABLE weblog(url STRING, time LONG)
PARTITIONED BY (day INT, state STRING);

SELECT * FROM weblog WHERE day = 20110102 AND state = 'CA';

--使用上面的分区同样可能出现问题，一些州的数据多一些州的数据少，这样会导致map task处理数据的时候出现不均匀的现象（数据倾斜）
--加入找不到合适的分区方式，可以使用分桶存储

-- 唯一键和标准化

--


