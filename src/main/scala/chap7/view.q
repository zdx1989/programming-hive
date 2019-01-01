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

CREATE VIEW as
SELECT firstname, lastname FROM userinfo;

--