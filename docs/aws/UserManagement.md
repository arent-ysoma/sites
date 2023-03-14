# AWSのアカウント管理について
- AWS環境の作成時にどのようにアカウント管理をしていくかを考える
- [ベストプラクティス](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/best-practices.html)ではルートユーザを日常的なタスクには使用しないと書いてあるが、どう実現するかを考える
- ほか、どのようにID管理をしていくかを考える

---
## ルートユーザを使わない理由
- [ここ](https://docs.aws.amazon.com/ja_jp/accounts/latest/reference/root-user.html)に記載されているとおり、ユーザ認証情報を持っていれば、アカウントすべてのリソースにアクセスできてしまう
- 誰（どの人やリソース）がどんな操作をしたのかが追えなくなる
- アカウントリソースは共用できるので必要に応じてアカウントや権限の払い出しを行っていく

## アカウントを作成したら、まず行うこと
- ルートユーザのMFA有効化
   - ユーザID、とパスワードだけの認証だとセキュリティが引くためMFAは必ず設定しておくこと！
- AWS Organizationsのセットアップ
   - 新規アカウントや請求コストの一元管理ができるようになる
   - たとえば検証利用であっても、新規アカウントであれば安心して環境を利用することができる
- AWS IAM Identity Centerのセットアップ
   - 環境ごとにアカウント払い出しが不要となり、認証や権限管理も１元化できる
   - 今まではAssumeRoleが主流であったが、こちらのほうが権限管理が楽である
- ユーザアカウント払い出し

---
## 初期権限状況とAsuumeRole、AWS IAM Identity Center＋SSOのイメージ
### AWSアカウント作成時のアカウント状況
- 作成されたアカウントIDに対して[root]ユーザのみが操作ができる

![IAM_IC-AWSアカウト作成時](https://user-images.githubusercontent.com/125415634/224245848-b9a60c9c-728d-4ce9-ae72-63396b92270a.png)

### AssumeRoleを利用した一時的な権限払い出し（よくあるやつ）
- 基本rootアカウントを使用せず、必要な権限を記載したポリシーをユーザIDに付与する、もしくはAsumeRoleを利用して、一時的な権限付与で対応

![IAM_IC-AsumeRole](https://user-images.githubusercontent.com/125415634/224864218-e3266069-3313-47d1-ab8d-84059ec4f23f.png)

### AWS Organizations + AWS IAM Identity Center
- AWS Organizationsを利用することが前提だが、IAM Identity Centerを利用すことにより各AWSアカウントのIAMでユーザやロール管理することなく、IAM ICで管理できるようになる
- また検証や、環境を分けるためのAWSアカウント払い出し時に決済情報不要でAWSアカウントの払い出しができるようになる

![IAM_IC-OU and IAM_IC](https://user-images.githubusercontent.com/125415634/224866316-89267522-9d65-4552-9b7a-89bd3ef2f288.png)

## 「AWS Organizations」とは？
- AWSアカウントを一元管理できる
- 一元管理することにより、すべてのアカウントの請求が一括となる
- [ドキュメント](https://docs.aws.amazon.com/ja_jp/organizations/latest/userguide/orgs_introduction.html)

## 「IAM Ddentity Center」とは？
- AWS Single Sign-On の後継である
- ユーザアカウントを一元管理でき、AWSアカウント毎に権限設定ができる
- [ドキュメント](https://docs.aws.amazon.com/ja_jp/singlesignon/latest/userguide/what-is.html)


---
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
- AWS アカウント管理
  - https://docs.aws.amazon.com/ja_jp/accounts/latest/reference/accounts-welcome.html
- AWS Identity and Access Management
  - https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/introduction.html



