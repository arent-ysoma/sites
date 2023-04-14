# AWSアカウント設定後の環境整理
- メモ的な

## とにかくデフォルトVPCを削除したい
- [参考]https://dev.classmethod.jp/articles/delete-default-vpcs-by-cloudshell/)
- アカウント作成時にデフォルトで有効になっているリージョンにはデフォルトVPCやサブネット、IGWが作成されている
- 消してしまっても問題ないので削除する
- 例えば検証アカウントで一時的にしかアカウントを利用しない場合はコンソール画面が一番はやい
- サービス利用の場合はCLIからまとめて削除してきれいにしてしまうのがいいかもしれない

### 方法１：コンソール画面から削除
- PVC画面からVPCを削除する
  - 警告が表示されるが何もリソースは使われてないのでそのまま削除してしまってもOKである
  - この場合は現在自分が操作しているリージョンのVPCだけ削除される

### 方法２: CloudSHellから削除
- 説明にも記載したがデフォルトで有効になっているリージョンをすべて削除したい場合は、リージョンごとに切り替えて削除すると手間である。   
  こういう時はAWS CLIとシェルコマンドを組み合わせて削除すると楽である。
- ただし一部だけ削除していた場合等で削除できない可能性があると、何かしらのタイミングで他リージョンですでにサービスが開始されている場合は注意である。
- 実行シェルは長いので[別ファイルのリンク](https://github.com/YoichiSoma/sites/blob/main/docs/aws/file/delete_vpc.md)を作成しておく

---
# デフォルトVPC準備
- 削除したあとにVPC、サブネット、IGWの作成、ルートテーブルへの関連付け等を作業行い、利用できる状況にしておく
## 設計
以下の構成図の通り

![vpc-base](https://user-images.githubusercontent.com/125415634/231948559-c8fa6a4e-cd55-4a49-be88-8c9c39c4270c.png)
- VPC
  - Name : VPC-BASE
  - IPv4 CIDR block : 172.30.0.0/16
- subnet A
  - Name : SUBNET-BASE-A
  - CIDR block : 172.30.11.0/24
  - Availability Zone : ap-northeast-1a(AZ-A) 
  - パブリックサブネット
- subnet C
  - Name : SUBNET-BASE-C
  - CIDR block : 172.30.21.0/24
  - Availability Zone : ap-northeast-1c(AZ-C) 
  - パブリックサブネット
- InternetGateway
  - name : IGW-BASE
- Route Table
  - Name : RTT-BASE
  - [IGW-BASE]をデフォルトルートに指定
  - [SUBNET-BASE-A]と[SUBNET-BASE-C]を関連付け
