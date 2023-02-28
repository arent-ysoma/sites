# AWS Code系を利用したコンテナデプロイ
## 趣旨
- [lab1-1](https://github.com/YoichiSoma/sites/blob/main/docs/lab/container1-1.md)では一旦ローカルでイメージを作成し、ECRにアップロードしていた
- lab2ではコードを更新するだけでコンテナイメージを自動でビルド、また環境に合わせたECSへの展開までのハンズオンを行う
- 設定するサービスがかなり多くなるため、lab2では以下の章区分けでハンズオンを行っていく
   - lab2-1 : codecommitへのコード反映からCodeBuildを利用して自動的にECRにコンテナを格納
   - lab2-2 : 環境に合わせたECSへの展開
 
 ## 利用するサービス説明
 ### lab2-1での利用サービス
 - [AWS Codecommit](https://aws.amazon.com/jp/codecommit/) ： プライベート Git リポジトリをホストする、安全で高度にスケーラブルなフルマネージド型ソース管理サービス(AWS版GitHub)
 - [AWS Code Build](https://aws.amazon.com/jp/codebuild/?nc2=h_ql_prod_dt_cb) : フルマネージド型の継続的インテグレーションサービス (サーバレスでコンテナビルドができる等)
 - [AWS Code Pipeline](https://aws.amazon.com/jp/codepipeline/?nc2=h_ql_prod_dt_cp) : フルマネージドの継続的デリバリーサービス
 ### lab2-2での利用サービス
 - [AWS ECS](https://aws.amazon.com/jp/ecs/?nc2=h_ql_prod_ct_ecs) : フルマネージドコンテナオーケストレーションサービス
 - [AWS Code Deploy](https://aws.amazon.com/jp/codedeploy/?nc2=h_ql_prod_dt_cd) : コンピューティングサービスへのソフトウェアデプロイを自動化するフルマネージド型のデプロイサービス
 
 ## 前提条件
 - lab1-1の環境(Cloud9)を利用するので環境を作成してない場合は作成しておくこと
 - **Git操作があるのでgitの概念や、操作系(add,commit,push等)のコマンド操作は予め学習しておくこと**
 
 ---
 ## 想定構成

![コンテナラボ-lab2](https://user-images.githubusercontent.com/125415634/221768001-e4f854fc-6ed1-4bbd-b3fa-ae07d7ca5a9c.png)
- CodeComitのリポジトリ名を「container-test」とする
- ECRリポジトリ名を「container-test」とする
- 利用するベースコンテナイメージは「nginx」を利用
- ビルドプロジェクト名は「container-test」とする
- パイプライン名は「container-test-build」とする
- 「container-test」リポジトリの「master」ブランチにファイルがプッシュされたらビルドを開始する
- 他それぞれの設定項目において項番毎に適宜記載する

---
