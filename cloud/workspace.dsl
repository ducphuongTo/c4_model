workspace {

    model {
        user = person "Developer"

        sourceRepo = softwareSystem "Source Code Repository" {
            webhook = container "Webhook"
        }

        aws = softwareSystem "AWS Services" {
            codePipeline = container "CodePipeline"
            codeBuild = container "CodeBuild"
            ecr = container "Amazon ECR"
            eks = container "Amazon EKS"
        }

        user -> sourceRepo "Commits and pushes changes to"
        webhook -> codePipeline "Triggers"
        codePipeline -> sourceRepo "Downloads source code"
        codePipeline -> codeBuild "Starts build process"
        codeBuild -> sourceRepo "Downloads necessary source packages"
        codeBuild -> codeBuild "Builds and tags a local Docker image"
        codeBuild -> ecr "Pushes the container image with a unique label"
        codePipeline -> eks "Deploys image"
    }

    views {
        container aws {
            include *
            autolayout lr
        }

        dynamic aws "Dynamic-001-WF" "CI/CD Workflow using AWS Services" {
            user -> sourceRepo "Commits and pushes changes"
            sourceRepo -> codePipeline "Triggers CodePipeline to build"
            codePipeline -> sourceRepo "Downloads source code"
            codePipeline -> codeBuild "Starts build process"
            codeBuild -> sourceRepo "Downloads necessary source packages"
            codeBuild -> codeBuild "Builds and tags Docker image"
            codeBuild -> ecr "Pushes image to Amazon ECR"
            codePipeline -> eks "Deploys image on Amazon EKS"
            autolayout lr
        }


        styles {
            element "Dynamic Element" {
                background #ffffff
            }
        }
    }
}
