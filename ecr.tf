resource "aws_ecr_repository" "repo" {
  name = "${var.project}-${var.env}"
  tags = var.tags
}
resource "aws_ecr_lifecycle_policy" "repo" {
  repository = aws_ecr_repository.repo.name
  policy     = <<EOF
    {
        "rules": [
            {
                "rulePriority": 1,
                "description": "Keep last 60 images",
                "selection": {
                    "tagStatus": "tagged",
                    "tagPrefixList": ["build-"],
                    "countType": "imageCountMoreThan",
                    "countNumber": 60
                },
                "action": {
                    "type": "expire"
                }
            },
            {
              "rulePriority": 2,
              "description": "Expire images older than 14 days",
              "selection": {
                  "tagStatus": "untagged",
                  "countType": "sinceImagePushed",
                  "countUnit": "days",
                  "countNumber": 14
              },
              "action": {
                  "type": "expire"
              }
            }
        ]
    }
    EOF
}