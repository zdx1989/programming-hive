 hive --define foo=bar

 set foo;
 set hivevar:foo;
 set hivevar:foo=bar2;
 set foo;
 set hivevar:foo;

 ## hivevar 命名空间 可读可写 用户自定义变量
 ## hivevar: 是可选的，--hivevar和--define标记是相同的

