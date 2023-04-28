# IaC を使ってみる
- IaCの代表的なツールである[Terrafrom](https://www.terraform.io/)を用いてAWS環境を構築する

## なんでTeffafromなのか？
- 独自の言語（HCL(HashiCorp Configuration Language)）でコードを書いていくが、わかりやすい
- 例えばAWS CloudFormation はJson及びYAMLで記載することになるが分かりづらいのとAWS限定となるため他クラウドプラットフォームでの転用がしずらい
- 構文チェックやテスト、廃棄がしやすく、検証が行いやすい

---
## 事前準備
- ※ Cloud Shellの場合は一定時間するとホームディレクトリ以外が初期化されるので以下の手順を再実行しておくこと
- [この手順](https://github.com/YoichiSoma/sites/blob/main/docs/iac/terrafrom_setup.md#terraform-%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB-cli)

---
## 構築内容
- ec2を起動するまでのよくある構成
  - VPC周り(VPC、サブネット、IGW、ルートテーブル)
  - EC2周り(SG作成、EC2起動)
- コードのざっくりとした説明

### デモ
#### 実際に構築してみる
- コマンドメモ
```
terraform plan
terraform apply
terraform destory
```

### コード変更してみる
- インスタンスタイプを増やしてみるのとプライベートサブネットのインスタンスからｓ３に接続するためのエンドポイント作成
  - 予め用意したコードを利用
  ```
  mv instance2.tf{.org,}
  mv endpoint.tf{.org,}
  ```
  - 適用
  ```
  terraform plan
  terraform apply
  ```
- 接続確認 
  - LAB-SVに鍵のコピー
```
LABSVIP=`aws ec2 describe-instances \
--filters "Name=tag:Name,Values=LAB-SV" \
--query "Reservations[].Instances[].PublicIpAddress" \
--output text`
scp -i ~/lab-key.pem ~/lab-key.pem ec2-user@${LABSVIP}:/home/ec2-user

```
- LAB-SVに接続
```
ssh -i ~/lab-key.pem ec2-user@${LABSVIP}
```
- LAB-SVからLAB-SV2に接続
```
ssh -i ~/lab-key.pem ec2-user@172.30.21.101
```
- LAB-SV2からS３バケットにアクセス
```
aws s3 ls
```


