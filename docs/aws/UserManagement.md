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
## 「AWS Organizations」とは？
- AWSアカウントを一元管理できる
- 一元管理することにより、すべてのアカウントの請求が一括となる
- [ドキュメント](https://docs.aws.amazon.com/ja_jp/organizations/latest/userguide/orgs_introduction.html)

## 「IAM Ddentity Center」とは？
- AWS Single Sign-On の後継である
- ユーザアカウントを一元管理でき、AWSアカウント毎に権限設定ができる
- [ドキュメント](https://docs.aws.amazon.com/ja_jp/singlesignon/latest/userguide/what-is.html)

---
# 参考リンク
- AWS アカウント管理
  - https://docs.aws.amazon.com/ja_jp/accounts/latest/reference/accounts-welcome.html
- AWS Identity and Access Management
  - https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/introduction.html



