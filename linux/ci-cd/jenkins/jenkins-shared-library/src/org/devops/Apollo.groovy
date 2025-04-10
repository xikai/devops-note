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
