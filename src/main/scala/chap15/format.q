--文本格式和sequencefile的区别
create table text (x int);
describe formatted text;

create table seq (x int) stored as sequencefile;
describe formatted seq;

-- 文件格式

-文本文件格式 store as textfile 文本文件便于查看，便于和其他的工具进行共享

-- sequenceFile store as squenceFile sequenceFile含有键值对的二进制文件， sequenceFile可以
-- 选着块级别的压缩和记录级别的压缩，按照块级别的分割文件

-- RCFile

-- 对于特定类型的数据，使用列式存储可能会有更好的效果。
-- 表的字段很多，多大上百个字段，而每次查询只是用其中小部分字段，这样的表可以使用列式存储，每次只扫描小部分字段，可以提供性能
-- RCFile 便提供了列式存储的机制

