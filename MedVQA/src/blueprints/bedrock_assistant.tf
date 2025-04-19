# src/blueprints/bedrock_assistant.tf

resource "aws_iam_role" "bedrock_role" {
  name = "bedrock-invoke-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "sagemaker.amazonaws.com"  # Or lambda.amazonaws.com, etc.
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "bedrock_invoke_policy" {
  name        = "InvokeBedrockModel"
  description = "Policy to allow invoking Bedrock models"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "bedrock:InvokeModel"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.bedrock_role.name
  policy_arn = aws_iam_policy.bedrock_invoke_policy.arn
}
