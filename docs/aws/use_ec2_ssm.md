# EC2にセッションマネージャで接続する方法
[参考](https://docs.aws.amazon.com/ja_jp/prescriptive-guidance/latest/patterns/connect-to-an-amazon-ec2-instance-by-using-session-manager.html)
- 前提条件
  - インスタンスタイプは古いとだめらしい
     - 無償で使えるt2.micorはだめ
  - インターネット向け通信を許可していること

## IAMロール作成
- ロールの作成
  - AWSサービスでEC2を選択
  - 許可で[AmazonSSMManagedInstanceCore]ポリシーを選択
  - ロール名を[EC2_SSM_Role]（任意）

## EC2にロールの割り当て
- 該当インスタンスを選択し、アクション > セキュリティ > IAM ロールを変更
- 作成したロールを選択
