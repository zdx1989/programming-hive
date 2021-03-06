-- 确定安装编解码器
set io.compression.codecs;

-- 选择一种压缩编解码
-- 使用压缩的优势是可以减少磁盘的存储空间，减少磁盘的和网络IO操作，但是压缩和解压的过程都会增长CPU的开销。
-- 但是hive处理的job大多数情况下都是IO密集型的， 不是CPU密集型的
-- 为什么需要这么多种压缩算法，因为不同的压缩算法都会在压缩速率和压缩效率之间进行权衡
-- LZO和snappy相比于GZIP和BZip2压缩比要小，但是压缩和解压缩的速度会更快些
-- 另外需要考虑的因素是压缩的文件格式是否是可以分割的
-- 块级别的压缩
-- 对于文本格式，文件是通过\n(换行符)作为默认的行分隔符, 将文件划分，并将划分转化记录
-- 用户没有使用文本格式时，需要指出InputFormat和OutPutFormat
-- hive需要SerDe(序列化和反序列化)将记录分解成列（字段）或者把字符组合成记录

-- 开启中间压缩
set hive.exec.compress.intermidiate = true
-- 中间压缩可以选着一个合适的编解码器
set mapred.map.output.compression.codec = snappy

-- 开启最终输出结果压缩
set hive.exec.compress.output = true
-- 对于输出压缩可以使用gzip（压缩空间最多）， 注意gzip是不可以分割的

-- sequenceFile
-- 压缩文件可以节省存储空间，但是在Hadoop中直接存储裸压缩文件有一个缺点就是，通常这些文件都是不可分割的
-- Hadoop支持的sequenceFile可以将文件划分成多个块，然后采用一种可分割的方式对文件进行压缩

-- 如何早hive中使用sequenceFile

CREATE TABLE IF NOT EXISTS sequence_file STORED AS SEQUENCEFILE

-- sequence file 提供了三种压缩方式，NONE, RECORD, BLOCK, 默认的压缩方式是RECORD
-- 不过通常来说，BLOCK级别压缩性能最好，而且是可以分割的

-- 在mapred-site.xml或者hive-site.xml文件中进行定义

set mapred.output.compression.type = BLOCK

--使用压缩实践

--开启中间数据压缩

drop table if exists table_a;
create table if not exists table_a (a int, b int)
row format delimited fields terminated by ',';

load data local inpath '/Users/zhoudunxiong/Code/programming-hive/src/main/scala/chap11/data.txt'
overwrite into table table_a;

select * from table_a;


drop table if exists intermediate_comp_on;

create table if not exists intermediate_comp_on
row format delimited fields terminated by ','
as select * from table_a;

--开启输出结果压缩
set hive.exec.compress.output=true;

create table if not exists final_com_on
row format delimited fields terminated by ','
as select * from table_a;

dfs -ls /user/hive/warehouse/mydb.db/final_com_on;
dfs -cat /user/hive/warehouse/mydb.db/final_com_on/000000_0.deflate;

select * from final_com_on;

-- 使用Gzip进行压缩
set mapred.output.compression.codec=org.apache.hadoop.io.compress.GzipCodec;

create table if not exists final_comp_on_gz
row format delimited fields terminated by ','
as select * from table_a;

dfs -ls /user/hive/warehouse/mydb.db/final_comp_on_gz;

select * from final_comp_on_gz;

! /bin/zcat /user/hive/warehouse/mydb.db/final_comp_on_gz/000000_0.gz;

--使用sequenceFile

set mapred.output.compression.type=BLOCK;

create table if not exists final_comp_on_gz_seq
row format delimited fields terminated by ','
stored as sequencefile
as select * from table_a;

dfs -ls /user/hive/warehouse/final_comp_on_gz_seq;

dfs -cat /user/hive/warehouse/final_comp_on_gz_seq/000000_0

dfs -text /user/hive/warehouse/final_comp_on_gz_seq/000000_0

--存档分区

create table if not exists hive_text(line string)
partitioned by (folder string);

load data local inpath '${env:HIVE_HOME}/RELEASE_NOTES.txt'
into table hive_text partition(folder='doc');

load data local inpath '${env:HIVE_HOME}/NOTICE'
into table hive_text partition(folder='doc');

dfs -ls /user/hive/warehouse/mydb.db/hive_text/folder=doc;

set hive.archive.enabled=true;

alter table hive_text archive partition (folder = 'docs');


