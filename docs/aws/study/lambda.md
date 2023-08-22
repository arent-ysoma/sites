# lambdaを使ってみよう
## 主旨
## 基本

スクリプト単体で動かしてみる

## サーバレスサービス

- boto3というライブラリを利用
- 「AWS SDK for Python」のことで、AWS の各種サービス（Amazon S3、Amazon EC2、Amazon RDSなど）をPythonから操作するためのライブラリ
- 今回はAPI GatewayとAmazon Translate(翻訳サービス)を利用したサーバレスサービスを作ってみる
  - API Gateway とAmazon Translateに関しての細かい説明は割愛


### 翻訳するAPIを作成する
- 作成したAPI
  - https://yjpsh1oap3.execute-api.ap-northeast-1.amazonaws.com/dev/translate?input_text=こんにちわ

## 通知系
