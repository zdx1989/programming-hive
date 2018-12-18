## hive 有几个基础服务
## CLI hive的命令行界面
## HWI hive的网页页面
## metastoreservice 存储hive表的元数据信息， 默认为Derby，一般配置成MySQL或PostgrelSQL
## Thrift 提供使用jdbc和odbc访问hive的功能， 也提供访问其它进程的功能

## hive表默认会放在hive的仓库中，hive仓库的默认路径为/user/hive/warehouse
## 对于本地文件系统：file:///user/hive/warehouse
## 对于HDFS：hdfs://namenode/user/hive/warehouse
## 使用的文件系统由Hadoop中core-site.xml中fs.default.name来决定

