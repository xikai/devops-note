# Groovy
* http://groovy-lang.org/syntax.html
* [Groovy 简明教程](https://www.qikqiak.com/post/groovy-simple-tutorial/)

# Jenkins共享库
* https://www.jenkins.io/zh/doc/book/pipeline/shared-libraries/
* https://blog.csdn.net/qq_34556414/article/details/117533966
* https://github.com/zeyangli/jenkinslib/tree/master
>如果你经常使用 Jenkins Pipeline 一定会遇到多个不同流水线中有大量重复代码的情况，很多时候为了方便我们都是直接复制粘贴到不同的管道中去的，但是长期下去这些代码的维护就会越来越麻烦。为了解决这个问题，Jenkins 中提供了共享库的概念来解决重复代码的问题，我们只需要将公共部分提取出来，然后就可以在所有的 Pipeline 中引用这些共享库下面的代码了。

# 目录结构
```
(root)
+- src                        # src目录用于存放共享库的其他Groovy源代码文件，如类、工具函数等
|   +- org
|       +- devops
|           +- tools.groovy   # for org.devops.tools class
+- vars                       # vars目录定义可从流水线访问的全局变量的脚本
|   +- sayHello.groovy 
+- resources                  # resource files (external libraries only)
|   +- org
|       +- devops
|           +- config.json    # static helper data for org.devops.tools
```
>使用vars目录和src目录的规范使您能够将可重用的函数和类进行适当的组织和分类。通常，将流水线脚本中直接使用的函数放在vars目录，而其他辅助函数和类放在src目录中。这样可以提高共享库的可读性和维护性，并方便在多个流水线中共享和重用代码。

# jenkins设置全局共享库
* Manage Jenkins » Configure System » Global Pipeline Libraries
```
Name #共享库的标识，在jenkinsfile中使用。
Default version #默认版本号，可以是分支名或tag标签。
Load implicitly #隐式加载，不再需要显式@Library('jenkins-penngo-library@main')的方式加载使用。
Allow default version to be overridden #如果勾选，允许被jenkinsfile配置的版本号覆盖。
Include @Library changes in job recent changes #如果勾选，则共享库的变更信息也会打印在构建信息中。
Cache fetched versions on controller for quick retrieval #如果选中此项，使用此库获取的版本将缓存在控制器上。
Retrieval method #配置公共库获取的方式，选择“Modern SCM”，选择使用Git仓库。也支持SVN仓库。
Library Path (optional) #允许您设置从SCM根目录到库目录的相对路径。针对根目录不是库目录的情况
```
* 动态的指定检索方法, 在这种情况下不需要在Jenkins库中预定义库
```groovy
library identifier: 'custom-lib@master', retriever: modernSCM(
  [$class: 'GitSCMSource',
   remote: 'git@git.mycorp.com:my-jenkins-utils.git',
   credentialsId: 'my-private-key'])
```

# Jenkinsfile使用共享库
* Loading libraries dynamically
```groovy
//对于只定义全局变量(vars/)的共享库，或者只需要全局变量的Jenkinsfile, _ 对于保持代码简洁可能很有用。
@Library('jenkins-shared-library') _
/* Using a version specifier, such as branch, tag, etc */
@Library('my-shared-library@master') _
/* Accessing multiple libraries with one statement */
@Library(['my-shared-library', 'otherlib@abc1234']) _
```

### 变量函数
1. vars目录是共享库的默认目录，用于存放可供流水线脚本直接调用的函数,
2. 在vars目录中，每个函数通常定义在单独的Groovy脚本文件中，并以函数名命名
3. vars目录中的函数可以直接在Jenkins流水线脚本中调用，无需额外导入或声明
* vars/sayHello.groovy
```groovy
// vars/sayHello.groovy
def call(String name = 'human') {
    // Any valid steps can be called from this code, just like in other
    // Scripted Pipeline
    echo "Hello, ${name}."
}
```

* 在Jenkinsfile中使用
```groovy
//对于只定义全局变量(vars/)的共享库，或者只需要全局变量的Jenkinsfile, _ 对于保持代码简洁可能很有用。
@Library('jenkins-shared-library') _

pipeline {
    agent none
    stages{
        stage ('Example') {
            steps {
                script {    //共享库使用的是Groovy代码，在Jenkinsfile中使用时，必须放在script指令里面。
                   sayHello 'xikai'  //输出：Hello, xikai.
                   sayHello()  /* invoke with default arguments 输出：Hello, human.*/
                }
            }
        }
    }
}
```

> 在一个变量函数文件中定义多个方法
* vars/log.groovy
```groovy
def info(message) {
    echo "INFO: ${message}"
}

def warning(message) {
    echo "WARNING: ${message}"
}
```
```groovy
Jenkinsfile
@Library('utils') _

pipeline {
    agent none
    stage ('Example') {
        steps {
             script { 
                 log.info 'Starting'
                 log.warning 'Nothing to do!'
             }
        }
    }
}
```

### 自定义的Groovy类、工具函数和其他可重用的代码
1. src目录中的类和函数可以被vars目录中的变量函数或流水线脚本中的其他代码调用
2. 要在流水线脚本中使用src目录中的函数或类，您需要使用@Library注释导入共享库并使用相应的导入语句
* src/devops/tools.groovy
```groovy
package org.devops
import groovy.json.JsonSlurper

def parseDubboPort(projectName){
    try{
        def response = httpRequest  "http://apollo.test.local:8081/configs/$projectName/test/application"
        def jsonStr =  response.getContent()
        def states = new JsonSlurper().parseText(jsonStr)
        def ips=states['configurations']['dubbo.protocol.port']
        return ips
    }catch(Exception e) {
        println e
    }
    return null;
}

def parseJvmPort(projectName){
    try{
        def response = httpRequest  "http://apollo.test.local:8081/configs/$projectName/test/ps.jmx-option"
        def jsonStr =  response.getContent()
        def states = new JsonSlurper().parseText(jsonStr)
        def ips=states['configurations']['jmx.port']
        return ips
    }catch(Exception e) {
        println e
    }
    return null;
}
```
* 在Jenkinsfile中使用
```groovy
// 加载名称为jenkins-shared-library的共享库的master分支
@Library('jenkins-shared-library@master') _

//导入共享库中的方法类
def Apollo = new org.devops.Apollo()

//定义Jenkins流水线
pipeline {
    agent any
    stages{
        stage ('Example') {
            steps {
                script {
                    def dubboPort = Apollo.parseDubboPort("myjobs")
                    def jvmPort = Apollo.parseJvmPort("myjobs")
                    println "DubboPort: ${dubboPort}"
                    println "JvmPort: ${jvmPort}" 
                }
            }
        }
    }
}
```

# 加载资源文件
>外部库可以使用`libraryResource` 步骤从 resources/ 目录加载附属的 文件。参数是相对路径名, 类似于Java资源加载:
```
#src/org/devops/tools.groovy
def config = libraryResource '../../../../resources/org/devops/config.json'   #该文件做为字符串被加载
```

# 在共享库里定义声明式流水线
>判断构建号是奇数还是偶数来执行不同流水线
* vars/evenOrOdd.groovy
```groovy
def call(int buildNumber) {
  if (buildNumber % 2 == 0) {
    pipeline {
      agent any
      stages {
        stage('Even Stage') {
          steps {
            echo "The build number is even"
          }
        }
      }
    }
  } else {
    pipeline {
      agent any
      stages {
        stage('Odd Stage') {
          steps {
            echo "The build number is odd"
          }
        }
      }
    }
  }
}
```
```groovy
// Jenkinsfile
@Library('my-shared-library') _

evenOrOdd(currentBuild.getNumber())
```