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

