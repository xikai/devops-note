* 通过ResourceQuota对象定义对每个命名空间的资源配额，一个命名空间最多只能有一个ResourceQuota对象
  - 限制一个命名空间下对象的数量
  - 限制消耗计算资源，比如cpu和内存总量

* 开启资源配额，添加apiserver启动参数--enable-admission-plugins=ResourceQuota