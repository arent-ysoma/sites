# [AWS PrivateLink](https://docs.aws.amazon.com/ja_jp/vpc/latest/privatelink/what-is-privatelink.html)について
- VPC内のリソースから各AWSのサービスを利用する場合はAWS内の経路を利用する
- 例えばEC2からS3のバケットをアクセスする場合、通信はAWS内で完結するがAWS内のインターネット通信を通ることになる
   - [大半のマネージド・サービス](https://docs.aws.amazon.com/ja_jp/vpc/latest/privatelink/aws-services-privatelink-support.html)が対象
   - VPC内に構築したリソースやサービスはローカル通信になるため対象外である
   - イメージ的には以下
    - ![aws-basic-vpcとサービス drawio](https://user-images.githubusercontent.com/125415634/234176142-e38e4d8e-2f70-4900-8fb4-4b5901c1c826.png)
- 要件によってはインターネット通信不可というガイドラインがあった場合にはPrivateLinkを用いてプライベート接続を行うという話である

## PrivateLinkとはどういうものか？
- VPCの境界にエンドポイントというものを作成し、エンドポイント間はAWSがよしなにプライベート通信にしてくれる
