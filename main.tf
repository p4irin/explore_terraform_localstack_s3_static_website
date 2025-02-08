# resource "null_resource" "static_jekyll_resume" {

#   provisioner "local-exec" {
#     command = <<EOT
#         if [ -d "resume" ]; then
#             echo 'Directory "resume" exists!\n'
#             echo 'Deleting "resume" directory.\n'
#             rm -rf "resume"
#         fi

#         echo 'Cloning https://github.com/p4irin/resume.git'
#         git clone https://github.com/p4irin/resume.git
#         cd resume
#         echo "The current directory is $(pwd)"
#         bundle exec jekyll build
#     EOT
#   } 

# }

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_policy" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = "${aws_s3_bucket.s3_bucket.arn}/*"
      },
    ]
  })
}

resource "aws_s3_object" "object_resume" {
  depends_on = [
        aws_s3_bucket.s3_bucket,
        # null_resource.static_jekyll_resume
    ]
  for_each   = fileset("${path.root}/resume/_site", "**/*")
  bucket     = var.bucket_name
  key        = each.value
  source     = "${path.root}/resume/_site/${each.value}"
  etag       = filemd5("${path.root}/resume/_site/${each.value}")
  content_type = lookup({
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "ico"  = "image/x-icon"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
  }, try(regex(".*\\.(.*)$", each.value)[0], ""), "application/octet-stream")
  acl        = "public-read"
}

resource "aws_s3_bucket_website_configuration" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  index_document {
    suffix = "index.html"
  }

#   error_document {
#     key = "error.html"
#   }

}

