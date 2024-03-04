#character set
mysql> CREATE DATABASE {database} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
mysql> ALTER DATABASE {database} CHARACTER SET utf8 COLLATE utf8_general_ci;

# user & grants ,修改 {user} 和 {password} 为你希望的用户名和密码
CREATE USER '{user}'@'%' IDENTIFIED BY '{password}';
GRANT ALL PRIVILEGES ON dolphinscheduler.* TO '{user}'@'%';
CREATE USER '{user}'@'localhost' IDENTIFIED BY '{password}';
GRANT ALL PRIVILEGES ON dolphinscheduler.* TO '{user}'@'localhost';
FLUSH PRIVILEGES;

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, INDEX, ALTER, CREATE VIEW, SHOW VIEW ON *.* TO '{user}'@'%';
GRANT SELECT ON *.* TO '{user}'@'%'; 

# revoke
show grants for '{user}'@'%';
revoke GRANT SELECT ON *.* FROM '{user}'@'%'; 
DROP USER '{user}'@'%';