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
-- 因为limit使用的是抽样，所以抽样的数据可能不包含用户想要的数据

-- join 优化
-- join 的时候将表按照从小到大的顺序从左到右join，将最大的表放在最右边
-- 加入一张表足够小，小到完全可以载入到内存时，可以使用map-side join
-- 如何开启map-side join

set hive.auto.convert.join = true
set hive.mapjoin.smalltable.filesize = 2500000

-- 本地模式

-- hive输入的数据量非常小的时候, 这个时候触发执行任务消耗的时间可能比任务执行的时间还长
-- 对于这种情况可是使用本地模式，在单个机器单个进程中处理所有的任务，对于小数据集，可以明显缩短执行时间

set hive.exec.mode.local.auto = true;

-- 并行执行
-- hive会将查询转化为各个阶段（stage），各个阶段可能是相互依赖的，也有可能不是相互依赖的，
-- 二这些不存在相互依赖的阶段是可以并行执行的。通过设置下面的参数，可以开启并行执行。

set hive.exec.parallel = true

-- 设置并行执行后，集群的利用率会增加

-- 严格模式
-- hive提供了一种严格模式，可以防止用户执行那些可能产生不好影响的查询

set hive.mapred.mode = strict

-- 严格模式可以限制三种查询

-- 对于分区表查询，除非分区表的where字句中含有分区的过滤条件，要不不允许查询，这样做的原因是因为
-- 分区表通常都非常大，而且分区表的增长速度非常开，所以为了避免全表扫描，必须在查询的时候制定分区

-- 对于使用了ORDER BY字句的查询， 必须使用LIMIT，要不不允许执行。ORDER BY字句会触发全量排序，
-- 导致所有的数据都在一个reducer中排序，这个时候需要使用limit，避免reducer而外执行很长的时间

-- 对于笛卡尔积（只有join，没有on匹配字段进行连接）查询， 限制执行。
-- hive和关系数据库不一样的地方，对于JOIN WHERE关系数据会自动优化成JOIN ON，而在hive中不存在这种优化
-- 这时候会产生一个笛卡尔查询， 假如表很大，那么结果是完全不可控的



