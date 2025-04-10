Role Name
=========
vevor APOLLO deployment

Requirements
------------

- first version deploy in Ubuntu system
- create a loadbalance for each environment and give a dns name
- keep each server can get connection from mysql database
- keep portal service can connect the port 8080 and 8090 of each environment
- correctly modify the database message
- packages from aliyun oss

sql:
  - portaldb: 
    - update ServerConfig set Value='FAT,UAT,PRO' where id=1;
    - update ServerConfig set Value='[{"orgId":"capital","orgName":"xxxx"}]' where id=2 # multi origins separate with comma
  - configdb: 
    - update ServerConfig set Value='http://10.41.11.31:8080/eureka/' where id=1; # multi addresses separate with comma

Role Variables
--------------

host vars example:

```yaml
[histore-apollo]
10.135.54.90 apollo_service=portal env=prod
10.135.67.184 apollo_service=portal env=prod
10.133.68.179 apollo_service=meta env=test
10.132.74.254 apollo_service=meta env=prod
10.132.51.34 apollo_service=meta  env=prod
```

configservice and adminservice are meta services , so I deploy them in the same server

defaule vars:

```yaml

defaule vars:

```yaml
---
# defaults file for ansible.apollo
## apollo package messages
apollo_adminservice_url: https://vevor-yunwei.oss-cn-shanghai.aliyuncs.com/packages/apollo/{{ apollo_adminservice }}-{{ apollo_version }}-github.zip
apollo_configservice_url: https://vevor-yunwei.oss-cn-shanghai.aliyuncs.com/packages/apollo/{{ apollo_configservice }}-{{ apollo_version }}-github.zip
apollo_portal_url: https://vevor-yunwei.oss-cn-shanghai.aliyuncs.com/packages/apollo/{{ apollo_portal }}-{{ apollo_version }}-github.zip

## apollo default messages
apollo_running_user: app
apollo_home: /data/services
apollo_log_directory: /opt/logs
apollo_version: 1.3.0
apollo_adminservice: apollo-adminservice
apollo_adminservice_port: 8090
apollo_configservice: apollo-configservice
apollo_configservice_port: 8080
apollo_portal: apollo-portal
apollo_portal_port: 8070

## apollo checking connection status
apollo_mysql_address: 'sql-xxxxxx.mysql.rds.aliyuncs.com'
apollo_mysql_user: 'app_axxxpollo_rw'
apollo_mysql_pass: 'xxxx'
apollo_mysql_proconfigdb: 'x'
apollo_mysql_fatconfigdb: 'x'
apollo_mysql_portaldb: 'x'

## portal env
apollo_env:
  - {env: 'pro',server: 'http://meta-xxx.xx.com:8080'}
  - {env: 'fat',server: 'http://meta-xxx.xx.com:8080'}
```

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: server
      roles:
         - vevor.apollo

License
-------

BSD

Author Information
------------------

created by wangxingmin
