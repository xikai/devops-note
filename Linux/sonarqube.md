* https://docs.sonarqube.org/latest/

>SonarQube 是一个开源的代码分析平台, 代码质量管理 用来持续分析和评测项目源代码的质量。 通过SonarQube我们可以检测出项目中重复代码， 潜在bug， 代码规范，安全性漏洞等问题， 并通过SonarQube web UI展示出来。

# [Requirements](https://docs.sonarqube.org/latest/requirements/requirements/)
```
sysctl -w vm.max_map_count=524288
sysctl -w fs.file-max=131072
ulimit -n 131072
ulimit -u 8192
```

* 如果运行用户为sonarqube， vim /etc/security/limits.d/99-sonarqube.conf
```
sonarqube   -   nofile   131072
sonarqube   -   nproc    8192
```


# [Install sonarqube server](https://docs.sonarqube.org/latest/setup/install-server/)
```yml
version: "3"

services:
  sonarqube:
    image: sonarqube:lts-community
    depends_on:
      - db
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://db:5432/sonar
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonar
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
    ports:
      - "9000:9000"
  db:
    image: postgres:12
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
    volumes:
      - postgresql:/var/lib/postgresql
      - postgresql_data:/var/lib/postgresql/data

volumes:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
  postgresql:
  postgresql_data:
```

* 访问web ui
```
http://localhost:9000
login: admin
password: admin
```

* [生成用户token](https://docs.sonarqube.org/latest/user-guide/user-token/)
```
user profile -> 安全 -> 生成token:
ed8aafabde57a4f9272a4e61d9d62fece9756387
```


# [Install Plugins](https://docs.sonarqube.org/latest/setup/install-plugin/)
* Administration > Marketplace
```
chinese     - 中文汉化插件
checkstyle  - 检查源文件编码规范
SonarJS
SonarTs
findbugs
Dependency-Check
pmd
```


# [SonarScanner for Maven](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-maven/)
> 推荐maven作为maven项目的默认扫瞄器; maven已经拥有SonarQube成功分析项目所需的大量信息,可以大大减少手动配置 
* Maven 3.x and Java
* vim $MAVEN_HOME/conf or ~/.m2 ，修改对应标签
```xml
<settings>
  <pluginGroups>
    <pluginGroup>org.sonarsource.scanner.maven</pluginGroup>
  </pluginGroups>

  <profiles>
    <profile>
      <id>sonar</id>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
      <properties>
        <!-- Optional URL to server. Default value is http://localhost:9000 -->
        <sonar.host.url>
          http://172.31.195.138:9000
        </sonar.host.url>
      </properties>
    </profile>
  </profiles>
</settings>
```

* Analyzing
```
mvn clean verify sonar:sonar -Dsonar.login=ed8aafabde57a4f9272a4e61d9d62fece9756387
```
```
# 如果要单独运行sonar分析，确保先执行mvn clean install
mvn clean install
mvn sonar:sonar -Dsonar.login=myAuthenticationToken
```


# [SonarScanner for Jenkins](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-jenkins/)
1. 安装SonarQube插件：
    - 插件管理 > SonarQube Scanner
2. 配置SonarQube servers: (sonarqube138)
    - Manage Jenkins > Configure System > SonarQube servers  
3. 配置SonarScanner: (sonarScanner4.7)
    - Manage Jenkins > Global Tool Configuration > SonarQube Scanner > Add SonarScanner(钩选“自动安装”)
4. Job Configuration:
    - Build > Execute SonarQube Scanner
    - or: 在项目根目录添加配置文件 [sonar-project.properties](https://docs.sonarqube.org/latest/analysis/analysis-parameters/) 
    - or: 命令行指定参数

5. Using a Jenkins pipelin
```groovy
withSonarQubeEnv('sonarqube138', envOnly: true) {
  // This expands the evironment variables SONAR_CONFIG_NAME, SONAR_HOST_URL, SONAR_AUTH_TOKEN that can be used by any script.
  println "${env.SONAR_HOST_URL}"
  println "${env.SONAR_AUTH_TOKEN}"
}
```

* Analyzing other project types
```groovy
pipeline {
    agent any
    environment {
        scannerHome = tool 'sonarScanner4.7';
    }
    
    stages {
        stage('SCM') {
            steps {
                git branch: "master", credentialsId: 'dfcdbee5-dacf-4182-94f0-73dc29df0030', url: 'https://github.com/foo/bar.git'
            }
        }

        stage('SonarQube analysis') {
            steps {
                withSonarQubeEnv('sonarqube138') {
                    sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=${JOB_NAME}"
                }
            }
        }
    }
}
```


# [SonarScanner](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/)
>sonar scanner cli, 是在构建系统没有特定扫描器时使用的扫描器

* 配置项目
  - 配置SonarQube server, conf/sonar-scanner.properties
  ```ini
    #----- Default SonarQube server
    #sonar.host.url=http://localhost:9000
  ```

  - 在项目根目录添加配置文件 [sonar-project.properties](https://docs.sonarqube.org/latest/analysis/analysis-parameters/) 
  ```ini
   # must be unique in a given SonarQube instance
   sonar.projectKey=my:project

   # --- optional properties ---

   # defaults to project key
   #sonar.projectName=My project
   # defaults to 'not provided'
   #sonar.projectVersion=1.0
   
   # Path is relative to the sonar-project.properties file. Defaults to .
   #sonar.sources=.
   
   # Encoding of the source code. Default is default system encoding
   #sonar.sourceEncoding=UTF-8
  ```
  - or: 命令行指定参数
  ```
  sonar-scanner -Dsonar.login=myAuthenticationToken -Dsonar.projectKey=myproject -Dsonar.sources=src1
  ```
* Running SonarScanner
```dockerfile
docker run \
    --rm \
    -e SONAR_HOST_URL="http://${SONARQUBE_URL}" \
    -e SONAR_SCANNER_OPTS="-Dsonar.projectKey=${YOUR_PROJECT_KEY}"
    -e SONAR_LOGIN="myAuthenticationToken" \
    -v "${YOUR_REPO}:/usr/src" \
    #-v ${YOUR_CACHE_DIR}:/opt/sonar-scanner/.sonar/cache \
    sonarsource/sonar-scanner-cli
```


# [webhook通知](https://docs.sonarqube.org/latest/project-administration/webhooks/)
* sonarqube -> 配置 -> 网络调用
```
名称	      URL
jenkins	  http://[jenkins_server_ip:port]/sonarqube-webhook/
```

```groovy
pipeline {
    agent any
    environment {
        scannerHome = tool 'sonarScanner4.7';
    }
    
    stages {
        stage('SCM') {
            steps {
                git branch: "master", credentialsId: 'dfcdbee5-dacf-4182-94f0-73dc29df0030', url: 'https://codeup.aliyun.com/60b6ff4db8301d20d58b7cd2/web/www-soa.git'
            }
        }

        stage('SonarQube analysis') {
            steps {
                withSonarQubeEnv('sonarqube138') {
                    sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=${JOB_NAME}"
                }
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        def qg = waitForQualityGate('sonarqube138')
                        if (qg.status != 'OK') {
                            error "未通过Sonarqube的代码质量阈检查，请及时修改！failure: ${qg.status}"
                        }
                    }
                }
            }
        }
    }
}
```