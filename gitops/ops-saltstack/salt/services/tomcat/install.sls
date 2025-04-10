jdk_pkg:
  file.managed:
    - name: /usr/local/src/jdk-8u121-linux-x64.rpm
    - source: salt://services/tomcat/files/jdk-8u121-linux-x64.rpm
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - cwd: /usr/local/src
    - name: rpm -ivh jdk-8u121-linux-x64.rpm
    - unless: java -version

tomcat_source:
  file.managed:
    - name: /usr/local/src/apache-tomcat-8.0.26.tar.gz
    - source: salt://services/tomcat/files/apache-tomcat-8.0.26.tar.gz
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - cwd: /usr/local/src
    - name: tar -xzf apache-tomcat-8.0.26.tar.gz && rm -rf /usr/local/src/apache-tomcat-8.0.26/webapps/* && rm -rf /usr/local/src/apache-tomcat-8.0.26/logs
    - unless: test -d /usr/local/src/apache-tomcat-8.0.26
    - require:
      - file: tomcat_source

/data/shell:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/data/shell/project_update.sh:
  file.managed:
    - source: salt://services/tomcat/files/project_update.sh
    - user: root
    - group: root
    - mode: 755

apr_source:
  file.managed:
    - name: /usr/local/src/apr-1.5.2.tar.gz
    - source: salt://services/tomcat/files/apr-1.5.2.tar.gz
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - cwd: /usr/local/src
    - name: tar -xzf apr-1.5.2.tar.gz
    - unless: test -d /usr/local/src/apr-1.5.2
    - require:
      - file: apr_source

apr_compile:
  cmd.run:
    - cwd: /usr/local/src/apr-1.5.2
    - name: ./configure --prefix=/usr/local/apr && make && make install
    - requires:
      - cmd: apr_source
    - unless: test -d /usr/local/apr

apr_util_source:
  file.managed:
    - name: /usr/local/src/apr-util-1.5.4.tar.gz
    - source: salt://services/tomcat/files/apr-util-1.5.4.tar.gz
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - cwd: /usr/local/src
    - name: tar -xzf apr-util-1.5.4.tar.gz
    - unless: test -d /usr/local/src/apr-util-1.5.4
    - require:
      - file: apr_util_source

apr_util_compile:
  cmd.run:
    - cwd: /usr/local/src/apr-util-1.5.4
    - name: ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr && make && make install
    - requires:
      - cmd: apr_util_source
    - unless: test -d /usr/local/apr-util

tomcat_native_source:
  file.managed:
    - name: /usr/local/src/tomcat-native.tar.gz
    - source: salt://services/tomcat/files/tomcat-native.tar.gz
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - cwd: /usr/local/src
    - name: tar -xzf tomcat-native.tar.gz
    - unless: test -d /usr/local/src/tomcat-native-1.1.33-src
    - require:
      - file: tomcat_native_source

tomcat_native_compile:
  cmd.run:
    - cwd: /usr/local/src/tomcat-native-1.1.33-src/jni/native
    - name: ./configure --prefix=/usr/local/tomcat-native --with-apr=/usr/local/apr/bin/apr-1-config --with-java-home=/usr/java/jdk1.8.0_121 && make && make install
    - requires:
      - cmd: apr_util_source
    - unless: test -d /usr/local/tomcat-native
