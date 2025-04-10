#!/usr/bin/env groovy

def call(String gitUrl, String type = 'branches', String credentialsId) {
    if (!['branches', 'tags'].contains(type)) {
        error "Invalid type: ${type}. Supported types are 'branches' or 'tags'."
    }
    def branchesOrTagsList = []
    def gitCommand = ''

    if (type == 'branches') {
        gitCommand = "git ls-remote --heads ${gitUrl}"
    } else if (type == 'tags') {
        gitCommand = "git ls-remote --tages ${gitUrl}"
    }

    def output = sh(script: gitCommand, returnStdout: true).trim()

    output.split('\n').each { line -> 
        def parts = line.split('\t')
        if (parts.length > 1) {
            def ref = parts[1]
            if (type == 'branches') {
                branchesOrTagsList << ref.replaceAll('refs/heads/', '')
            } else if (type == 'tags') {
                branchesOrTagsList << ref.replaceAll('refs/tags/', '')
            }
        }
    }

    return branchesOrTagsList

}
