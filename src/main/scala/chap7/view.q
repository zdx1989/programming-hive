-- 视图可以保存一个查询并想表一样对这个查询进行操作，但是视图是一个逻辑结构，不会像表一样真正的存储数据，
-- 目前hive还不支持物化视图

-- 使用视图来降低查询复杂度
-- 可以使用视图对嵌套查询进行简化，例如：
SELECT a.lastname
FROM (
    SELECT * FROM people p JOIN cart c
    ON c.people_id = p.people_id
    WHERE p.firstname = 'john'
) a
WHERE a.id = 3;

-- 可以使用视图来替换
CREATE VIEW short_join AS
SELECT * FROM people p JOIN cart c
ON c.people_id = p.people_id
WHERE p.firstname = 'john';

SELECT lastname FROM short_join WHERE id = 3;

-- 是用视图来限制基于条件过滤的数据
-- 有时候一些涉及敏感数据的表，用户可以使用视图过滤掉敏感数据，对用户隐藏表，只暴露视图
CREATE TABLE userinfo (
    firstname STRING,
    lastname  STRING,
    ssh       STRING,
    passwors  STRING
);

CREATE VIEW safe_user_info as
SELECT firstname, lastname FROM userinfo;

-- 动态分区中的视图和map类型

-- 视图其他相关的事情
-- hive会优先解析视图，所以生成查询计划时，视图中的查询会先执行
-- DROP VIEW XXX 可以删除视图
-- SHOW TABLES 可以显示所有的表和视图
-- DESCRIBE EXTENDED XXX视图的时候tableType 显示的是VIRTUAL_VIEW
-- 视图不能作为INSERT语句和LOAD命令的目标表