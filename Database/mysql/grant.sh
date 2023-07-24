#character set
CREATE DATABASE `wordpress` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER DATABASE 数据库名 CHARACTER SET utf8 COLLATE utf8_bin;

# user & grants
CREATE USER `dadi01`@`172.19.%.%` IDENTIFIED BY 'xxxxxxx';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, INDEX, ALTER, CREATE VIEW, SHOW VIEW ON *.* TO 'dadi01'@'172.19.%.%' IDENTIFIED BY 'xxxxxxxx';
GRANT SELECT ON *.* TO 'dadi_read'@'%' IDENTIFIED BY 'xxxxxx'; 

DROP USER 'dadi01'@'172.19.%.%';

show grants for 'dadi01'@'172.19.%.%';