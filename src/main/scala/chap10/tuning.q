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

-- 调整mapper和reducer的个数
-- hive查询会转化成MapReduce任务，每个任务可能具有多个mapper和reducer任务，确定最佳的mapper和reducer个数取决于多个变量
-- 例如输入的数据量大小和对这些数据量执行的操作类型

-- hive是按照输入量大小来确定reducer的个数的，例如
-- 某张表根据分区来查询，具体分区下的数据量是2.7个G，已有hive的配置
set hive.exec.reducers.bytes.per.reducer = 10000000000;
-- 该属性的默认值的是1GB, 那么产生3个reducer，假如修改该属性
set hive.exec.reducers.bytes.per.reducer = 7500000000;
-- 那么将产生4个reducer，这样根据输入表计算出来的reducer个数一般是比较合适的，不过有些情况下map阶段会产生更多的数据量
-- 这个时候按照输入的数据量计算的reducer个数就会少了；而有的时候map阶段会过滤掉很多的数据，这个时候根据输入量计算的reducer
-- 个数就会多了。这个时候可以用户自己配置固定的reducer的个数
set mapred.reducer.tasks = 3;

-- 在共享的集群（多个团队共享一个Hadoop集群）上处理大任务的时候，为了控制资源的使用，属性
set hive.exec.reducers.max;
-- 显得非常重要，一个Hadoop集群可以提供的mapper和reducer资源个数（也称为插槽）是固定的。一个大的任务可能消耗掉所有的插槽，
-- 从而导致其他的job无法执行，该属性可以阻止某个属性消耗太多的reducer资源。该属性值大小的计算公式为
-- 集群总reducer槽位数 * 1.5 / 执行中平均的查询个数

-- JVM重用
-- Hadoop配置都是使用派生JVM实例来执行map和reducer的任务的，对于task非常多的场景，JVM的启动过程会造成相当大的开销，
-- JVM重用可以使得JVM实例在同一个job中使用多次
set mapred.job.reuse.jvm.num.tasks = 10

-- 这个功能的缺点是jvm重用的实例会一直占用task插槽，可能影响其他的任务获取集群的资源

-- 动态分区调整
-- 用户可以通过如下设置开启动态分区的功能：
set hive.exec.dynamic.partition = true;
-- 使用动态分区的时候存在一个隐患，就是用户select出来的分区字段右太多的数据可能导致生成太多的分区
-- 太多的分区会造成过多的文件夹目录和小文件，这个对hdfs的namenode会造成过大的压力，文件目录的元数据都是
-- 存在namenode的内存中，所以需要限制动态分区的使用
set hive.exec.dynamic.partition.mode = strict;
-- 设置动态分区为严格模式的话， 需要保证分区字段中至少有一个是静态分区字段
set hive.exec.max.dynamic.partitions = 10000
-- 可以限制动态分区的可以创建的最大分区的个数

-- 推测执行
-- 推测执行是Hadoop的一个功能，所谓推测执行指的是对于一些执行时间特别慢的任务，Hadoop可以侦查到这些任务，然后
-- 重启一个新的一样的任务，来提高整体的运行效率

-- hive本身也提供了reduce-side的推测执行
set hive.mapred.reduce.tasks.speculative.axecution = true;

-- 虚拟列



