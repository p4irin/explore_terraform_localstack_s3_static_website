# Explore Terraform, AWS S3 static website on LocalStack

1. Manually setup an AWS S3 bucket on Localstack with awscli to host my static Jekyll resume locally.
1. Automate the above with Terraform

## Prerequisites

* [LocalStack](https://docs.localstack.cloud/getting-started/)
* [Terraform](https://developer.hashicorp.com/terraform/install)
* [AWS CLI](https://docs.localstack.cloud/user-guide/integrations/aws-cli/)
* [Jekyll](https://jekyllrb.com/docs/installation/ubuntu/)
* [Static webiste](https://github.com/p4irin/resume.git)

### My stack

* Ubuntu 22.04.03 LTS Jammy on WSL 2.0.14.0
* LocalStack CLI 4.1.0
* Terraform 1.10.5
* aws-cli 1.37.13
* Jekyll 4.4.1

## General steps

1. `$ localstack start`
1. Clone my Jekyll resume on GitHub
1. Create an S3 bucket
1. Attach a policy to the bucket
1. Sync/upload files
1. Enable static website hosting on the bucket
1. `$ localstack stop`

## Using AWS CLI

###

```bash
$ localstack start
```

### Clone my Jekyll resume on GitHub

```bash
$ localstack start
...
$ git clone https://github.com/p4irin/resume.git
$ cd resume
```

Generate static website

```bash
$ bundle exec jekyll build
```
This will generate a static website in a sub-directory `_site`.

### Create an S3 bucket

```bash
$ aws --profile localstack s3api create-bucket --bucket myresume
```
### Attach a policy to the bucket

Attach the bucket policy file `myresume_bucket_policy.json` to the bucket. Note the attribute "Resource" containing the bucket name in the path.

```json
"Resource": "arn:aws:s3:::myresume/*"
```

This policy allows public access to its content.
Attach the policy

```bash
$ aws --profile localstack s3api put-bucket-policy --bucket myresume --policy file://../myresume_bucket_policy.json
```

### Sync/upload files

```bash
$ aws --profile localstack s3 sync _site/ s3://myresume
```

### Enable static website hosting on the bucket

```bash
aws --profile localstack s3 website s3://myresume/ --index-document index.html
```

Check my resume on http://myresume.s3-website.localhost.localstack.cloud:4566/

###

```bash
$ localstack stop
```

## Terraform

Refer to the `*.tf` files.

### 

### Provider configuration

The aws provider is configured in `provider.tf`. Note that `s3.localhost.localstack.cloud:4566` is used for the s3 endpoint

```json
endpoints {
  s3 = "http://s3.localhost.localstack.cloud:4566"
}
```

This is recommended. S3 is a virtual hosted-style endpoint.

### Variables

Declare and set the `bucket_name` var to _myresume_ in `variables.tf` and `variables.tfvars`

### Outputs

Display some info we can use/for context after Terraform is done in `outputs.tf`. Like the URL for the website.

### Resources

Declare resources in `main.tf` in accordance to the general steps

1. Clone my Jekyll resume on GitHub
1. Create an S3 bucket
1. Attach a policy to the bucket
1. Sync/upload files
1. Enable static website hosting on the bucket

#### Clone Jekyll resume on Github and generate a static website

<!-- A `null_resource` type resource is used for this purpose.
The repo is cloned into a `resume/` directory and the static website is generated in `resume/_site` -->

Clone the repo before running `terraform` `init` `plan` and `apply`.
See below.

#### Create the bucket

#### Attach a policy

The policy resource references the bucket so the dependency of the policy on the bucket is implied. The bucket is created before the policy is attached to it.

#### Sync/upload files

Dependency on the bucket is explicit. It must be available in order to upload files. Everything below directory `_site` is uploaded.

#### Enable static website hosting on the bucket

Reference the bucket and set the index_document. We'll skipp setting the error_document.

#### Deploy the Jekyll resume

```bash
$ git clone https://github.com/p4irin/resume.git
...
$ cd resume
$ bundle exec jekyll build
...
$ cd ..
$ localstack start
...
$ terraform init
...
$ terraform plan
...
$ terraform apply
...
```

With the dependencies in place the resources should be created in the correct order. The Jekyll static website is now deployed to an S3 bucket on LocalStack. `terraform apply` shows the outputs.

```bash
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

arn = "arn:aws:s3:::myresume"
domain = "s3-website-us-east-1.amazonaws.com"
name = "myresume"
website_endpoint = "myresume.s3-website-us-east-1.amazonaws.com"
```

The domain and website_endpoint are specific to AWS and are not applicable when deploying to LocalStack.

To access the Jekyll generated static website on the LocalStack S3 bucket use http://myresume.s3-website.localhost.localstack.cloud:4566/.

#### Cleaning up

```bash
$ localstack stop
...
```

## References

* [LocalStack S3](https://docs.localstack.cloud/user-guide/aws/s3/)
* [AWS S3](https://docs.aws.amazon.com/s3/?icmpid=docs_homepage_featuredsvcs)
* [LocalStack](https://www.localstack.cloud/)
* [Terraform aws provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
* [Loacalstack awscli integration](https://docs.localstack.cloud/user-guide/integrations/aws-cli/)
* [Jekyll](https://jekyllrb.com/)