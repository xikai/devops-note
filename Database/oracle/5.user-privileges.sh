数据字典：
1,对数据库及其内容的描述，用户定义、权限、完整性约事、性能监视信息都是数据字典的一部分
2,它在SYSTEM和SYSAUX表空间中以段的形式存储
3,数据字典在创建数据库时生成


查询数据字典（提供三种格式的视图）：
USER_  描述查询视图的用户自己拥有的对象，USER_TABLES看到和用户自己相关的表的信息
ALL_  描述查询视图的用户用户有权访问的对象，ALL_TABLES看到自己有权访问的表信息
DBA_ 描述数据库中所有的对象，DBA_TABLES看到数据库中所有表的信息，必须有DBA权限才可以查询该视图


常用的数据字典视图：
DBA_OBJECTS
DBA_DATA_FILE
DBA_USERS
DBA_TABLES



动态性能视图：
前缀v$，通过查询动态性能视图可以访问实例和数据库的大量信息

v$instance、v$sysstat在实例处于nomount模式时也可以使用
v$database、v$datafile在加载了数据库(open模式)才可以使用
DBA_、ALL_、USER_只有在打开数据库及数据字典后才可以使用