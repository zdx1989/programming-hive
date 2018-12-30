-- INSERT 可以通过查询语句向表中插入数据

INSERT OVERWRITE TABLE employees2
PARTITION (country = 'US', state = 'CA')
SELECT se.name, se.salary, se.subordinates, se.deductions, se.address FROM employees se
WHERE se.country = 'US' AND se.state = 'CA';

-- 使用OVERWRITE意味着之前分区内的内容会被覆盖掉
-- 使用INTO的话，即为追加，不会覆盖之前分区目录中的内容，这样会造成重复数据

-- 还可以在扫描一次原表的情况下，向目标表的多个分区插入数据

FROM employees se
INSERT OVERWRITE TABLE employees2 PARTITION (country = 'US', state = 'CA')
    SELECT se.name, se.salary, se.subordinates, se.deductions, se.address
    WHERE se.country = 'US' AND se.state = 'CA'
INSERT OVERWRITE TABLE employees2 PARTITION (country = 'CN', state = 'HN')
    SELECT se.name, se.salary, se.subordinates, se.deductions, se.address
    WHERE se.country = 'CN' AND se.state = 'HN';

-- 这里可以混合使用OVERWRITE和INTO

-- hive提供了动态分区的功能，可以基于查询参数推断出需要创建的分区名称
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nostrict;

INSERT OVERWRITE TABLE employees2
PARTITION (country, state)
SELECT * FROM employees;

-- hive默认是没有开启动态分区功能的，需要设置hive.exec.dynamic.partition = true才能开启动态分区功能
-- hive默认分区模式是严格的， 也就说只要有一个分区是静态的，假如想都是动态的，需要设置
-- hive.exec.dynamic.partition.mode = nostrict
-- hive动态分区设置不当的话可能会产生大量的分区和小文件，所以hive有配置对分区数和文件数进行限制

-- 可以将hive表中的数据导出到本地的目录，可以使用Hadoop fs -copyToLocal sourcePath targetPath
-- 可恶意使用INSERT OVERWRITE LOCAL DIRECTORY

INSERT OVERWRITE LOCAL DIRECTORY '/Users/zhoudunxiong/employees'
SELECT name, salary
FROM employees;
