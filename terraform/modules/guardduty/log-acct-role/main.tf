resource "aws_iam_role" "GuardDutyTerraformLoggingAcctRole" {
  name = "GuardDutyTerraformOrgRole"

  # Set the Trusted principal to the Management account
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowAssumeRole"
        Principal = {
          "AWS" = "arn:aws:iam::${var.management_id}:root"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM definitions for GuardDutyTerraformOrgRole for the logging account
data "aws_iam_policy_document" "logging_acct_pol" {

  statement {
    sid    = "AllowS3"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      join("", ["arn:aws:s3:::", "log-gd-bucket1", "*"]),
      join("", ["arn:aws:s3:::", "log-gd-bucket1", "*/*"]),
      join("", ["arn:aws:s3:::", "s3-gdlogs2", "*"]),
      join("", ["arn:aws:s3:::", "s3-gdlogs2", "*/*"])
    ]
  }
  statement {
    sid    = "AllowKMS"
    effect = "Allow"
    actions = [
      "kms:ListGrants",
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:ListKeys",
      "kms:ListResourceTags",
      "kms:GetKeyRotationStatus",
      "kms:PutKeyPolicy",
      "kms:ScheduleKeyDeletion",
      "kms:GenerateDataKey",
      "kms:CreateKey",
      "kms:EnableKeyRotation",
      "kms:CreateAlias",
      "kms:ListAliases",
      "kms:DeleteAlias"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [var.logging_acc_id]
    }
  }
  statement {
    sid       = "AllowIamPerms"
    effect    = "Allow"
    actions   = ["iam:GetRole"]
    resources = ["arn:aws:iam::*:role/aws-service-role/*guardduty.amazonaws.com/*"]
  }
  statement {
    sid       = "AllowSvcLinkedRolePerms"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["arn:aws:iam::*:role/aws-service-role/*guardduty.amazonaws.com/*"]
    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["guardduty.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "gd_terraform_logging_acct_policy" {
  name   = "gd_terraform_logging_acct_Policy"
  policy = data.aws_iam_policy_document.logging_acct_pol.json
}

resource "aws_iam_role_policy_attachment" "attach_gd_terraform_logging_acct_policy" {
  role       = aws_iam_role.GuardDutyTerraformLoggingAcctRole.name
  policy_arn = aws_iam_policy.gd_terraform_logging_acct_policy.arn
}


