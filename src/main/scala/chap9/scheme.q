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

-- 同一份多种处理
-- hive可以从一个数据源产生多次聚合，不必每次都扫描

INSERT OVERWRITE TABLE sales
SELECT * FROM history WHERE action = 'purchased';

INSERT OVERWRITE TABLE credits
SELECT * FROM history WHERE action = 'returned';

-- 上面的操作可以合成

FROM history
INSERT OVERWRITE table sales WHERE action = 'purchased'
INSERT OVERWRITE table credits WHERE action = 'returned';

--分桶表的数据存储
--分区提供了隔离数据和优化查询的便利方式，但是不是所有的数据集都可以形成合理的分区
--分桶是将数据集分解成更容易管理的若干部分的另一种技术

-- hive会限制创建动态分区的最大数量, hive.exec.max.dynamic.partitions = 1000
-- 用來限制創建過多的分區，导致超过文件系统的处理能力，如下命令是可能失败的

CREATE TABLE IF NOT EXISTS weblog (
    url STRING,
    source_ip STRING,
)
PARTITIONED BY (dt STRING, user_id INT);

INSERT OVERWRITE TABLE weblog
PARTITION (dt = '2012-06-08', user_id)
SELECT url, source_id, user_id
FROM raw_weblog;

-- 由于会有很多不同的user_id所以上面的sql语句会动态的创建很多的分区，导致失败
-- 一种更好的方案是对表weblog进行分桶，并使用user_id作为分桶字段，字段会根据用户指定的值进行哈希分发到桶中去
-- 同一个user_id会分发到同一个桶中去，但是同一个桶内可能装着好几种user_id
-- 例如user_id为1、3、4、8，加入分桶数为3，着0桶: [3], 1桶: [1, 4], 2桶: [8]
-- weblog表也可以做相同的处理

CREATE TABLE IF NOT EXISTS weblog (user_id INT, url STRING, source_ip STRING)
PARTITIONED BY (dt STRING)
CLUSTER BY (user_id) INTO 96 BUCKETS;

-- 表声明只是定义了元数据，如何表数据插入表中完全取决于用户自己

set hive.enforce.bucketing = true;

INSERT OVERWRITE TABLE IF NOT EXISTS
PARTITION (dt = '2018-01-29')
SELECT user_id, url, source_ip
FROM raw_weblog;

set mapred.reducer.tasks = 96;

INSERT OVERWRITE TABLE IF NOT EXISTS
PARTITION (dt = '2018-01-29')
SELECT user_id, url, source_ip
FROM raw_weblog
CLUSTER BY (user_id);

-- 分桶表有利于高校的map-join

--为表增加列

-- SerDe通常都是从左到右进行解析，SerDe通常是非常宽松的，加入某行的字段比预期的字段少，缺少的字段会返回null
-- 加入某行的字段比预期的字段多，多出的字段会被忽略掉
-- 方便的为已有的表增加字段

DROP TABLE IF EXISTS weblogs;
CREATE TABLE IF NOT EXISTS weblogs(version BIGINT, url STRING)
PARTITIONED BY (hit_date INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

LOAD DATA LOCAL INPATH '/Users/zhoudunxiong/Code/programming-hive/src/main/scala/chap9/log1.txt'
OVERWRITE INTO TABLE weblogs
PARTITION (hit_date = 20110101);

LOAD DATA LOCAL INPATH '/Users/zhoudunxiong/Code/programming-hive/src/main/scala/chap9/log2.txt'
OVERWRITE INTO TABLE weblogs
PARTITION (hit_date = 20110102);

ALTER TABLE weblogs ADD COLUMNS (user_id STRING);

SELECT * FROM weblogs;

-- 这种方式不能在表的中间或者开始添加字段

-- 使用列存储表

-- hive通常是使用行式存储的，但是也可以使用列式存储， 下面的情况适合使用列式存储
-- 某一列有很多的重复数据
-- 某张表有很多的列，但是查询的时候只能够查询少数一些字段
-- RCFile和ORC都是列式存储的格式

-- 总是使用压缩


