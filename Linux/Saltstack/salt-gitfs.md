* master配置gitfs官方文档：
```
salt:
https://docs.saltstack.com/en/latest/topics/tutorials/gitfs.html
ext_pillar:
https://docs.saltstack.com/en/latest/ref/pillar/all/salt.pillar.git_pillar.html#git-pillar-2015-8-0-and-later
```
```
yum install GitPython
yum install python-pygit2
```
* vim /etc/salt/master
```
fileserver_backend:
  - git

gitfs_remotes:
  - git@192.168.221.58:sa/salt-tomtop.git
gitfs_root: salt

ext_pillar:
  - git: master git@192.168.221.58:sa/salt-tomtop.git root=pillar
```


* 清理gitfs缓存：
```
salt-run fileserver.clear_cache backend=git
```