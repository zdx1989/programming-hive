-- 对于符合类型的列如何筛选字段
-- 对于数组类型可以使用下标来操作
SELECT subordinates[1] FROM employees WHERE country = 'US';

-- 对Map类型使用key来检索value值
SELECT deductions["state taxes"] FROM employees WHERE country = 'US';

-- 对于Struct类型使用属性名来检索属性值
SELECT address.city FROM employees WHERE country = 'US';


-- 可以使用正则表达式来指定列
SELECT symbol, `price.*` FROM stocks;

-- 并没有生效？

-- 可以使用列值进行计算，用户不仅可以选择表中的列，还可以使用函数调用和算术运算来操作列值

-- 常用函数分类
-- 常用数学函数
-- round(Double d) 返回d的BigInt的近似值, floor(Double d)返回<= d的最大BigInt值, ceil(Double d) 返回>=d 的最小的BigInt值

-- 常用聚合函数
-- count(*) 计算总行数，包含null的行；count(expr)计算expr表达式的值非null的行
-- sum(col) 计算指定行的和；avg(col) 计算指定行的平均值
SET hive.map.aggr=true 设置该属性可以触发map阶段的预聚合，减少reduce时的数据量，提高性能，不过该设置会消耗更多的内存
SELECT count(*), avg(salary) FROM employees;

-- 常用表生成函数
-- 表生成函数和聚合函数相反，聚合函数将多行聚合成一行，表生成函数是将一行生成多行
-- explode(Array arr)返回0到多行的结果，每一行对应数组的一个元素
SELECT EXPLODE(subordinates) AS sub FROM employees;

-- 其他内置函数和时间处理有关的函数

-- LIMIT语句
-- 列别名
-- 嵌套SELECT语句
-- CASE WHEN THEN语句和if else语句很想，用于处理单个列的查询结果

SELECT name, salary,
    CASE
        WHEN salary < 10000 THEN 'low'
        WHEN salary >= 10000 AND salary < 20000 THEN 'middle'
        WHEN salary >= 20000 THEN 'high'
    END AS bracket FROM employees;

-- 如何避免进行MapReduce
-- 大部分查询都会触发一个mapreduce的job，但是hive对于有些查询时不会触发mapreduce，也就是所谓的本地模式
SET hive.exec.model.local.auto=true
-- 设置该属性hive还是尝试使用本地模式执行其他的操作

-- WHERE语句
-- 不能在WHERE语句中使用别名, 不过可以使用嵌套查询来处理
SELECT name, salary,
    CASE
        WHEN salary < 10000 THEN 'low'
        WHEN salary >= 10000 AND salary < 20000 THEN 'middle'
        WHEN salary >= 20000 THEN 'high'
    END AS bracket FROM employees
WHERE bracket = 'high';
-- 上面的SQL语句不能通过，因为不能再WHERE语句使用别名，不过可以使用嵌套查询来替换
SELECT e.* FROM
    (SELECT name, salary,
        CASE
            WHEN salary < 10000 THEN 'low'
            WHEN salary >= 10000 AND salary < 20000 THEN 'middle'
            WHEN salary >= 20000 THEN 'high'
        END AS bracket FROM employees) AS e
WHERE bracket = 'high';


