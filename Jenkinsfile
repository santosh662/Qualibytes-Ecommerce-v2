
@Library('Shared') _

pipeline {
    agent any

    environment {
        // Updated image names for QBShop project (DEV)
        DOCKER_IMAGE_NAME = 'mrsinghdev/qbshop-app'
        DOCKER_MIGRATION_IMAGE_NAME = 'mrsinghdev/qbshop-migration'
        DOCKER_IMAGE_TAG = "${BUILD_NUMBER}"
        GITHUB_CREDENTIALS = credentials('github-credentials')
        GIT_BRANCH = "dev"
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
                        "https://github.com/santosh662/Qualibytes-Ecommerce-v2.git",
                        "dev"
                    )
                }
            }
        }

        // Cleanup old Docker images to avoid disk full issues
        stage('Cleanup Old Docker Images') {
            steps {
                script {
                    echo "Cleaning up old Docker images, containers & volumes..."

                    // Remove dangling images
                    sh "docker image prune -f"

                    // Remove unused images older than 12 hours
                    sh 'docker image prune -a --force --filter "until=12h"'

                    // Remove stopped containers
                    sh "docker container prune -f"

                    echo "Cleanup completed successfully!"
                }
            }
        }

        stage('Build Docker Images') {
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
            steps {
                script {
                    run_tests()
                }
            }
        }

        stage('Security Scan with Trivy') {
            steps {
                script {
                    trivy_scan()
                }
            }
        }

        stage('Push Docker Images') {
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

