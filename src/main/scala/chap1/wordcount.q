CREATE TABLE docs(line STRING);

LOAD DATA INPATH 'docs' OVERWRITE INTO TABLE docs;

CREATE TABLE word_counts AS
SELECT word, count(1) AS count FROM
    (SELECT explode(split(line, '\\s+')) AS word FROM docs) w
GROUP BY word
ORDER BY word;

## split(line, '\\s+') 根据空白符来切割字符串，返回一个字符串数据
## "zdx i like backetball" -> ["zdx","i","like","backetball"]

## explode(["zdx","i","like","backetball"]) 将传入一行字符串数数据据切割成多行，一个字符串一行
## ["zdx","i","like","backetball"] ->
## zdx
## i
## like
## backetball

## GROUP BY word 会根据word为key进行分组，word相同的分在一个组内
## count(1) 对GROUP BY 分组的元素个数进行统计