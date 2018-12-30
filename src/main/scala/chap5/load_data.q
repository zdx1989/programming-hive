-- 向管理表中装载数据，hive没有行级别的数据插入、更新和删除，可以通过数据装载的方式来操作，或者将数据文件写入到指定的目录中去

LOAD DATA LOCAL INPATH '/Users/zhoudunxiong/Code/programming-hive/src/main/scala'
INTO TABLE employees
PARTITION (country = 'US', state = 'CA');

-- 使用LOCAL关键字，表示是从本地文件系统拷贝到制定分布式文件系统目录， 没有local的话是从分布式文件系统的一个目录移动到
-- 另外一个目录

-- 使用overwrite关键字，之前目录中存在的文件会被删除掉，重新写入新的文件
-- 没有使用overwrite关键字，之前目录中存在的文件不会被删除，假如新的文件个老的文件名字重复，会将新的文件重命名
-- 注意这样会造成重复数据的现象

-- PARTITION 用来指明数据导入到表中的那个分区， 非分区表可以不用填写

-- 一些限制，INPATH假如表示的是一个目录，那么目录下应该全是文件夹，不能存在子文件夹
-- FAILED source contains directory:
-- hive不会校验文件夹中文件的模式是否和表模式一致（读时模式），但是会校验文件的格式是否和定义的格式一致
-- STORE AS TEXTFILE 只能使用文本格式的文件
--