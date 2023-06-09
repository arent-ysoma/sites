# AWSリソースに接続するあれこれ
AWSの各サービスを操作するにはAWSコンソール、AWS CLI、AWS SDK と様々な操作方法がある  
ではAWSのリソース、たとえばEC2にログインして操作したい場合やRDSに接続して操作したい等の接続をどうするか

---
# 直接接続
<img src="https://github.com/YoichiSoma/sites/assets/125415634/023f9627-31dd-47d7-aa23-1704bdba8fca" width="300">

- Linux系であればSSHポート、Windows系であればRDPポートに対してEC2に付与されているIPで接続
- RDSの場合は稼働しているDB（画像ではMySQL）のポート番号に対して各種クライアントにて接続
- 直接接続の場合はSGにて接続元制限を行う必要がある
- 接続はユーザ名、パスワードないしPrivateキーでの接続となる
