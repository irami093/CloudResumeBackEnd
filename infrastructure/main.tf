resource "aws_lambda_function" "myfunction" {
  filename         = data.archive_file.zip_python_code.output_path
  source_code_hash = data.archive_file.zip_python_code.output_base64sha256
  function_name    = "myfunction"
  role             = aws_iam_role.iam_forlambda.arn
  handler          = "function.lambda_handler"
  runtime          = "python3.10"
}

# IAM role for Lambda function execution

resource "aws_iam_role" "iam_forlambda" {
  name = "iam_forlambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

#AWS IAM policy for DynamoDB access

resource "aws_iam_policy" "iam_policy_resume_challenge" {
  name        = "aws_iam_policy_terraform_resumeproject_policy"
  description = "AWS IAM policy for DynamoDB access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:*:*:*",
          "Effect" : "Allow"
      },
      {
        Effect = "Allow",
        Action : [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ],
        Resource = "arn:aws:dynamodb:*:*:table/latechanista_counter"
      }
    ],
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_role" {
  role       = aws_iam_role.iam_forlambda.name
  policy_arn = aws_iam_policy.iam_policy_resume_challenge.arn
}

//Need to troubleshoot this section
data "archive_file" "zip_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda/counterfunc.zip"
}

resource "aws_lambda_function_url" "url1" {
  function_name      = aws_lambda_function.myfunction.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}