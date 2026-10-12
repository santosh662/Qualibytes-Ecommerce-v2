@Library('Shared') _

pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
        timestamps()
    }

    environment {
        DOCKER_IMAGE_NAME = 'mrsinghdev/qbshop-app'
        DOCKER_MIGRATION_IMAGE_NAME = 'mrsinghdev/qbshop-migration'
        DOCKER_IMAGE_TAG = "${BUILD_NUMBER}"
        GIT_BRANCH = 'dev'

        // Detect Jenkins-generated GitOps commits.
        SKIP_CI_PIPELINE = 'false'
    }

    stages {

        stage('Cleanup Workspace') {
            steps {
                script {
                    clean_ws()
                }
            }
        }

        stage('Clone Repository') {
            steps {
                script {
                    clone(
                        'https://github.com/santosh662/Qualibytes-Ecommerce-v2.git',
                        'dev'
                    )

                    def commitMessage = sh(
                        script: 'git log -1 --pretty=%s',
                        returnStdout: true
                    ).trim()

                    if (commitMessage.startsWith('ci: update image ')) {
                        env.SKIP_CI_PIPELINE = 'true'
                        currentBuild.description =
                            'Skipped: Jenkins-generated GitOps commit'

                        echo "GitOps commit detected: ${commitMessage}"
                        echo 'Skipping CI/CD stages to prevent a build loop.'
                    } else {
                        echo "Application change detected: ${commitMessage}"
                    }
                }
            }
        }

        stage('Cleanup Old Docker Images') {
            when {
                expression { env.SKIP_CI_PIPELINE != 'true' }
            }
            steps {
                script {
                    echo 'Cleaning up unused Docker resources...'

                    sh 'docker image prune -f'
                    sh 'docker image prune -a --force --filter "until=12h"'
                    sh 'docker container prune -f'

                    echo 'Docker cleanup completed.'
                }
            }
        }

        stage('Build Docker Images') {
            when {
                expression { env.SKIP_CI_PIPELINE != 'true' }
            }
            parallel {
                stage('Build Main App Image') {
                    steps {
                        script {
                            docker_build(
                                imageName: env.DOCKER_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                dockerfile: 'Dockerfile',
                                context: '.'
                            )
                        }
                    }
                }

                stage('Build Migration Image') {
                    steps {
                        script {
                            docker_build(
                                imageName: env.DOCKER_MIGRATION_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                dockerfile: 'scripts/Dockerfile.migration',
                                context: '.'
                            )
                        }
                    }
                }
            }
        }

        stage('Run Unit Tests') {
            when {
                expression { env.SKIP_CI_PIPELINE != 'true' }
            }
            steps {
                script {
                    run_tests()
                }
            }
        }

        stage('Security Scan with Trivy') {
            when {
                expression { env.SKIP_CI_PIPELINE != 'true' }
            }
            steps {
                script {
                    trivy_scan()
                }
            }
        }

        stage('Push Docker Images') {
            when {
                expression { env.SKIP_CI_PIPELINE != 'true' }
            }
            parallel {
                stage('Push Main App Image') {
                    steps {
                        script {
                            docker_push(
                                imageName: env.DOCKER_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                credentials: 'docker-hub-credentials'
                            )
                        }
                    }
                }

                stage('Push Migration Image') {
                    steps {
                        script {
                            docker_push(
                                imageName: env.DOCKER_MIGRATION_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                credentials: 'docker-hub-credentials'
                            )
                        }
                    }
                }
            }
        }

        stage('Update GitOps Repository') {
            when {
                expression { env.SKIP_CI_PIPELINE != 'true' }
            }
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'github-credentials',
                        usernameVariable: 'GIT_USERNAME',
                        passwordVariable: 'GIT_PASSWORD'
                    )
                ]) {
                    sh '''
                        set -eu
                        set +x

                        chmod +x automation/update-image-tag.sh
                        chmod +x automation/git-commit.sh

                        automation/update-image-tag.sh "$BUILD_NUMBER"
                        automation/git-commit.sh
                    '''
                }
            }
        }
    }

    post {
        always {
            emailext(
                to: 'patelsantosh441@gmail.com',
                subject: "${currentBuild.currentResult}: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                mimeType: 'text/html',
                body: """
                    <h2>QBShop CI/CD Pipeline Report</h2>
                    <p><b>Build Status:</b> ${currentBuild.currentResult}</p>
                    <p><b>Job:</b> ${env.JOB_NAME}</p>
                    <p><b>Build Number:</b> ${env.BUILD_NUMBER}</p>
                    <p><b>Git Branch:</b> ${env.GIT_BRANCH}</p>
                    <p><b>Build URL:</b>
                    <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                    <p>Check Jenkins console output for detailed logs.</p>
                """
            )
        }
    }
}

