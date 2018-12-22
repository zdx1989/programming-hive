CREATE TABLE employees (
    name         STRING,
    salary       FLOAT,
    subordinates ARRAY<STRING>,
    deductions   MAP<STRING, FLOAT>,
    address      STRUCT<street: STRING, city: STRING, state: STRING, zip: INT>
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\001'
COLLECTION ITEMS TERMINATED BY '\002'
MAP KEYS TERMINATED BY '\003'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

--FIELDS TERMINATED BY '\001': 表示的是字段间也就是列之间的分割符号，例如zdx^A29^AMan 表示三列，每列以^A分开

--COLLECTION ITEMS TERMINATED BY '\002': 表示Array和Struct的元素之间和Map的键值对之间的分割符号，
--例如：zdx^Bygy^Bzq 表示一列，这一列可能定义为Array<STRING>, 也可能定义为STRUCT<first: STRING, second: STRING, third: STRING>
--例如：name^Czdx^Bage^C29^Bsex^Cman 表示一列，这一列定义为MAP<STRING, STRING> 分别为键值对: name->zdx; age->29; sex->man

-- MAP KEY TERMINATED BY '\003': 表示的是Map键值对之间的分割符，键和值之间用^C分开，例如：name^Czdx

--LINE TERMINATED BY '\n' 表示行和行之间通过'\n'来实现分割
--STORE AS TEXTFILE 表示数据文件的格式

--hive 的数据类型分为基本数据类型和集合数据类型
--基本数据类型包含：(tinyInt, byte), (smallInt, short), (int, int), (bigInt, long), (float, float), (double, double)
--(boolean, boolean), (string, string), (timestamp, timestamp), (binary, Array<Byte>)

--集合数据类型包含：（struct, Struct<name: String, age: Int>); (Array, Array<String>); (Map, Map<String, Int>)

