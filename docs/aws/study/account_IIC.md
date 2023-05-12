# AWS IAM Identity Center について
[前項]ではAWS OUを利用することにより、請求先の一本化やAWSアカウントの一元管理ができることを説明した。   
ただし、実際にユーザが利用するためには更にIAMアカウント管理が必要となる。  
そこで"AWS IAM Identity Center(旧AWS SSO)"を利用することにより、まとめて管理できるのでそちらの説明を行う。

---

# [AWS IAM Identity Center](https://docs.aws.amazon.com/ja_jp/singlesignon/latest/userguide/what-is.html) とは？
- 複数のAWSアカウントとアプリケーションへのSingle Sgin-Onアクセスの一元管理を行うサービスである。
  - 認証情報を一元管理できる (AWS OUと連携して)
  - 外部のIdPと連携できる (Active Drectory,Google WorkSpace等)
  - 一時アクセスキーを簡単に発行できる
     - ローカル環境はIaCを実行する場合に有効である

## どういう状況になるのか？
前項で説明した通り、AWSアカウントをAWS OUを利用せず、個々に管理した場合、それぞれのAWSアカウント毎にIAMユーザの作成やロールの管理が必要となる。   
AWS IICを有効化することにより以下の状態となる。

<img src="https://github.com/YoichiSoma/sites/assets/125415634/b148e99a-ce90-4bbe-a203-ab41257032ab" width="450">

#### 図の説明
