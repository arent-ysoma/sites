# lab2-1 コードからコンテナイメージを作成
- 前項で記載した通りlab2-1ではCodeCommitに反映されたコードにもとづき、コンテナイメージをビルドするところまでの環境構築を行う

---

## ファイルの準備
- Cloud9にて以下の構成でファイルを準備する
```
├── buildspec.yml : CodeBuild が docker build して コンテナイメージを作成し ECR のリポジトリに push する際に使用する仕様書
└── nginx
    ├── Dockerfile : ビルドするときに参照されるファイル
    └── index.html ：lab1同様index.htmlの差し替えファイル
```
- 各ファイルの内容は以下のリンク先のファイル内容をコピーして利用
   - buildspec.yml
   - Dockerfile


