# EC2に安全に接続するいくつかの方法
- 通常EC2に接続する場合はプライベートIPアドレスやパブリックIPアドレスへクライアントからSSHする方法が多い
- 上記の場合特にパブリックIP接続においてはセキュリティを考慮すると接続元IP制限が必要となる
- よりカジュアルかつ安全に接続するいくつかの方法を記載する

## EC2にセッションマネージャで接続する方法
[参考](https://docs.aws.amazon.com/ja_jp/prescriptive-guidance/latest/patterns/connect-to-an-amazon-ec2-instance-by-using-session-manager.html)
- 前提条件
  - インスタンスタイプは古いとだめらしい
     - 無償で使えるt2.micorはだめ
  - インターネット向け通信を許可していること

### IAMロール作成
- ロールの作成
  - AWSサービスでEC2を選択
  - 許可で[AmazonSSMManagedInstanceCore]ポリシーを選択
  - ロール名を[EC2_SSM_Role]（任意）

### EC2にロールの割り当て
- 該当インスタンスを選択し、アクション > セキュリティ > IAM ロールを変更
- 作成したロールを選択

---
## EC2にEC2 Instance Connectで接続する方法
[参考](https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/connect-linux-inst-eic.html)
### 前提条件
- IAMユーザーにEC2InstanceConnectポリシー権限があること
  - 以下の権限が付与されている場合はポリシー設定不要
  - AdministratorAccess
  - PowerUserAccess
- パブリックIPを持っていること

### 設定
#### SGで以下を許可
- インバウンド
  - タイプ: SSH
  - ソース: 3.112.23.0/29 

### 接続方法
- AWSコンソールから該当のEC2インスタンスを選択し。"接続"ボタンをクリック
- 「インスタンスに接続」画面にて[EC2 Instance Connec]タブを選択
- そのまま[接続]ボタンをクリックする

### 補足
- [3.112.23.0/29]はAWS各サービス向けに発行されたパブリックIPレンジである
- もし接続できなくなった場合は以下で検索可能である
- ```
curl -s https://ip-ranges.amazonaws.com/ip-ranges.json | \
   jq '.prefixes[] | select(.region == "ap-northeast-1" and .service == "EC2_INSTANCE_CONNECT")'
```
