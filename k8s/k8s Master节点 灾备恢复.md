https://yq.aliyun.com/articles/561894

### etcd集群数据的备份和恢复
* etcd v2
```
#备份
etcdctl backup --data-dir /var/lib/etcd/ --backup-dir /data/etcd_backup

#恢复
etcdctl -data-dir=/var/lib/etcd_backup/  -force-new-cluster
```

* etcd v3
```
# 在使用 API 3 时需要使用环境变量 ETCDCTL_API 指定。
export ETCDCTL_API=3

#备份
etcdctl --endpoints localhost:2379 snapshot save snapshot.db

#恢复
etcdctl snapshot restore snapshot.db --name m3 --data-dir=/var/lib/etcd/
```