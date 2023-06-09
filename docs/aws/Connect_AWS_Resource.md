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

## セッションマネージャを利用しての接続
- AWS Systems Mangerというサービスがあり、リソースを運用管理するものである(他にも色々)
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

## その他
#### EC2 Instance Connect
- これはマネジメントコンソールからSSHでEC2インスタンスに接続する方法
- ただし、キーペアを設定したEC2には接続不可
  - この時点であまり用途が無い気がするが・・・・
 
#### EC2 シリアルコンソール ([参考](https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/ec2-serial-console.html))
- マネジメントコンソール or CLIの場合[ec2-instance-connect]コマンドのオプションで接続できる
- 以下のインスタンスタイプ以外は利用できないので注意
   - Nitro システム上に構築されたすべての仮想化インスタンス
     - ***※ 無料枠であるt2系は上記に該当しないので利用できない***
   - その他特定のインスタンス 
- SSHでどうしても入れないときには有用だが、あまり使うことはない
