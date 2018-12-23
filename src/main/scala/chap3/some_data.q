CREATE TABLE some_data (
    first  FLOAT,
    second FLOAT,
    third  FLOAT
)
ROW FORMAT DELIMITED
    FIELDS TERMINATED BY ',';

LOAD DATA LOCAL INPATH '/Users/zhoudunxiong/Code/programming-hive/src/main/scala/chap3/some_data.txt'
INTO TABLE some_data;

--导入或者插入数据的时候hive和关系数据库存在不同，关系数据库为写时模式，hive为读时模式
--关系数据库在导入或者写入数据的时候会严格校验导入的数据和表的模式是否匹配，不匹配的话会导入数据失败
--hive在导入的时候不会做任何校验，可以随意导入数据，在读取时候会校验导入的数据和标的模式是否匹配
--不过hive会尽可能的从数据和模式不匹配中恢复过来，加入数据比模式缺少之列时，缺少的列会被填充null，模式不匹配的时候也会返回列