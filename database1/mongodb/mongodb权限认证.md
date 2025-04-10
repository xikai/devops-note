# [用户](https://docs.mongodb.com/manual/reference/method/js-user-management/)
* 创建管理员帐号
```
use admin
db.createUser(
  {
    user: "root",
    pwd: "abc123",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" }, "readWriteAnyDatabase" ]
  }
)
```

* 认证连接
```
/usr/local/mongodb/bin/mongo -uroot -pabc123 --authenticationDatabase "admin"
```
* 连接后认证
```
use admin
db.auth("root", "abc123" )
```

* 查询用户
```
获取当前db所有用户
db.getUsers()
获取当前db指定用户
db.getUser("test")
```

* 创建其它用户
```
use test
db.createUser(
  {
    user: "myTester",
    pwd: "xyz123",
    roles: [ { role: "readWrite", db: "test" },
             { role: "read", db: "reporting" } ]
  }
)
```
* 修改用户权限Revoke、Grant
``` 
use reporting
db.grantRolesToUser(
    "reportsUser",
    [
      { role: "read", db: "accounts" }
    ]
)

use reporting
db.revokeRolesFromUser(
    "reportsUser",
    [
      { role: "readWrite", db: "accounts" }
    ]
)
```

* 查看用户角色的权限
```
use reporting
db.getUser("reportsUser")

use accounts
db.getRole( "readWriteRole", { showPrivileges: true } )
```

* 修改用户密码
```
db.changeUserPassword("reporting", "SOh3TbYhxuLiW8ypJPxmt1oOfL")
```

# [角色](https://docs.mongodb.com/manual/reference/method/js-role-management/)
* 创建角色
>创建可以修改自己的密码和数据的角色
```
use admin
db.createRole(
   { role: "changeOwnPasswordCustomDataRole",
     privileges: [
        {
          resource: { db: "", collection: ""},
          actions: [ "changeOwnPassword", "changeOwnCustomData" ]
        }
     ],
     roles: []
   }
)
```

* 查询用户定义的角色
```
查询用户定义的所有角色
db.getRoles()
查询用户定义的指定角色
db.getRole("changeOwnPasswordCustomDataRole")
```

* 创建用户应用自定义角色
```
use test
db.createUser(
   {
     user:"user123",
     pwd:"12345678",
     roles:[ "readWrite", { role:"changeOwnPasswordCustomDataRole", db:"admin" } ]
   }
)
```

* 普通用户修改密码
```
use test
db.updateUser(
   "user123",
   {
      pwd: "KNlZmiaNUp0B",
      customData: { title: "Senior Manager" }
   }
)
```

* 针对集合定义权限
```
privileges: [
  { resource: { db: "products", collection: "inventory" }, actions: [ "find", "update", "insert" ] },
  { resource: { db: "products", collection: "orders" },  actions: [ "find" ] }
]
```


