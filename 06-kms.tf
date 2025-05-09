//symmetric key required to encrypt s3, ebs, acm volumes and RDS 
//Asymmetric needed to encypt keys
//get current users identity
data "aws_caller_identity" "current" {}

//kms key to encrypt ebs 
resource "aws_kms_key" "kms_ebs" {
  description              = "Symmetric KMS key for EBS Encryption"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  key_usage                = "ENCRYPT_DECRYPT"
  enable_key_rotation      = true

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/EKS_finals"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/control-tower"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow all services originating from ec2 under the account to access this key"
        Effect = "Allow"
        Principal ={
        "AWS" = "*"
        },
      Action = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:CreateGrant",
        "kms:DescribeKey"
      ],
      Resource = "*",
       //this helps resolve the key not found issue, the key should be multi regional or you have to gives access to give access to region specific keys
      Condition =  {
        "StringEquals"= {
          "kms:CallerAccount" = "${data.aws_caller_identity.current.account_id}",
          "kms:ViaService" = "ec2.us-east-1.amazonaws.com"
        }
      }
    }
    ]
  })
}

resource "aws_kms_key" "kms_eks" {
  description              = "Symmetric KMS key for secrets Encryption"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  key_usage                = "ENCRYPT_DECRYPT"
  enable_key_rotation      = true

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/EKS_finals"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/control-tower"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      # {
      #   Sid    = "Enable IAM User Permissions"
      #   Effect = "Allow"
      #   Principal = {
      #     AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eks-cluster"
      #   },
      #   Action   = [
      #   "kms:Encrypt",
      #   "kms:Decrypt",
      #   "kms:ReEncrypt*",
      #   "kms:GenerateDataKey*",
      #   "kms:CreateGrant",
      #   "kms:DescribeKey"
      # ],
      #   Resource = "*"
      # },
      {
        Sid    = "Allow eks to use this key for encryption and decryption of secrets"
        Effect = "Allow"
        Principal ={
        "AWS" = "*"
        },
      Action = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:CreateGrant",
        "kms:DescribeKey"
      ],
      Resource = "*",
       //this helps resolve the key not found issue, the key should be multi regional or you have to gives access to give access to region specific keys
      Condition =  {
        "StringEquals"= {
          "kms:CallerAccount" = "${data.aws_caller_identity.current.account_id}",
          "kms:ViaService" = "eks.us-east-1.amazonaws.com"
        }
      }
    }
    ]
  })
}

//alias for keys

  resource "aws_kms_alias" "kms_ebs" {
    name_prefix = "alias/ebs-"
    target_key_id = aws_kms_key.kms_ebs.arn
  }

    resource "aws_kms_alias" "kms_eks" {
    name_prefix = "alias/eks-"
    target_key_id = aws_kms_key.kms_eks.arn
  }