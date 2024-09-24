

## setup
### terraform インストール (CLI)
- [インストール](sudo yum -y install terraform)
```
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
```
- パスを通す (cloud-shell限定)
```
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

### 初期セットアップ
- terraform.stateファイルを格納する場所を作成
```
aws s3 mb s3://<バケット名>
```
- 作業用フォルダ作成
  - 適当にフォルダを作成する
- [provider.tf]ファイルを作成
```
provider "aws" {
  region  = "ap-northeast-1"
}
```
Terrafromのキャッシュログ(?)をs3に保存する設定
```
terraform {
  backend "s3" {
    bucket  = "作成したバケット名"
    key     = "dev-cshell/terraform"
    region  = "ap-northeast-1"
    encrypt = true
  }
}

```
- 初期化
```
terraform init
```

## コード作成
- なにか適当にコードを作成

## 実際に適用してみる
- 構文チェック
```
terraform validate
```
- ファイルのインデント整形
```
terraform fmt
```
- テスト
```
terraform plan
```
- 実行
```
terrafrom apply
```
- 削除
```
terraform destroy
```


----
## AWS cloud shell で codecommitを使う
- clone時に"HTTPSのクローン(GRC)"のURLをコピーする
- git clone は通常通り
```
git clone codecommit::ap-northeast-1://<リポジトリ名>
```
