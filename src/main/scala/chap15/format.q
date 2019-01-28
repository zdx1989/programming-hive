--文本格式和sequencefile的区别
create table text (x int);
describe formatted text;

create table seq (x int) stored as sequencefile;
describe formatted seq;

-- 文件格式

