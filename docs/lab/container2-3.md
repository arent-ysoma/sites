# lab2-3 Blue/Greenデプロイ環境の作成
- lab2-1で作成したコンテナイメージをlab2-2でECSクラスタを作成し、サービスに手動デプロイを行った
- 次項で自動デプロイを行うための前準備としてCodeDeployの設定を行う

---
## CodeDeployの作成
### CodeDeployで利用するIAMロール作成
- デプロイ実施時にECS操作やELB操作を行うため権限のあるロールを作成する
- 内容は以下
  - 信頼されたエンティティタイプ　:　AWS のサービス
  - ユースケース　:　CodeDeploy -> CodeDeploy - ECS
  - 許可ポリシー : AWSCodeDeployRoleForECS
  - ロール名 : ecsCodeDeployRole

### CodeDeploy アプリケーション作成
- デベロッパー用ツール > CodeDeploy > アプリケーション > アプリケーションの作成
- 「アプリケーションの作成」画面にて以下を設定し、[アプリケーションの作成]ボタンをクリックする
  - アプリケーション名
    - AppECS-nginx-cluster-nginx-fargate
  - コンピューティングプラットフォーム
    - ”Amazon ECS”を選択

### デプロイグループ作成
- 前項で作成したアプリケーション内にデプロイグループの作成
- [デプロイグループの作成]画面にて以下の設定を行い、[デプロイグループの作成]ボタンをクリックする
  - デプロイグループ名
    - DDgpECS-nginx-cluster-nginx-fargate
  - サービスロール
    - ecsCodeDeployRole
      - 前項で作成したサービスロールを指定
  - 環境設定
    - ECS クラスター名
      - nginx-cluster
    - ECS サービス名
      - nginx-fargate
  - Load balancer
    - Load balancerを選択
      - ALB-ECS
    - 本稼働リスナーポート
      - HTTP:80
    - ターゲットグループ 1 の名前
      - ECSBGA
    - ターゲットグループ 2 の名前
      - ECSBGB
  - デプロイ設定
    - トラフィックの再ルーティング
      - すぐにトラフィックを再ルーティング
    - デプロイ設定
      - CodeDeployDefault.ECSLiner10PercentEvery1Minutes
    - 元のリビジョン終了
      - ０日間 ０時間 10分
    - 詳細 – オプション
      - ロールバック
        - "デプロイが失敗したときにロールバックする"にチェック

### S3バケット作成
- この後利用するappspec.ymlと****を格納するためのバケットを作成
- 名前は全世界でユニークである必要があるためわかりやすいなにかの名前で作成する
  - ex ) nginx-test-dp-20230407
- CLIだと面倒なのでAWSコンソール画面から作成するのが楽である

### appspec.yaml
- デプロイのリビジョンタイプ指定で利用するappspec.yamlファイルを作成し、S3バケットに格納する
- [appspec.yaml]ファイルの作成
  - [ここに](https://github.com/YoichiSoma/sites/blob/main/docs/lab/lab2/2-3/appspec.yaml)ファイルがあるのでこの内容をコピーしてcloud9のエディタで作成する 
  - <TASK_DEFINITION>はタスク定義で作成した内容のアクティブなタスクのARNをコピーする
- ファイルのアップロード
```
aws s3 cp appspec.yaml s3://nginx-test-dp-20230407/
```

### デプロイメント作成
- 前項で作成したアプリケーション内にデプロイを作成
- [Create deployment]画面にて以下の設定を行い、[デプロイの作成]ボタンをクリックする
  - デプロイ設定
    - デプロイグループ
      - DgpECS-nginx-cluster-nginx-fargate
    - リビジョンタイプ
      - アプリケーションは Amazon S3 に格納されています
    - リビジョンの場所
      - 作成したS3バケットのURIを指定
    - リビジョンファイルの種類
      - yaml
- 作成が終わるとデプロイが開始される
  - このタイミングでデプロイが開始される

### 確認
- デプロイ画面でステップ４まで終わっていることを確認する
  - ステップ１が終わっていれば大体はデプロイは問題ないはず
  - ALBのリスナーを表示し、リスナーの詳細にて転送先がECSBGBが100,ECSBGAが0であれば問題なし
  - 今回のタイミングではコンテナイメージの変更はないので表示が替わることはない


