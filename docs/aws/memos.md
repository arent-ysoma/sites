# 未整理情報
- ちょっとした情報をまとめたもの
- ドキュメント化したらここから削除しておく

---

#### 特定のs3バケットにアクセスするためのポリシー
```
pl-s3-ys-lab-test-access
---
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::my-bucket"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::my-bucket/*"
        }
    ]
}
```
---

#### Workspace のプロトコルを変更する方法
- PCOIPだとWEBアクセスが使えないのでセットアップ時にPCOIPを選択した場合はWSPに変更する必要がある
- コマンドは以下
```
aws workspaces modify-workspace-properties \
--workspace-id <workspaceID> \
--workspace-properties "Protocols=[WSP]"
```


##### Windows パスワード取得
###### コンソール
- 対象インスタンスにチェック > アクション > セキュリティ < Windows パスワードを取得 を選択
- [Windowsパスワードを取得]画面にて設定したキーペアの内容をアップロードするか貼り付けを行い、[パスワードを復号化]ボタンをクリック
- 別ウィンドウで情報が表示されるのでメモする
###### CLI
- 以下のコマンドを実行すると表示される
```
aws ec2 get-password-data --instance-id <インスタンスID> --priv-launch-key <キーペア>
```
