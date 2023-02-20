# AWS App Runner + AWS ECR を利用したコンテナ環境構築
## 趣旨
- まずはさっくりクラウド上でコンテナ環境を動かしてみる
- AWSで提供しているサービスの内、一番わかりやすのがAppRunnerであったのでこれを利用

## 「AWS App Runner」 と「AWS ECR」
- [AWS App Runner](https://aws.amazon.com/jp/apprunner/)とはフルマネージド型のコンテナアプリケーションサービスである
- [AWS ECR](https://aws.amazon.com/jp/ecr/)はAWSが提供するコンテナレジストリである
- AppRunnerとECRを連携して、新しいイメージがレジストリにアップロードされた場合、自動デプロイすることが可能である

## 前提条件
- コンテナがビルドできる環境を用意しておく
- IAMロールにてECR及びAppRunnerの作成及び実行権限を付与して置くこと
  - ”AdministratorAccess”ロールであれば多分操作はほとんどできるはず

---
# 想定構成
![コンテナラボ-lab1 drawio](https://user-images.githubusercontent.com/125415634/220017373-c8d2dff0-a63c-4af7-86b5-35e2ce6fd041.png)
- ECRリポジトリ名を「nginx-test」とする
- AppRunnerのサービス名を「nginx-test」とする

---
## イメージ作成
- 作業用フォルダを作成し、フォルダに移動
```
mkdir tmp && cd $_ 
```
- 差し替え用の[index.thml]ファイルを作成
```
echo -e "<h1>nginx test</h1>\n" > index.html
```
- Dockerfileを作成
```
cat << EOF > Dockerfile
FROM 'nginx:latest'
RUN service nginx start
ADD index.html /usr/share/nginx/html/
EOF
```
- イメージをビルドする
```
docker build -t nginx-test ./
```
- イメージが作成されているか確認
```
docker images
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
nginx-test   latest    49aabfdeddca   2 seconds ago   142MB
nginx        latest    3f8a00f137a0   11 days ago     142MB
```
### 動作確認
- コンテナの起動
```
docker run --name my-nginx-test -p 80:80 -d nginx-test
```
- テスト
```
curl http://localhost
<h1>nginx test</h1>
```
- 停止
```
docker stop my-nginx-test
```
- 停止したコンテナを削除
```
docker rm my-nginx-test
```

## 準備（ECR）
### リポジトリをECRに作成する (※ 作成するにはECRを操作できる権限が必要)
- 「ECR」画面にて右上の[使用方法]をクリックか、左ペインより[Repositories]をクリックし、リポジトリ画面より[リポジトリ作成]をクリックする
- 「リポジトリを作成」画面にて以下を設定し、画面最下部にある[リポジトリを作成]ボタンをクリックする
  - 一般設定
    - 可視性設定: プライベート
    - リポジトリ名: 適当な名前（nginx-test 等）
  - ほか設定はそのまま

## 作成したリポジトリにnginxイメージをアップロード
- 作成したリポジトリ名を選択し、表示された画面の右上にある[プッシュコマンドの表示]をクリックする
- "1. 認証トークを取得し ～”の内容をコピーし、コンソール画面に貼り付ける
```
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin <アカウントID>.dkr.ecr.ap-northeast-1.amazonaws.com
---
WARNING! Your password will be stored unencrypted in /home/ec2-user/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```
- "3.構築が完了したら～"の内容をコンソール画面に貼り付ける
```
docker tag nginx-test:latest <アカウントID>.dkr.ecr.ap-northeast-1.amazonaws.com/nginx-test:latest
```
- イメージ状況の確認
```
docker images
---
REPOSITORY                                                     TAG       IMAGE ID       CREATED         SIZE
<アカウントID>.dkr.ecr.ap-northeast-1.amazonaws.com/nginx-test   latest    49aabfdeddca   9 minutes ago   142MB
nginx-test                                                     latest    49aabfdeddca   9 minutes ago   142MB
nginx                                                          latest    3f8a00f137a0   11 days ago     142MB
```
- "4.以下のコマンドを実行して~"の内容をコンソール画面に貼り付ける
```
$ docker push <アカウントID>.dkr.ecr.ap-northeast-1.amazonaws.com/nginx-test:latest
The push refers to repository [<アカウントID>.dkr.ecr.ap-northeast-1.amazonaws.com/nginx-test]
a0fde0a42b2b: Pushed 
~ 以下略 ～
```
- [nginx-test]リポジトリ画面にてイメージタグ"latest”がプッシュされていることを確認する

---

## AppRunner設定
### サービス作成
- 「App Runner」を開き、左ペインよりサービスを選択
- 「サービス」画面から[サービスの作成]ボタンをクリック
- 「ソース及びデプロイ」画面で以下の通り項目を設定し、[次へ]ボタンをクリックする
  - ソース
    - リソースタイプ
      - ”コンテナレジストリ”を選択
    - プロバイダー
      - ”Amazon ECR”を選択
    - コンテナイメージのURI
      - 前項で作成したECRリポジトリを選択
      - イメージタグは"latest"を選択
  - デプロイ設定 > デプロイトリガー
    - ”自動”を選択
  - デプロイ設定 > ECRアクセスロール
    - ”新しいサービスロールの作成”を選択
    - サービス名はデフォルト(AppRunnerECRAccessRole)のままか、なにかわかりやすい名前にする
- 「サービスを設定」画面で以下の通り項目を設定し、[次へ]ボタンをクリックする
  - サービス設定
    - サービス名：適当に、"nginx-test"とか
    - 仮想CPUとメモリ：一番ミニマムに
      - 1vCPU、2GB
    - ポート：80
      - コンテが動くポートが80番なのでそれに合わせる
  - ほか設定はそのまま
- 「確認および作成」画面で一通り内容を確認し、[作成とデプロイ]ボタンをクリックする
  - うまく行けば5分ぐらいでデプロイされる
- ステータスが"Running"になったらデフォルトドメインにアクセスすると"nginx test"と表示される

### イメージ更新
新しいコンテナイメージがECRリポジトリにプッシュされたらデプロイされるかのテストを行う
- 現状のイメージ状況確認
```
$ docker images
REPOSITORY                                                     TAG       IMAGE ID       CREATED             SIZE
<アカウントID>.dkr.ecr.ap-northeast-1.amazonaws.com/nginx-test   latest    49aabfdeddca   About an hour ago   142MB
nginx-test                                                     latest    49aabfdeddca   About an hour ago   142MB
nginx                                                          latest    3f8a00f137a0   11 days ago         142MB
```
- ビルドしたフォルダー内にあるindex.htmlファイルの中身を変更する
```
sed -i s/test/test222/g index.html
```
- 再度イメージをビルドする
```
docker build -t nginx-test ./
```
- イメージ状況の確認
   - "nginx-test"イメージのIMAGE ID が変わっていることを確認
```
$ docker images
REPOSITORY                                                     TAG       IMAGE ID       CREATED             SIZE
nginx-test                                                     latest    1194d2a718d1   10 seconds ago      142MB
<アカウントID>.dkr.ecr.ap-northeast-1.amazonaws.com/nginx-test   latest    49aabfdeddca   About an hour ago   142MB
nginx                                                          latest    3f8a00f137a0   11 days ago         142MB
```
- イメージタグを付与
```
docker tag nginx-test:latest <アカウントID>.dkr.ecr.ap-northeast-1.amazonaws.com/nginx-test:latest
```
- イメージ状況の確認
   - nginx-testのIMAGE IDと"アカウントID.dkr~"のIDが一緒になっている
   - 既存の"アカウントID.dkr~"のTAGが"<none>"に変わっている
```
$ docker images
REPOSITORY                                                     TAG       IMAGE ID       CREATED             SIZE
<アカウントID>.dkr.ecr.ap-northeast-1.amazonaws.com/nginx-test   latest    1194d2a718d1   4 minutes ago       142MB
nginx-test                                                     latest    1194d2a718d1   4 minutes ago       142MB
<アカウントID>.dkr.ecr.ap-northeast-1.amazonaws.com/nginx-test   <none>    49aabfdeddca   About an hour ago   142MB
nginx                                                          latest    3f8a00f137a0   11 days ago         142MB
```
- イメージプッシュ
```
docker push <アカウントID>.dkr.ecr.ap-northeast-1.amazonaws.com/nginx-test:latest
```
- pushしたら[nginx-test]サービスのステータスが”Operation in progress”となり、デプロイが実行される
[nginx-test]サービスのステータスが”Running”になったら、ドメインにアクセスして、”nginx test222”と表示されることを確認する
