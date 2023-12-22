AWSで利用できるストレージの概要。

なおEC2等にマウントできるブロックストレージについては説明しない。

---

# ストレージの種別

- よく使われそうなものをピックアップ
- 各ドキュメントのリンクをサービス名に埋め込んでます

- AWSで利用できるファイルシステムは以下の通りである
  - ※ FSxは他にも色々とあるがここはWindowsを例として記載する

サービス名 | S3 | EFS | FSx for Windows
---|---|---|---
種類 | オブジェクトストレージ | ファイルストレージ | ファイルストレージ
アクセス | REST API(HTTPS),CLI,SDK等 | NFSクライアント | SMBクライアント
ユースケース | 大容量コンテンツやバックアップの保存 | 汎用的なファイル共有 | Window利用に特化
利用 | プログラムやサービスからのアクセス | Linuxサーバにマウント | Windowsマシンからアクセス
アクセススピード| 遅い｜普通 | 普通
その他 | 他マネージド・サービスと組み合わせて利用も可能 | 複雑なセットアップがない | AD認証できるので細かい権限管理が可能

---

# 各サービスごとの説明

## [S3 (Amazon Simple Storage Service)](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/userguide)
- AWSといえばS3というぐらい有名
- フルマネージドであり、容量は無制限である
- アクセス経路はインターネット経由である
- アクセス方法は基本RestAPI経由となるが他マネージドサービス等と組み合わせることによりファイルサーバとしても利用可能である
  - AWS Transfer Familyと組み合わせる事によりSFTP,FTPSでのアクセスが可能
  - Storage Gatewayと組み合わることによりNFS,SMBでのアクセスが可能
- 認証管理は基本IAMでの管理となる
  - 上記マネージドサービスを利用する場合はマネージド機能に依存
### 利用用途
- プログラムからのデータ保存
- 大容量データの保管
- バックアップ

クライアント利用PCからアクセスして利用というより、プログラムやサーバからアクセスして利用する用途に向いている

<img src="https://github.com/YoichiSoma/sites/assets/125415634/a437f37b-7166-4a75-a94d-fd88391e69e9" width="500px">


## [EFS (Amazon Elastic File System)](https://docs.aws.amazon.com/ja_jp/efs/latest/ug)
- サーバレスで伸縮自在なマネージドファイルシステム
- 細かい設定が可能
  - マルチAZやスループット等
- アクセス経路はローカル通信のみである
  - オンプレミス環境からのアクセスはVPNやDirectConnect経由となる
- アクセス方法はNFS経由となる
- 認証管理はLinux操作と同等となる
  - ユーザID(UID)、グループID(GID)
### 利用用途
- Linuxサーバにマウントしてストレージとして利用
- アクセス頻度の高いファイルの保管

クライアント利用というより、サーバにマウントして利用するストレージ用途である

<img src="https://github.com/YoichiSoma/sites/assets/125415634/398a2107-5622-44d9-b034-f152cb9d6eec" width="500px">

## [Amazon FSx for Windows File Server](https://docs.aws.amazon.com/ja_jp/fsx/latest/WindowsGuide)
- フルマネージドのWindowsサーバ
  - 構成はインスタンスを利用するのでRDSに近い
- マネージドサービスなインスタンスなので細かい管理が楽である
- **AZごとにデプロイが必要である**
- **アクセス経路はローカル通信のみである**
  - **オンプレミス環境からのアクセスはVPNやDirectConnect経由となる**
- アクセス方法はSMB経由となる
- 認証管理はActiveDirectoryとなるため、ADサーバが存在する場合管理が楽である

### 利用用途
- オンプレミスのWindowsFileサーバの代替として
- Windowsクライアントのファイルサーバとして

Windows環境で利用するには一番最適

<img src="https://github.com/YoichiSoma/sites/assets/125415634/084fa64b-b6b9-4fc6-9118-f615b5002193" width="500px">

---

# まとめ
- EBSを除くとファイルストレージは前項記載の３つとなる。
- オブジェクトストレージ(S3)とファイルストレージ(EFS,FSx)とでは利用方法が違う
