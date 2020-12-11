# RANGE分区
>eg:创建一个如下表，该表保存有20家音像店的职员记录，这20家音像店的编号从1到20。如果你想将其分成5个小分区，分别保存店铺编号ID为(1-6，6-10，11-15，16-20，店铺编号ID大于20)的职员信息。
```
CREATE TABLE employees (
    id INT NOT NULL,
    fname VARCHAR(30),
    lname VARCHAR(30),
    hired DATE NOT NULL DEFAULT '1970-01-01',
    separated DATE NOT NULL DEFAULT '9999-12-31',
    job_code INT NOT NULL,
    store_id INT NOT NULL
)
PARTITION BY RANGE (store_id) (
    PARTITION p0 VALUES LESS THAN (6),
    PARTITION p1 VALUES LESS THAN (11),
    PARTITION p2 VALUES LESS THAN (16),
    PARTITION p3 VALUES LESS THAN (21),
    PARTITION p4 VALUES LESS THAN MAXVALUES
);
```


# LIST分区
>eg:假定有20个音像店，分布在4个有经销权的地区，如下表所示：
```
地区      商店ID 号
------------------------------
北区      3, 5, 6, 9, 17
东区      1, 2, 10, 11, 19, 20
西区      4, 12, 13, 14, 18
中心区    7, 8, 15, 16
```
```
CREATE TABLE employees(
 id INT NOT NULL,
 fname VARCHAR(30),
 lname VARCHAR(30),
 hired DATE NOT NULL DEFAULT '1970-1-1',
 separated DATA NOT NULL DEFAULT '9999-12-31',
 job_code INT,
 store_id INT
)
PARTITION BY LIST(store_id)(
 PARTITION pNorth VALUES IN(3,5,6,9,17),
 PARTITION pEast VALUES IN(1,2,10,11,19,20),
 PARTITION pWest VALUES IN(4,12,13,14,18),
 PARTITION pCentral VALUES IN(7,8,15,16)
);
```


# HASH分区
>eg:通过字段store_id的哈希值，轮流分配到4个分区中
```
CREATE TABLE employees (  
    id INT NOT NULL,  
    fname VARCHAR(30),  
    lname VARCHAR(30),  
    hired DATE NOT NULL DEFAULT '1970-01-01',  
    separated DATE NOT NULL DEFAULT '9999-12-31',  
    job_code INT,  
    store_id INT  
)  
PARTITION BY HASH(store_id)  
PARTITIONS 4；
```