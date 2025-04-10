# [organizations](https://bitwarden.com/help/getting-started-organizations/)
1. 创建组织（创建者默认为组织所有者，建议用一个公共邮箱帐号创建组织 避免人个离职后邮箱被删除）
2. 在组织中创建集合collections,可以在集合下创建子集合
3. 将用户添加到您的组织,邀请→接受→确认

### [collections](https://bitwarden.com/help/about-collections/)
  - 组织通过将用户或组分配到集合来控制对组织拥有的项目的访问
  - 组织拥有的项目必须包含在至少一个集合中
  - 构建可扩展集合的一些常用方法包括按部门收集（例如，将营销团队的用户分配到营销集合）或按功能收集（例如，将营销团队的用户分配到社交媒体集合）
  - 团队和企业组织还可以根据用户组而不是单个用户指定对集合的访问
  - 可以在collection嵌套子collection, 子集合name写法必须为“父集合/子集合”。嵌套集合仅用于显示目的，他们不会从其“父”集合继承项目、访问或权限

### [groups(在valutwarden处于BETA阶段)](https://bitwarden.com/help/about-groups/)
>unstable, setting an [environment variable](https://github.com/dani-garcia/vaultwarden/blob/main/.env.template#L98) is required in order to enable it
```
ORG_GROUPS_ENABLED=true
```

### [Folders](https://bitwarden.com/help/folders/)
  - 文件夹用于帮助用户归类items,以便于他们更容易找到特定的item
  - 文件夹是用户级别的功能，A用户创建的文件夹对其它用户是不可见的
  - 文件夹可以“嵌套”，以便在库中逻辑地组织它们

### [Member Roles and Permissions](https://bitwarden.com/help/user-types-access-control/)
……

### [policy](https://bitwarden.com/help/policies/)
  - 组织策略允许企业组织为所有用户实施安全规则，例如强制使用两步登录
  - 组织策略可以由组织管理员或所有者设置
  - 建议在邀请用户加入您的组织之前设置组织策略。有些策略在启用时会删除不合规的用户，有些则不可追溯执行
* 组织 > 设置 > 策略:
  - 禁用个人密码库: 通过禁用个人密码库选项，要求成员将项目保存到组织
  - 单一组织: 将限制您组织的非所有者/非管理员成员加入其他组织或创建其他组织

### [删除用户](https://bitwarden.com/help/onboarding-and-succession/#basic-offboarding)
- 可以继续使用任何 Bitwarden 应用程序来登录和访问个人保险库
- 将立即失去对与组织相关的任何内容（保险库、所有收藏和所有共享项目、包括自己创建的集合）的所有权限和访问权限

* 行政接管
  - 从您的组织中删除用户不会自动删除他们的 Bitwarden 帐户。使用主密码重置策略，组织中的所有者和管理员可以在下线期间重置用户的主密码。
  - 重置用户的主密码会将用户从所有活动的 Bitwarden 会话中注销，并将他们的登录凭据重置为管理员指定的凭据，这意味着管理员（并且只有该管理员）将拥有用户保险库数据的密钥，包括个人金库。组织通常使用这种金库接管策略，以确保员工不会保留对可能与工作相关的单个金库项目的访问权限，并可用于促进对员工可能使用的每个凭证的审计。