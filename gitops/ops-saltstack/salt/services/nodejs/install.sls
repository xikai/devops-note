nodejs_source:
  file.managed:
    - name: /usr/local/src/node-v6.11.4.tar.gz
    - source: salt://services/nodejs/files/node-v6.11.4.tar.gz
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - cwd: /usr/local/src
    - name: tar -xzf node-v6.11.4.tar.gz
    - unless: test -d /usr/local/src/node-v6.11.4
    - require:
      - file: nodejs_source

nodejs_compile:
  cmd.run:
    - cwd: /usr/local/src/node-v6.11.4 
    - name: ./configure --prefix=/usr/local/node && make && make install
    - requires:
      - cmd: nodejs_source
    - unless: test -d /usr/local/node

/etc/profile:
  file.append:
    - text:
      - export PATH=$PATH:/usr/local/node/bin

/data/shell:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/data/shell/mnode_start.sh:
  file.managed:
    - source: salt://services/nodejs/files/mnode_start.sh
    - user: root
    - group: root
    - mode: 755

npm_install:
  cmd.run:
    - name: source /etc/profile; /usr/local/node/bin/npm i babel-cli babel-core pm2 -g
    - require: 
      - cmd: nodejs_compile
