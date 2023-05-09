# AWSアカウントとAWS Organizations
- AWSアカウントをどのように管理、運用していくかの話となる
- 大抵の場合、本番(production)とその他(non-production、ステージングや開発環境等)と分けて運用することが多い.   
その場合、ユーザアカウントを最適な運用方法をどうするかという話でもある

---
## AWSアカウントとは？
- アカウントは"テナント"である
  - "テナント" = 賃貸で言う入居する賃借人(借り主)のこと
- AWSから直接もしくはAWSパートナーからアカウントを払い出ししてもらったもの
- __個人に紐づくアカウントではない__
  - 操作するためのIAMユーザやロールということではないと認識してもらえると
- 払い出しされたアカウントに基づいてAWSリソースを利用できる
   - それぞれのリソースをAWSから借りているというイメージ

## アカウント払い出し時の状態
- アカウントID(１２桁の数値)が付与
- デフォルトでアカウント所有者 (ルートユーザー)が作成される
   - このユーザはアカウント内のすべてのリソースへのフルアクセスが許可されている。
- 以下がAWSアカウント発行時の状況である
   - ![aws-basic-account drawio](https://user-images.githubusercontent.com/125415634/235079336-73ecf537-7358-49d9-92f3-ec300dde92f5.png)

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
前項の状態であると、用途ごとにアカウントを分けたい場合、アカウントIDを別途発行する必要がある。   
その場合、アカウントが分かれているため運用が煩雑になる可能性や予算管理が面倒になるケースが多い。   
- 例えば本番環境と開発環境があった場合、それぞれIAMユーザの払い出しが必要であり、ポリシーも別々に管理する必要がある。
- 予算管理に関しても環境ごとに請求処理が発行され、PJの合計値を出したい場合別途計算をする必要がある。
  - イメージ的にはこんな感じである  
  - <img src="https://user-images.githubusercontent.com/125415634/237005858-a1af0e89-ad73-4aa5-a0cd-7cf1cb5d9fe2.png" width="450">

AWSとして複数アカウントを利用する場合はAWS Organizationsを利用するとよいと記載がある。

---

### AWS Organizationsとは？
複数のAWSアカウントを統合するためのアカウント管理サービスである。
AWS Organizations（以下 AWS OU）を利用することにより以下のメリットがある。
- 支払いを一括管理できる
   - アカウント別の利用コストは別途 Cost Explorer等で確認できるので予算分析にも利用できる
   - また利用金額を統合できるため、ボリュームディスカウントによるコストメリットの恩恵を受けるとことができる
- ユーザ管理や、権限管理の統合
   - アカウントごとのユーザ管理が不要であるため、アカウント整理がし易い
   - 権限管理もアカウントごとに付与できるためセキュリティ統制がやりやすい
- 外部認証連携が利用できる
   - AWS OU + AWS IAM Identity Center (旧 AWS SSO)を利用することにより、強力な認証基盤を利用することができる

### [AWS OU 概念](https://docs.aws.amazon.com/ja_jp/organizations/latest/userguide/orgs_getting-started_concepts.html)
※ 枠組みとしては大きのでなんとなく理解してもらえれば大丈夫かと
- 下図を元に、概念について説明する。
  - <img src="https://user-images.githubusercontent.com/125415634/236995912-7655163f-10a0-48e0-b672-4a7773ce3c76.png" width="450">
- 組織 (Organization)
  - AWS OUを有効化することによりできる枠組み。
  - 有効化することにより１つの管理アカウントとゼロ以上のメンバーアカウントが含まれる。
- ルート (Organizations root)
  - 組織内のすべてのアカウントが設定された親コンテナ。
  - ここにポリシーを適用することにより、組織内のすべてのOUとアカウントに適用される。
  - awsアカウント作成時に作成される[root]ユーザとは別である。
- OU (組織単位)
  - ルート内のアカウントコンテナ
  - OU内にOUを含めることも可能である
  - 親(上位OU？)は１つだけである
- アカウント
  - AWSアカウントのこと、２種類のアカウントがある
    - 管理アカウント
      - 組織を作成、管理、削除できる
      - メンバーアカウントで発生したすべての料金を支払う責任がある
      - 管理アカウントは変更できない
    - メンバーアカウント
      - 管理アカウント以外のアカウント
      - 組織メンバーになることできるのは、１度に１つのみ

----
(以下、コピペ元データのためあとで整理する)


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
- AWS IIC
  - https://docs.aws.amazon.com/ja_jp/singlesignon/latest/userguide/what-is.html
- IAM入門
　- https://blog.serverworks.co.jp/tech/2020/02/03/awsaccountforbeginner/
   
 
