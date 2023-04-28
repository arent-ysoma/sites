# AWSアカウントとAWS Organizations

## AWSアカウントとは？
- アカウントは"テナント"である
  - "テナント" = 賃貸で言う入居する賃借人(借り主)のこと
- AWSから直接もしくはAWSパートナーからアカウントを払い出ししてもらったもの
- __個人に紐づくアカウントではない__
- 払い出しされたアカウントに基づいてAWSリソースを利用できる
   - それぞれのリソースをAWSから借りているというイメージ

## アカウント払い出し時の状態
- アカウントID(１２桁の数値)が付与
- デフォルトでアカウント所有者 (ルートユーザー)が作成される
   - このユーザはアカウント内のすべてのリソースへのフルアクセスが許可されている。
- 以下がAWSアカウント発行時の状況である
![aws-basic-account drawio](https://user-images.githubusercontent.com/125415634/235079336-73ecf537-7358-49d9-92f3-ec300dde92f5.png)

- 上記の状態からIAMにて操作に応じた権限のユーザやロールの払い出しを行うことによりリソースを利用できることになる
- リソースはARNと呼ばれる一意の認識情報である
- 例 ）
   ```
   arn:partition:service:region:account-id:resource-id
   arn:partition:service:region:account-id:resource-type/resource-id
   arn:partition:service:region:account-id:resource-type:resource-id
   ```
- [参考 : リソースネーム](https://docs.aws.amazon.com/ja_jp/general/latest/gr/aws-arns-and-namespaces.html)

## [AWS Organizations](https://docs.aws.amazon.com/ja_jp/organizations/latest/userguide/orgs_introduction.html)
前項の状態であると、用途ごとにアカウントを分けたい場合、IDを別途発行する必要がある。   
その場合、アカウントが分かれているため運用が煩雑になる可能性や予算管理が面倒になるケースが多い。   
AWSとして複数アカウントを利用する場合はAWS Organizationsを利用するとよいと記載がある。


- (OUの概要図を作成する！）
-  

----

## 権限（IAM ユーザ、ロール、ポリシー）
- ポリシー
  - リソースに対して許可や禁止、操作制限等を行う情報
- ロール
  - ポリシー

---
## 参考
- AWS全般のリファレンス
  - https://docs.aws.amazon.com/ja_jp/general/latest/gr/Welcome.html
- AWS Well-Architected Framework
  - https://docs.aws.amazon.com/ja_jp/wellarchitected/latest/framework/welcome.html
- AWSアカウント管理
  - https://docs.aws.amazon.com/ja_jp/accounts/latest/reference/accounts-welcome.html 
- IAM
  - https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/introduction.html
- IAM入門
　- https://blog.serverworks.co.jp/tech/2020/02/03/awsaccountforbeginner/
   
 
