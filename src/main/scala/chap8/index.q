-- hive中维护索引需要额外的存储空间，创建索引也需要消耗计算资源，用户需要在建立索引带来的好处和需要付出的代价之间做出平衡
-- 如何建立索引

CREATE TABLE employees (
    name STRING,
    salary FLOAT,
    subordinates ARRAY<STRING>,
    deduction Map<STRING, FLOAT>,
    address STRUCT<street: STRING, city: STRING, state: STRING, zip: INT>
)
PARTITIONED BY (country: STRING, state: STRING);

CREATE INDEX employees index
ON TABLE employees (country)
AS 'org.apache.hadoop.hive.ql.index.compact.CompactIndexHandler'
WITH DEFERRED REBUILD
idxproperties('createor' = 'me', 'created_at' = 'some_time')
IN TABLE employees_index_table
PARTITIONED by (country, name);