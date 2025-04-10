zabbix_agent:
  cmd.run:
    - name: rpm -ivh http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
    - unless: rpm -qa|grep zabbix-release-3.0-1
  pkg.installed:
    - name: zabbix-agent
    - require:
      - cmd: zabbix_agent

zabbix_conf:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.conf
    - source: salt://base/files/zabbix_agentd.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        hostname: {{ grains['fqdn'] }}

/data/logs/zabbix:
  file.directory:
    - user: zabbix
    - group: zabbix
    - mode: 755
    - makedirs: True 
 
zabbix_service:
  service.running:
    - name: zabbix-agent
    - enable: True
    - watch:
      - file: /etc/zabbix/zabbix_agentd.conf

/etc/zabbix/script:
  file.directory:
    - user: zabbix
    - group: zabbix
    - mode: 755
    - makedirs: True 

get_all_port.conf:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.d/get_all_port.conf
    - source: salt://base/files/get_all_port.conf
    - template: jinja
    - watch_in:
      - service: zabbix_service

get_all_port.py:
  file.managed:
    - name: /etc/zabbix/script/get_all_port.py
    - source: salt://base/files/get_all_port.py
    - mode: 777
  cmd.run:
    - name: chmod +s /bin/netstat
