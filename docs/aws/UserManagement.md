# AWSアカウントや利用するためのユーザ管理について
- AWS環境の作成時にどのようにアカウント管理をしていくかを考える
- [ベストプラクティス](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/best-practices.html)ではルートユーザを日常的なタスクには使用しないと書いてあるが、どう実現するかを考える
- ほか、どのようにID管理をしていくかを考える

---
# まずは
## ルートユーザを使わない理由
- [ここ](https://docs.aws.amazon.com/ja_jp/accounts/latest/reference/root-user.html)に記載されているとおり、ユーザ認証情報を持っていれば、アカウントすべてのリソースにアクセスできてしまう
- 複数人でrootアカウントを利用した場合、誰（どの人やリソース）がどんな操作をしたのかが追えなくなる
- 最悪の場合rootアカウント情報が漏れた場合、悪用されるおそれがある

## AWSアカウントを作成したら、まず行うこと
- ルートユーザのMFA有効化
   - ベストプラクティスに記載の通り

## その後どうするのか？
- 前項で記載した通り、ベストプラクティスに沿うのであれば操作を行うためのユーザの作成を行う。
- 通常の場合はIAMにて作業用ユーザを作成し、権限を付与する。

## 例えばこんな時
- 自己利用の場合、自分が利用するIAMユーザIDを作成すれば良い、ただし別に環境が必要になった時はAWSアカウントを別に取得する必要がある。   
  (この場合、決済情報の登録、rootユーザのMFA有効化、ユーザID作成の作業が必要となる)
- 会社で利用する場合、上記同様単一の環境であればIAMユーザIDを作成し利用することも可能だが、その場合は１つのAWSアカウント内でリソースを利用することになり、   
  最悪の場合動いている環境が誤操作等で破壊されてしまうこともある。

## どうすれば良いのか？
- [AWS Organization](https://docs.aws.amazon.com/ja_jp/organizations/latest/userguide/orgs_introduction.html)を利用
   - 検証利用や会社での個人学習環境の払い出し行うことができるようになり、まっさらなAWS環境を利用することができる
   - コスト管理が一元化でき、場合によってはボリュームディスカウントできる
   - AWSとしても用途ごとのマルチアカウント運用を推奨している
     - ※元情報が無いので後で探す
   - ※AWSアカウントを払い出す場合は、アカウント毎に個別のメールアドレスが必要となるので注意 
- [AWS IAM Identity Center(旧 AWS SSO)](https://docs.aws.amazon.com/ja_jp/singlesignon/latest/userguide/what-is.html)を利用
   - ユーザアカウントを一元管理できる
   - AWS Organizationと一緒に利用することにより、AWSアカウント毎の権限管理をまとめられる
   - 外部認証や外部ID管理を利用することができる(Active DirectoryやOkuta等)

**=> 個人利用であっても会社利用であっても上記の組み合わせでユーザ管理をしていくほうがメリットが多々ある**

---
## 初期権限状況とAsuumeRole、AWS IAM Identity Center＋SSOのイメージ
設定内容のイメージがつきやすいようにどのように権限が付与されているかをまとめてみた

### AWSアカウント作成時のアカウント状況
- 作成されたアカウントIDに対して[root]ユーザのみが操作ができる

<img src="https://user-images.githubusercontent.com/125415634/224245848-b9a60c9c-728d-4ce9-ae72-63396b92270a.png" width="30%">

### AssumeRoleを利用した一時的な権限払い出し（よくあるやつ）
- 基本rootアカウントを使用せず、必要な権限を記載したポリシーをユーザIDに付与する、もしくはAsumeRoleを利用して、一時的な権限付与で対応

<img src="https://user-images.githubusercontent.com/125415634/224864218-e3266069-3313-47d1-ab8d-84059ec4f23f.png" width="30%">

### AWS Organizations + AWS IAM Identity Center (個人開発や自社開発で利用する場合)
- AWS Organizationsを利用することが前提だが、IAM Identity Centerを利用すことにより各AWSアカウントのIAMでユーザやロール管理することなく、IAM ICで管理できるようになる
- また検証や、環境を分けるためのAWSアカウント払い出し時に決済情報不要でAWSアカウントの払い出しができるようになる

<img src="https://user-images.githubusercontent.com/125415634/224866316-89267522-9d65-4552-9b7a-89bd3ef2f288.png" width="40%">

---
# AWS OrganizationsとAWS IAM Identity Centerを使ってみよう！
## AWS Organizationsのセットアップ
- 特に難しい設定ではないので[公式ドキュメントを参照](https://docs.aws.amazon.com/ja_jp/organizations/latest/userguide/orgs_manage_org_create.html)
- よく発生する作業ではないのでマネジメントコンソールで作業したほうが良さそう

## AWS IAM Identity Centerのセットアップ
### 有効化
- 特に難しい設定ではないので[公式ドキュメントを参照](https://docs.aws.amazon.com/ja_jp/singlesignon/latest/userguide/get-started-enable-identity-center.html)
- 予めOrganizationsをセットアップしておく
- 作業アカウントのリージョンが”東京”になっていることを確認する
- 有効化すると設定されるまで多少時間がかかる
### 許可セットとアカウント（必要であればグループ）の作成
- AWSアカウントに権限付与するために、許可セット(権限)とユーザ(もしくはグループ)の設定がひつようになるため作成する
- 許可セットの作成 ([参考](https://docs.aws.amazon.com/ja_jp/singlesignon/latest/userguide/get-started-create-an-administrative-permission-set.html))
   - ”AdministratorAccess”をまずは作成、必要に応じて適切な権限の許可セットを作成する
- グループの作成
   - 許可セットとグループ及びユーザがセットとなるので必要に応じてグループを作成する
- ユーザーの作成
   - まずは管理者ユーザを作成する
   - ユーザ名は変更できないため、社用で使う場合はわかりやすい名前にしておく
   - 個人検証等の場合は、IDはユーザ名に紐づいているため、メールアドレスは個人の場合アカウント作成したときのメールアドレスでも問題ない
### AWSアカウントにユーザまたはグループを割り当てる
- この作業を行うことでAWSアカウントと作成した許可セット、ユーザが紐づけされる
- 手順は[このページ](https://docs.aws.amazon.com/ja_jp/singlesignon/latest/userguide/get-started-assign-account-access-admin-user.html)を参照


---
# 参考リンク
- IAMでのセキュリティのベストプラクティス
  - https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/best-practices.html#enable-mfa-for-privileged-users
- AWS アカウント管理
  - https://docs.aws.amazon.com/ja_jp/accounts/latest/reference/accounts-welcome.html
- AWS Identity and Access Management
  - https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/introduction.html
- 一時クレデンシャルを利用する
  - https://tech.nri-net.com/entry/sts-temp-credential



