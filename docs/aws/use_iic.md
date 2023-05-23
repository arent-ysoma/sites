# AWS IAM Identity Center(IIC , 旧SSO) の使い方

---
## CLIで別のAWSアカウントの権限を利用する
- [参考](https://dev.classmethod.jp/articles/aws-cli-for-iam-identity-center-sso/)
- cloudshellでやってみる

---
## 設定
例として、awsアカウントA(ACC-A)とawsアカウントB(ACC-B)でSSOアカウントを利用しているとする。  
ACC-BアカウントでACC-AのAWSリソースを操作したい場合の設定となる。

- [aws configure sso]コマンドを実施し、適宜値を入力していく
```
[cloudshell-user@ip-10-2-14-146 ~]$ aws configure sso
SSO session name (Recommended): acc-sso # <- セッション名なので何かわかりやすいものを指定する
SSO start URL [None]: https://d-xxxxxxxxxx.awsapps.com/start # <- ログインURLを指定する
SSO region [None]: ap-northeast-1 # <- もしSSOを利用しているRegionが東京リージョン以外であれば明示的に指定したほうがいいかも
SSO registration scopes [sso:account:access]: # <- ここは空のままでOK
Attempting to automatically open the SSO authorization page in your default browser.
If the browser does not open or you wish to use a different device to authorize this request, open the following URL:

https://device.sso.ap-northeast-1.amazonaws.com/

Then enter the code:

XXXX-YYYY # <- ここは認証するためのURLのため、ランダムで表示される
```
- 認証コードが表示されたら、表示されているURLにアクセスを行う
  - CLI画面で表示されているコードを入力し、[Next]をクリック
  - ![SSO_auth](https://github.com/YoichiSoma/sites/assets/125415634/8772a67d-4567-4382-b1be-3a4c8bf1a5d4) 
  - "Allow botocode- ~ "画面が表示されたら[Allow]をクリック
  - ![SSO_auth_2](https://github.com/YoichiSoma/sites/assets/125415634/c02c4cda-13e6-472d-847a-963f28d57141)
  - "Allow botocode-<セッション名> can now access your ddata"画面が表示されたら認証ウインドウを閉じる
  - ![SSO_auth_3](https://github.com/YoichiSoma/sites/assets/125415634/2086c8dc-fbda-4f4b-a57c-1a1a4fce4823)
- CLI画面に戻ると、AWSアカウントを指定する表示に変わっているので、以降の設定を進める
```
There are 2 AWS accounts available to you.
> ACC-A, hoge+acc-a@gmail.com (111111111111) # <- こちらを選択   
  ACC-B, hoge+acc-b@gmail.com (222222222222)    

There are 2 AWS accounts available to you.
Using the account ID 111111111111
The only role available to you is: AdministratorAccess # <- ここは許可セット名画表示される
Using the role name "AdministratorAccess"
CLI default client Region [None]: ap-northeast-1 # <- 念のため明示的に指定する
CLI default output format [None]:
CLI profile name [AdministratorAccess-111111111111]: acc-a # <- わかりやすいプロファイル名をつける

To use this profile, specify the profile name using --profile, as shown:

aws s3 ls --profile acc-a
```
- 適当なAWSコマンドを実施してみる
```
$ aws s3 ls --profile acc-a
```
   - 実施した内容がacc-aに設定されているリソースが表示されればOK

----
## 再度認証をする場合
aws iicではセッション期間が指定されている(デフォルトは8時間)   
そのため期限が切れた場合は再認証を行う

- [aws sso login]コマンドで認証を行える
```
$ aws sso login --profile acc-a
```
- 実行すると認証用URLとコードが表示されるのでWEB画面で認証を行う

---
## アカウントを追加したい場合
- ACC-AとACC-B、更にACC-C(333333333333)のアカウントが存在しておりそちらもACC-Bのユーザアカウントで操作したい場合は[.aws/config]を編集すれば良い
- 内容的には以下の様な感じとなる
```
$ vi .aws/config
[profile acc-a]
sso_session = acc-sso
sso_account_id = 111111111111
sso_role_name = AdministratorAccess
region = ap-northeast-1
[sso-session acc_sso]
sso_start_url = https://d-xxxxxxxxxx.awsapps.com/start
sso_region = ap-northeast-1
sso_registration_scopes = sso:account:access
## ここから下を追加する
[profile acc-c]
sso_session = acc-sso
sso_account_id = 333333333333
sso_role_name = AdministratorAccess
region = ap-northeast-1
```

---
## CodeCommitで利用したい
- コードを管理しているAWSアカウントがACC-AでありACC-Bでそのコードを利用したいときどうするか。
- [参考](https://dev.classmethod.jp/articles/grc-codecomit-add-remoterepo/)
- [参考2](https://docs.aws.amazon.com/ja_jp/codecommit/latest/userguide/setting-up-git-remote-codecommit.html)
- 設定や操作内容はcloudshellで操作する場合の話となる

### 設定
- GRC(git-remote-codecommit)をインストール
```
pip3 install git-remote-codecommit
```
- ACC-Aのhogeリポジトリの内容をcloneしたい場合は以下のコマンドでcloneできる
```
git clone codecommit::ap-northeast-1://<プロファイル名>@hoge
```
- [リポジトリ/.git/config]のファイルを見てもらうとわかるがoriginのURLがGRCとなっている




