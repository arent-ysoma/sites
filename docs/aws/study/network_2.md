# VPCエンドポイントとPrivateLinkについて
- VPC内のリソースから各AWSのサービスを利用する場合はAWS内の経路を利用する
- 例えばEC2からS3のバケットをアクセスする場合、通信はAWS内で完結するがAWS内のパブリックルートを通ることになる
   - [大半のマネージド・サービス](https://docs.aws.amazon.com/ja_jp/vpc/latest/privatelink/aws-services-privatelink-support.html)が対象
   - ※ ただし、VPC内に構築したリソースやサービスはローカル通信になるため対象外である
   - イメージ
    - ![aws-basic-vpcとサービス](https://user-images.githubusercontent.com/125415634/234213181-c542de86-b139-49fe-a0c0-9bdd2acadce6.png)

## 何が問題か？
- エンドユーザのガイドラインにてインターネットへの通信は禁止である
- インターネットへ通信を行うため、VPCとオンプレミスに接続して通信制限を行っている
   - 上記において通信制限が厳しかったり、高負荷になる可能性がある

ではどうするか？

## VPCエンドポイントを利用する
- VPCの境界に[VPCエンドポイント]というものを作成
 　- サブネット内に[インターフェイスエンドポイント]を作成
- 作成されたエンドポイントURIでアクセスすることによりインターフェイスエンドポイント経由でサービスにアクセスができるようになる
- イメージ図
   - ![aws-basic-vpcエンドポイント drawio](https://user-images.githubusercontent.com/125415634/234198976-e9a5c646-810a-495b-961a-505a9a3bf62d.png)

## エンドポイントを利用する際の注意点
- サブネットごとにENIが必要になる
   -> 料金が発生(東京リージョンの場合0.014USD/時間 ＋データ転送量 1GBあたり0.01USD)
- ENIのIPアドレスは指定できないのと変更はできない

---
## AWS PrivateLinkについて
- [AWS PrivateLink]([https://aws.amazon.com/jp/privatelink/](https://docs.aws.amazon.com/ja_jp/vpc/latest/privatelink/what-is-privatelink.html))はプライベート接続を介したサービスを提供するためのサービス
  - VPCエンドポイントと（利用者側設定）VPCエンドポイントサービス（サービス提供側設定）の２つがセットとなり提供されている
  - イメージ的にはエンドポイントを通してAWSの各サービスやエンドポイントサービスを公開しているサービスにプライベートで接続できるようになる
    - 前項で説明したVPCエンドポイントはあるいみこのサービス含まれるようなものである
  - ※ ”AWS PrivateLink”というサービス名はない（エンドポイントとエンドポイントサービスが実態である）


Provider VPC
