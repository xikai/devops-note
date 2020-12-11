#查看正在运行的job
salt '*' saltutil.running

#kill指定job           
salt '*' saltutil.kill_job jid      