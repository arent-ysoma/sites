# AWS IAM Identity Center について
[前項](https://github.com/YoichiSoma/sites/blob/main/docs/aws/study/account_ou.md)ではAWS OUを利用することにより、請求先の一本化やAWSアカウントの一元管理ができることを説明した。   
ただし、実際にユーザが利用するためには更にIAMアカウント管理が必要となる。  
そこで **"AWS IAM Identity Center(旧AWS SSO)"** を利用することにより、まとめて管理できるのでそちらの説明を行う。

---

# [AWS IAM Identity Center](https://docs.aws.amazon.com/ja_jp/singlesignon/latest/userguide/what-is.html) とは？
- 複数のAWSアカウントとアプリケーションへのSingle Sgin-Onアクセスの一元管理を行うサービスである。
  - 認証情報を一元管理できる (AWS OUと連携して)
  - 外部のIdPと連携できる (Active Drectory,Google WorkSpace等)
  - 一時アクセスキーを簡単に発行できる
     - ローカル環境はIaCを実行する場合に有効である

## どういう状況になるのか？
前項で説明した通り、AWSアカウントをAWS OUを利用せず個々に管理した場合、それぞれのAWSアカウント毎にIAMユーザの作成やロールの管理が必要となる。   
AWS IICを有効化することにより以下の状態となる。

<img src="https://github.com/YoichiSoma/sites/assets/125415634/b148e99a-ce90-4bbe-a203-ab41257032ab" width="450">

#### 図の説明
- まず１つの管理アカウント(Management Account)と２つのメンバーアカウント(A,B)を含むOU（組織）が存在する
- [Management Accout]リソース内でIICを設定、ユーザ(user_A,B,C)、グループ(AとBが所属しているグループ)、権限セット(1,2)が作成されている
- グループには権限セット1を紐づけ、AccountAに紐づけしている
- User_Cには権限セット2を紐づけ、AccountBに紐づけをしている

上記構成だとあまりメリットが無いように感じるが例えば下記の様の構成の場合において   
<img src="https://github.com/YoichiSoma/sites/assets/125415634/7597257e-2af0-4795-81f7-ee21948a724b" width="450">   
ユーザ権限を変更する場合に所属グループを変更するか、権限セットの割当を変更するだけで権限変更ができるため、運用コストが下がる


