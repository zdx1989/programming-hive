-- 确定安装编解码器
set io.compression.codecs;

-- 选择一种压缩编解码
-- 使用压缩的优势是可以减少磁盘的存储空间，减少磁盘的和网络IO操作，但是压缩和解压的过程都会增长CPU的开销。
-- 但是hive处理的job大多数情况下都是IO密集型的， 不是CPU密集型的
-- 为什么需要这么多种压缩算法，因为不同的压缩算法都会在压缩速率和压缩效率之间进行权衡
-- LZO和snappy相比于GZIP和BZip2压缩比要小，但是压缩和解压缩的速度会更快些
-- 另外需要考虑的因素是压缩的文件格式是否是可以分割的
-- 块级别的压缩
-- 对于文本格式，文件是通过\n(换行符)作为默认的行分隔符, 将文件划分，并将划分转化记录
-- 用户没有使用文本格式时，需要指出InputFormat和OutPutFormat
-- hive需要SerDe(序列化和反序列化)将记录分解成列（字段）或者把字符组合成记录

-- 开启中间压缩
set hive.exec.compress.intermidiate = true
-- 中间压缩可以选着一个合适的编解码器
set mapred.map.output.compression.codec = snappy

-- 开启最终输出结果压缩
set hive.exec.compress.output = true
-- 对于输出压缩可以使用gzip（压缩空间最多）， 注意gzip是不可以分割的

-- sequenceFile