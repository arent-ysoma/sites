# AWSリソースに接続するあれこれ
AWSの各サービスを操作するにはAWSコンソール、AWS CLI、AWS SDK と様々な操作方法がある  
ではAWSのリソース、たとえばEC2にログインして操作したい場合やRDSに接続して操作したい等の接続をどうするか

---
## 直接接続
<img src="https://github.com/YoichiSoma/sites/assets/125415634/023f9627-31dd-47d7-aa23-1704bdba8fca" width="300">

- Linux系であればSSHポート、Windows系であればRDPポートに対してEC2に付与されているIPで接続
- RDSの場合は稼働しているDB（画像ではMySQL）のポート番号に対して各種クライアントにて接続
- 直接接続の場合はSGにて接続元制限を行う必要がある
- 接続はユーザ名、パスワードないしPrivateキーでの接続となる

## EC2 Instance Connect
- これはマネジメントコンソールからSSHでEC2インスタンスに接続する方法
  - キーペアは1回限りの公開鍵が生成されるので鍵指定の必要はない
  - 接続方法は２つのパターンがある

#### パターン１：EC2 Instance Connect エンドポイントを使用して接続する
<img src="https://github.com/YoichiSoma/sites/assets/125415634/35fb3062-b40c-4a36-a1bb-5f64c61c1398" width="300">

- 最近発表されたパターンでエンドポイントから接続ができる([参考](https://aws.amazon.com/jp/about-aws/whats-new/2023/06/amazon-ec2-instance-connect-ssh-rdp-public-ip-address/))
  - エンドポイントはサブネット内にENIが作成されるのでローカル通信だけ許可すれば接続できる
  - エンドポイント作成で"EC2 Instance Connect Endpoint"を指定し、VPC、セキュリティーグループ、サブネットを指定すれば作成ができる
- EC2側でもSGでエンドポイントからの接続許可は必要

### パターン２：EC2 Instance Connect を使用して接続する
(画像なし)
- 従来の接続方法
- パターン１と同じSSHだが、利用リージョンのIPアドレスレンジをSGで許可する必要あり（結構広いかも）

## セッションマネージャを利用しての接続
- [AWS Systems Manger](https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/what-is-systems-manager.html)というサービスがあり、リソースを運用管理するものである(他にも色々)
- Systems Mangerのノード管理機能である"Session manger"および”Fleet Manger”を利用することによりEC2上で稼働しているOSにログインすることができる
- RDSへの接続はSessin Manger経由でポートフォワーディングを行うことにより接続が実現できる

#### SSHの場合
<img src="https://github.com/YoichiSoma/sites/assets/125415634/01ddbb23-ccbd-45b1-92a1-22c6098f705c" width="300">

- SSHの場合はSystems ManagerのSession Manager機能を利用して接続できる
  - 予め以下の準備が必要
    - EC2インスタンスにSSMエージェントをインストールする
      - Amazon Linuxの場合はデフォルトでインストールされている（はず）
    - EC2インスタンス用のIAMロールを作成する
    - EC2インスタンスに作成したIAMロールをアタッチする 

#### RDPの場合 (後で試す)
- RDPの場合はSystems ManagerのFleet Managerを利用すると接続できる
- 経路はSession Mangerと変わらないため割愛
- これを利用することにより、AWSコンソール画面からWindowsマシンへ接続することが可能である

#### RDSへの接続 (後で試す)
- Session Mangerで接続したインスタンスからポートフォワードで接続
- そのため別途フォワード用インスタンスが必要となる

## その他
### EC2 シリアルコンソール ([参考](https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/ec2-serial-console.html))
- マネジメントコンソール or CLIの場合[ec2-instance-connect]コマンドのオプションで接続できる
- 以下のインスタンスタイプ以外は利用できないので注意
   - Nitro システム上に構築されたすべての仮想化インスタンス
     - ***※ 無料枠であるt2系は上記に該当しないので利用できない***
   - その他特定のインスタンス 
- SSHでどうしても入れないときには有用だが、あまり使うことはない
