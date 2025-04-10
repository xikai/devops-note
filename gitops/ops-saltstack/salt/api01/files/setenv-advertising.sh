#add tomcat pid
CATALINA_PID="$CATALINA_BASE/tomcat.pid"
#add java opts
CATALINA_OPTS="-Djava.library.path=/usr/local/tomcat-native/lib"
{% if grains['env'] == 'test' %}
JAVA_OPTS="-server -Xms1024M -Xmx1024M -Dspring.profiles.active=test"
{% elif grains['env'] == 'uat' %}
JAVA_OPTS="-server -Xms1024M -Xmx1024M -Dspring.profiles.active=uat"
{% elif grains['env'] == 'prod' %}
JAVA_OPTS="-server -Xms4096M -Xmx4096M -Dspring.profiles.active=prod"
{% endif %}