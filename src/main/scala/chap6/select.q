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
-- SET hive.map.aggr=true 设置该属性可以触发map阶段的预聚合，减少reduce时的数据量，提高性能，不过该设置会消耗更多的内存
-- SELECT count(*), avg(salary) FROM employees;

-- 常用表生成函数
-- 表生成函数和聚合函数相反，聚合函数将多行聚合成一行，表生成函数是将一行生成多行
-- explode(Array arr)返回0到多行的结果，每一行对应数组的一个元素
-- SELECT EXPLODE(subordinates) AS sub FROM employees;

-- 其他内置函数和时间处理有关的函数