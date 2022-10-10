resource "aws_iam_openid_connect_provider" "github_oidc_provider" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

##
# CI / CD Role
##

# resource "aws_iam_role" "cicd" {
#   name = "screensaver-cicd"

#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Effect = "Allow"
#       Principal = {
#         "Federated" : aws_iam_openid_connect_provider.github_oidc_provider.arn
#       }
#       Condition = {
#         "ForAnyValue:StringLike" = {
#           "token.actions.githubusercontent.com:sub" : [
#             "repo:bagel-dawg/screensaver:ref:refs/tags/*",
#             "repo:bagel-dawg/screensaver:ref:refs/heads/main",
#             "repo:bagel-dawg/screensaver:ref:refs/heads/release*"
#           ]
#         }
#       }
#     }]
#     Version = "2012-10-17"
#   })
# }

# resource "aws_iam_policy" "cicd" {
#   name = "screensaver-cicd"

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "ListObjectsInBucket",
#             "Effect": "Allow",
#             "Action": ["s3:ListBucket"],
#             "Resource": ["${aws_s3_bucket.bageltech_io.arn}"]
#         },
#         {
#             "Sid": "AllObjectActions",
#             "Effect": "Allow",
#             "Action": "s3:*Object",
#             "Resource": ["${aws_s3_bucket.bageltech_io.arn}/*"]
#         }
#     ]
# }
# EOF
# }


# resource "aws_iam_role_policy_attachment" "cicd" {
#   role       = aws_iam_role.cicd.name 
#   policy_arn = aws_iam_policy.cicd.arn
# }

##
# Terraform Role
##

resource "aws_iam_role" "terraform" {
  name_prefix = "screensaver-terraform"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        "Federated" : aws_iam_openid_connect_provider.github_oidc_provider.arn
      }
      Condition = {
        "ForAnyValue:StringLike" = {
          "token.actions.githubusercontent.com:sub" : [
            "repo:bagel-dawg/screensaver:ref:refs/tags/*",
            "repo:bagel-dawg/screensaver:ref:refs/heads/main",
            "repo:bagel-dawg/screensaver:ref:refs/heads/release*"
          ]
        }
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "terraform" {
  role       = aws_iam_role.terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}