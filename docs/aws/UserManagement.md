# AWSのアカウント管理について
- AWS環境の作成時にどのようにアカウント管理をしていくかを考える
- [ベストプラクティス](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/best-practices.html)ではルートユーザを日常的なタスクには使用しないと書いてあるが、どう実現するかを考える
- ほか、どのようにID管理をしていくかを考える

（以下）
- 今までは[IAMロール](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/introduction.html)にて権限委譲(AssumeRole)で権限を管理していた
- これからは[AWS IAM Identity Center](https://docs.aws.amazon.com/ja_jp/singlesignon/latest/userguide/what-is.html)で管理していくのがトレンドとなるかもしれない
- ”IAM Ddentity Center”についての説明や使い方をまとめる

---

# IAMの要素
- IAMは”ID”と呼ばれる個別の番号（もしくはリソース名）と”アクセス管理”で構成されている。
- ID
  - ”ユーザー”、”ユーザグループ”、**”ロール”** のこと。
  - AWSアカウント作成時のルートユーザもIDに含まれており、AWSのサービス、リソースに対して完全なアクセス権を持つ。   
    そのためアカウント作成後必ずIAMユーザを作成し、作成したユーザで操作を行うのが望ましい。 
- アクセス管理
  - **ポリシー** と呼ばれているもの。
  - サービスやリソースに対しての操作を可否する定義である。
  - 更に細かく分類される（次項参照）
- イメージ的なものは[ここを参照](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/intro-structure.html)

## [IAM Policy(ポリシー)]の分類
- 大きく分けて、”IDペースのポリシー”と”リソースベースのポリシー”がある。[ほかにも色々とあるが](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/access_policies.html#policies_id-based)概要を把握する上で不要なため割愛
- IDベースのポリシー
   - アイデンティティ（ユーザー、ユーザグループ、ロール）が実行できるもの
   - 更に以下に分類される
      - AWS管理ポリシー :標準で作成されているもの
      - カスタマー管理ポリシー : 手動で作成したもの
      - インラインポリシー : ユーザやロール等に埋め込まれたもの
   - IDベースのポリシーはIDに付与することで初めて適用される
- リソースベースのポリシー
   - リソースに直接付与するポリシー  (S3等) 

## [IAM User]とは
- AWSとやり取りをするための人間、またはワークロードである
  - AWSコンソールでの操作、AWS CLIでの操作、APIキーやSSHキーを利用してAWSのリソースを操作することことである

## [IAM Role(ロール)]とは
- AWSのリソース(ec2,やrds,s3等)にポリシーを付与するもの
- EC2からS3にアクセスしたり、SSMからEC2にアクセスできるポリシーを付与することができる
- ロールはIAMユーザに委任することもできる（この後出てくる"AsumeRoleにつながる"）

---
# [AsumeRole]とは
- 他のIAMロールを引き受けるアクション
- AWSコンソールでの操作としては”ロールの切り替え”、AWS CLIの場合は"aws sts assume-role"でロールの引受ができる

---
# 「IAM Ddentity Center」とは？
- AWS Single Sign-On の後継である

