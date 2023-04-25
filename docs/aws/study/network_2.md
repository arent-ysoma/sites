# VPCエンドポイントとPrivateLinkについて
- (参考)[AWS PrivateLink](https://docs.aws.amazon.com/ja_jp/vpc/latest/privatelink/what-is-privatelink.html)について
- VPC内のリソースから各AWSのサービスを利用する場合はAWS内の経路を利用する
- 例えばEC2からS3のバケットをアクセスする場合、通信はAWS内で完結するがAWS内のパブリックルートを通ることになる
   - [大半のマネージド・サービス](https://docs.aws.amazon.com/ja_jp/vpc/latest/privatelink/aws-services-privatelink-support.html)が対象
   - ※ ただし、VPC内に構築したリソースやサービスはローカル通信になるため対象外である
   - イメージ的には以下
    - ![aws-basic-vpcとサービス drawio](https://user-images.githubusercontent.com/125415634/234176142-e38e4d8e-2f70-4900-8fb4-4b5901c1c826.png)
- 要件によってはインターネット通信不可というガイドラインがあった場合にはVPCエンドポイントやPrivateLinkを用いてプライベート接続を行うという話である

## どう実現しているのか？
- ざっくりと
   - VPCの境界に[VPCエンドポイント]というものを作成
   - サブネット内に[インターフェイスエンドポイント]を作成
   - 作成されたエンドポイントURIでアクセスすることによりインターフェイスエンドポイント経由でサービスにアクセスができるようになる
- イメージ図
   - ![aws-basic-vpcエンドポイント drawio](https://user-images.githubusercontent.com/125415634/234198976-e9a5c646-810a-495b-961a-505a9a3bf62d.png)

## エンドポイントを利用する際の注意点
- サブネットごとにENIが必要になる
   -> 料金が発生(東京リージョンの場合0.014USD/時間 ＋データ転送量 1GBあたり0.01USD)
- ENIのIPアドレスは指定できないのと変更はできない
