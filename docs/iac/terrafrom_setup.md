# Terrafrom 新 入門
最近のTerrafromは"moduele"という概念が出てきた
今までのやり方でもデプロイはできるが最近のやり方に合わせて再度学習し直す

## 参考にしているページ
- https://dev.classmethod.jp/articles/terraform-deploy-module/
- https://dev.classmethod.jp/articles/re-introducation-2022-aws-terraform-registry-module/

## 直近の目標として
- 今まで通りVPC作成からインスタンス立ち上げまでをできるようにする


## なんかメモ
- Internet Gateway はデフォルトで作成されているみたい
- この話かな?
```
create_egress_only_igw bool
Description: Controls if an Egress Only Internet Gateway is created and its related routes.
Default: true
```

## 概念的な話
- 作成した名前とかがタグ情報に入るので良さそう

https://ap-northeast-1.console.aws.amazon.com/console/home?region=ap-northeast-1#




---
## モジュールの使い方
まずは公式のモジュールを使って準備してみる
-  [vpc]module
https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

-  [security-group]module
https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest

-  [ec2-instance]module
https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest

---

### vpc、subnet、InternetGateway
EC2を立ち上げて外部と通信できるようにするところまで
-  事前準備として
- キー登録は面倒なので先に登録しておく

#### [provider.tf]
おまじない（笑）
```
% cat provider.tf 
provider "aws" {
  region  = "ap-northeast-1"
}
```

#### [vpc.tf]
VPCの基本的な設定
- VPC
- Subnet
- InternetGatewayは明示的に指定しなくても作例されるみたい
```
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  # VPC
  name = "dev"
  cidr                 = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  # subnet
  azs             = ["ap-northeast-1a", "ap-northeast-1c"]
  public_subnets  = ["10.0.11.0/24", "10.0.12.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
    Domain = "soma-test"
  }
}
```
#### [sg.tf]
接続元制限
```
module "devsg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "devaccess"
  description = "sg-dev"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["10.0.0.0/16","113.37.234.22/32"]
  ingress_rules            = ["https-443-tcp","ssh-tcp"]  

  tags = {
    Name = "dev-sg"
    Terraform   = "true"
    Environment = "dev"
  }
}
```
#### [ec2.tf]
- これがEC2を立ち上げるやつ
- "for_each~ "行で２台立ち上げるようになっている
- ディスクサイズはデフォルトで８GBなので20GBで起動するようにしている
```
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(["01", "02"])
  name = "dev${each.key}"

  ami                    = "ami-05e7c17d8163170e7"
  instance_type          = "t2.micro"
  key_name               = "soma-test"
  monitoring             = true
  vpc_security_group_ids = [module.devsg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  root_block_device = [
    {
      volume_size           = 20
      volume_type           = "gp2"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Domain      = "dev-soma"
  }
}
```
TerraformをAWS CloudShellで使う
### AWSコンソールにログインし、画面上部にあるCloudShellアイコンをクリック
- あらかじめcloudshellの権限が必要
- 一旦は[AWSCloudShellFullAccess]を割り当ててしまっていいかも
- 権限の詳細は以下参照
    - https://docs.aws.amazon.com/ja_jp/cloudshell/latest/userguide/sec-auth-with-identities.html

### cloudshellが立ち上がったら以下を実行する
```
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
sudo mkdir /home/app
sudo mv /bin/terraform /home/app/
export PATH="$PATH:/home/app/"
```
- コマンドが実行できるか確認
```
$ terraform --version
Terraform v1.1.8
on linux_amd64
```
### aws code commitからコードを持ってくる

```
$ git clone https://git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/c-shell
Cloning into 'c-shell'...
Username for 'https://git-codecommit.ap-northeast-1.amazonaws.com': <iamユーザに設定してあるgit ユーザ名>
Password for 'https://y_soma-at-634650387945@git-codecommit.ap-northeast-1.amazonaws.com': <iamユーザに設定してあるgit ユーザのパスワード>
```
- これは初期のおまじない
```
  git config --global user.email "soma.yoichi@gmail.com"
  git config --global user.name "y_soma"
```

### 前準備
terraform.stateファイルを格納する場所を作成
```
aws s3 mb s3://soma-dev-tfstate
```

Terrafromのキャッシュログ(?)をs3に保存する設定
```
terraform {
  backend "s3" {
    bucket  = "soma-dev-tfstate"
    key     = "dev-cshell/terraform"
    region  = "ap-northeast-1"
    encrypt = true
  }
}




---

resource "aws_s3_bucket_policy" "zzk-hon-allow-vpce" {
  bucket = aws_s3_bucket.dev-zzk-lp.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["123456789012"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.example.arn,
      "${aws_s3_bucket.dev-zzk-lp.arn}/*",
    ]
  }
}
### allow VPC ENDPOINT

### deny all
data "aws_iam_policy_document" "policy_deny_all" {
  statement {
    sid    = "OverridePlaceHolderOne"
    effect = "Deny"

    actions   = [
        "s3:*"
    ]
    resources = [
      aws_s3_bucket.dev-zzk-lp.arn,
      "${aws_s3_bucket.dev-zzk-lp.arn}/*",
    ]

    condition = [
        "StringNotEquals": {
          "aws:SourceVpce": [
            "${aws_vpc_endpoint.zzk_s3.id"
          ]
        }
    ]
}


#### VPCエンドポイントからのみS3操作を可能にするポリシー
```
{
  "Id": "VPCe",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VPCe",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": [
        "arn:aws:s3:::dev-zzzzk-lp",
        "arn:aws:s3:::dev-zzzzk-lp/*"
      ],
      "Condition": {
        "StringNotEquals": {
          "aws:SourceVpce": [
            "vpce-091481989b297d40a"
          ]
        }
      },
      "Principal": "*"
    }
  ]
}
```
これをTerrafromで適用するにはこんな感じ
```
    statement {
        sid = "VPCe"
        effect = "Deny"
        actions = [
            "s3:*"
        ]
        resources = [
            aws_s3_bucket.dev-zzk-lp.arn,
            "${aws_s3_bucket.dev-zzk-lp.arn}/*",
        ]
        condition {
            test = "StringNotEquals"
            variable = "aws:SourceVpce"
            values = [
              "${aws_vpc_endpoint.zzk_s3.id}"
            ]
        }
        principals {
            type = "*"
            identifiers = ["*"]
        }
    }
```


作成されたポリシー
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VPCe",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::dev-zzzzk-lp/*",
                "arn:aws:s3:::dev-zzzzk-lp"
            ],
            "Condition": {
                "StringNotEquals": {
                    "aws:SourceVpce": "vpce-091481989b297d40a"
                }
            }
        }
    ]
}
```
