# lab2-1 コードからコンテナイメージを作成
- 前項で記載した通りlab2-1ではCodeCommitに反映されたコードにもとづき、コンテナイメージをビルドするところまでの環境構築を行う

---

## CodeCommit設定
- 「CodeCommit」画面にて右上の[リポジトリを作成]か、左ペインより[ソース] > [リポジトリ]をクリックし、リポジトリ画面より[リポジトリ作成]をクリックする
- 「リポジトリを作成」画面にて以下のように入力し、[作成]ボタンをクリックする
   - [リポジトリ名] : container-test
   - 他項目はそのまま
- 作成されると”接続のステップ”という画面が表示されるその中にある”ステップ 3: リポジトリのクローンを作成する”のコマンド内容をコピーする
- cloud9のターミナルにてコピーした内容を貼り付け、実行する
- 作成されたフォルダに移動し、空ファイルを作成する
```
cd container-test
touch buildspec.yml
mkdir nginx
touch nginx/Dockerfile
touch nginx/index.html
```
- 作成したファイルをリポジトリへアップロード
   - ※ cloud9のエディタ画面からでも操作可能なのでアップロード方法は各自やりやすい方法で対応していただけると
```
git add .
git commit -m "add file"
git push origin master
```
- 「CodeCommit」画面で作成されたリポジトリフォルダの内容を表示し、ファイルが作成されていれば問題なし

## ファイルの準備
- 先程作成した空ファイルをcloud9で開いて以下のリンクの内容そのままコピーする
   - [buildspec.yml](https://github.com/YoichiSoma/sites/blob/main/docs/lab/lab2/buildspec.yml)
   - [Dockerfile](https://github.com/YoichiSoma/sites/blob/main/docs/lab/lab2/Dockerfile)
   - [index.html](https://github.com/YoichiSoma/sites/blob/main/docs/lab/lab2/index.html)
- フォルダ構成と各ファイルの内容は以下である
```
(work Dir)
├── buildspec.yml : CodeBuild が docker build して コンテナイメージを作成し ECR のリポジトリに push する際に使用する仕様書
└── nginx
    ├── Dockerfile : ビルドするときに参照されるファイル
    └── index.html ：lab1同様index.htmlの差し替えファイル
```
- ファイルを更新したら再度リポジトリへプッシュすることを忘れずに！

## ECRリポジトリ作成
- 以下の内容で作成する
   - 可視性設定 : プライベート
   - リポジトリ名 : container-test
   - 他項目はデフォルト設定のまま

## CodeBuild設定
- 「CodeBuild」画面左ペインより[ビルド] > [ビルドプロジェクト]を選択し、[ビルドプロジェクト]画面内の[ビルドプロジェクトを作成する]ボタンをクリックする
- [ビルドプロジェクトを作成する]画面がされたら以下の通りに項目を入力し、画面最下部の[ビルドプロジェクトを作成する]ボタンをクリックする (※記載がない項目はデフォルトのまま)
   - プロジェクトの設定
      - プロジェクト名 : container-test
   - ソース
      - ソースプロバイダ : AWS CodeCommit
      - リポジトリ : container-test
      - リファレンスタイプ : ブランチ
      - ブランチ : master
      - 追加設定 > Git のクローンの深さ : Full
   - 環境
      - 環境イメージ : マネージド型イメージ
      - オペレーティングシステム : Amazon Linux 2
      - ランタイム : Standard
      - イメージ : aws/codebuild/amazonlinux2-x86_64-standard:4.0 (※難しいことをやらないので最新版でOK)
      - イメージのバージョン : "このランタイムバージョンには ～"を選択（デフォルト）
      - 環境タイプ : Linux (デフォルト)
      - 特権付与 : "Docker イメージを構築するか、ビルドで~"にチェック
      - サービスロール: 新しいサービスロール
      - ロール名 : codebuild-container-test-service-role (プロジェクト名のものが反映されているはずなのでそのまま利用)
      - 追加設定 > 環境変数
         - 以下の変数を作成
         - |名前|値|タイプ|
           |---|---|---|
           |AWS_ACCOUNT_ID|<利用しているアカウントのID>|プレーンテキスト|
           |AWS_DEFAULT_REGION|ap-northeast-1|プレーンテキスト|
           |IMAGE_REPO_NAME1|container-test|プレーンテキスト|
   - Buildspec
      - ビルド仕様 : buildspec ファイルを使用する
   - 以下項目はそのまま（アーティファクト、ログ）
           
   
