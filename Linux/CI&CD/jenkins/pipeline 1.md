```
pipeline {
    agent none

    environment {
        PROJECT_NAME      = "per-api"
        HOST_PRODUCTION_1 = "47.112.28.116"
        HOST_PRODUCTION_2 = "47.106.75.85"
    }

    stages {
        stage('Test & build') {
            when {
                expression { BRANCH_NAME ==~ /(master|^release.*|development)/ }
            }
            agent { 
                docker {
                    image "reg.dadi01.cn/library/jenkins-php:7.2"
                    args "-v /root/.composer:/root/.composer -v /var/run/docker.sock:/var/run/docker.sock"
                } 
            }
            environment {
                HARBOR                = credentials('secret-harbor-registry-dadi01-cn')
                DD01BOT_ACCESS_TOKEN  = credentials('github-dd01bot-access-token')
            }
            steps {
                echo "Testing"
                sh "composer config --global --auth github-oauth.github.com $DD01BOT_ACCESS_TOKEN"
                sh "composer update"
                sh "docker login -u $HARBOR_USR -p $HARBOR_PSW reg.dadi01.cn"
                script {
                    if ("${env.BRANCH_NAME}" == "development") {
                        sh "docker build -t reg.dadi01.cn/test/$PROJECT_NAME:${env.GIT_COMMIT.take(7)} ."
                        sh "docker push reg.dadi01.cn/test/$PROJECT_NAME:${env.GIT_COMMIT.take(7)}"
                    }
                    if ("${env.BRANCH_NAME}" ==~ /^release.*/) {
                        sh "docker build -t reg.dadi01.cn/staging/$PROJECT_NAME:${env.GIT_COMMIT.take(7)} ."
                        sh "docker push reg.dadi01.cn/staging/$PROJECT_NAME:${env.GIT_COMMIT.take(7)}"
                    }
                    if ("${env.BRANCH_NAME}" == "master") {
                        dir('prod-config'){
                            git credentialsId: 'jenkins-ssh-key-for-prod', url: 'ssh://git@gitlab.dadi01.com:28/yejunyi/prod-config.git'
                        }
                        sh 'cp prod-config/prod-site-config/per-dadi01-com.stg .env && rm -rf prod-config'
                        withCredentials(bindings: [sshUserPrivateKey(credentialsId: 'jenkins-ssh-key-for-prod', \
                                                             keyFileVariable: 'SSH_KEY_FOR_PROD')]) {
                            sh """
                                chown -R www-data.www-data .
                                rsync -avzp --delete --partial --exclude='.git/' -e "ssh -i ${SSH_KEY_FOR_PROD} -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no" ./ root@$HOST_PRODUCTION_1:/srv/per-dadi01-net |grep -v /\$
                                rsync -avzp --delete --partial --exclude='.git/' -e "ssh -i ${SSH_KEY_FOR_PROD} -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no" ./ root@$HOST_PRODUCTION_2:/srv/per-dadi01-net |grep -v /\$
                            """
                        }   
                    }
                }
            }
        }

        stage('Deploy Test') {
            when {
                branch 'development'
            }
            agent { 
                docker {
                    image "reg.dadi01.cn/library/helm-kubectl:latest"
                    args "-v /root/.kube/config-test:/root/.kube/config"
                } 
            }
            steps {
                echo 'Deploying Test'
                sh """
                    helm init --client-only --skip-refresh
                    cd helm/chart
                    sed -i "s/PARAM-WWWROOT/$PROJECT_NAME/" values-test.yaml
                    sed -i "s/PARAM-TAGS/${env.GIT_COMMIT.take(7)}/" values-test.yaml
                    helm dep update .
                    export DEPLOYS=\$(helm ls |awk '{print \$1}' |grep "^qa-$PROJECT_NAME\$" |wc -l)
                    if [ \${DEPLOYS}  -eq 0 ]; then helm install --name="qa-$PROJECT_NAME" -f values-test.yaml . --namespace=kube-test; else helm upgrade -f values-test.yaml qa-$PROJECT_NAME . --namespace=kube-test; fi
                """
            }
        }

        stage('Deploy staging') {
            when {
                expression { BRANCH_NAME ==~ /^release.*/ }
            }
            agent { 
                docker {
                    image "reg.dadi01.cn/library/helm-kubectl:latest"
                    args "-v /root/.kube/config-test:/root/.kube/config"
                } 
            }
            steps {
                echo 'Deploying Staging'
                sh """
                    helm init --client-only --skip-refresh
                    cd helm/chart
                    sed -i "s/PARAM-WWWROOT/$PROJECT_NAME/" values-staging.yaml
                    sed -i "s/PARAM-TAGS/${env.GIT_COMMIT.take(7)}/" values-staging.yaml
                    helm dep update .
                    export DEPLOYS=\$(helm ls |awk '{print \$1}' |grep "^stg-$PROJECT_NAME\$" |wc -l)
                    if [ \${DEPLOYS}  -eq 0 ]; then helm install --name="stg-$PROJECT_NAME" -f values-staging.yaml . --namespace=kube-staging; else helm upgrade -f values-staging.yaml stg-$PROJECT_NAME . --namespace=kube-staging; fi
                """
            }
        }
    }
}

```