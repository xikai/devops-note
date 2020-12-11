```
#!/bin/bash
projects=`cat tomcat_project.txt`
conf_file="/etc/logstash/conf.d/kafka-tomcat.conf"


echo "input {" > $conf_file
for i in $projects
do
cat >> $conf_file <<EOF
  kafka {
    bootstrap_servers => "172.31.37.224:9092"
    topics => ["tomcat_catalina_$i"]
    codec => "json"
    type => "tomcat_catalina_$i"
  }

EOF
done
echo -e "}\n\n" >> $conf_file

echo "output {" >> $conf_file
for i in $projects
do
cat >> $conf_file <<EOF
  if [type] == "tomcat_catalina_$i" {
    elasticsearch {
      hosts => ["172.31.40.180:9200"]
      index => "tomcat_catalina_$i"
    }
  } 

EOF
done
echo "}" >> $conf_file
```