# EC2キーペア秘密鍵の管理について

## 参考URL
- https://dev.classmethod.jp/articles/managing-keypairs-with-secrets-manager/

## やりたいこと
- EC2キーペア秘密鍵を管理したい
- ファイルサーバ等に保存するのもいいが、できればAWS内で完結したい
- S3も検討したが権限管理が面倒なのでほかを検討
- secret mangerなら権限管理や取り出しやすいのでこれを採用

---

# 使い方
- cloudshellで操作が完結するので管理しやすい
- "example-keypair"は適宜読み変えること

## 鍵の登録方法
- **※ "fileb://~"の”ｂ”をつけ忘れると正しくバイナリデータとして登録されないので注意！**
```
$ KEYPAIR_NAME=example-keypair
$ aws secretsmanager create-secret \
    --name ${KEYPAIR_NAME} \
    --secret-binary fileb://~/.ssh/${KEYPAIR_NAME}.pem
```

## ダウンロード
```
$ KEYPAIR_NAME=example-keypair
$ aws secretsmanager get-secret-value \
    --secret-id ${KEYPAIR_NAME} \
    --query 'SecretBinary' \
    --output text \
    | base64 -d > ${KEYPAIR_NAME}.pem
```

## 削除する場合
- 同じ名前で登録できなくなるので削除してまた登録したい場合はオプションを付ける
```
$ KEYPAIR_NAME=example-keypair
$ aws secretsmanager delete-secret --secret-id  ${KEYPAIR_NAME} --force-delete-without-recovery
```

## 更新する場合
```
$ KEYPAIR_NAME=example-keypair
aws secretsmanager update-secret \
    --name ${KEYPAIR_NAME} \
    --secret-binary fileb://~/.ssh/${KEYPAIR_NAME}.pem
```

SecretMangerの権限管理は適宜行うこと！
