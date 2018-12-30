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