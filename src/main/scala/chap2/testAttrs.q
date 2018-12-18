 hive --define foo=bar

 set foo;
 set hivevar:foo;
 set hivevar:foo=bar2;
 set foo;
 set hivevar:foo;

 ## hivevar 命名空间 可读可写 用户自定义变量
 ## hivevar: 是可选的，--hivevar和--define标记是相同的

 create table toss1(i int, ${hivevar:foo} string);
 describe table toss1;

 create table toss2(i int, ${foo} string);
 describe table toss2;

 drop table toss1;
 drop table toss2;

