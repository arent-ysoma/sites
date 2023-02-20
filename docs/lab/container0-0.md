# コンテナの基本操作
## 趣旨
- ローカル環境でコンテナを操作する
- 基礎の基礎なので軽く説明する程度

## 事前準備
- 環境はAWS Cloud9を利用するので予めセットアップをしておくこと

## 簡単な操作
### nginxを動かしてみる   
- 以下コマンドを実行
```
docker run --name mynginx1 -p 80:80 -d nginx
```
- 動いているか確認
   - ※ "CONTAINER ID"は実行ごとに変わるのでここでは"docker ps"でプロセスが表示されればOK
```
$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                               NAMES
bd29cef95bb2   nginx     "/docker-entrypoint.…"   6 seconds ago   Up 4 seconds   0.0.0.0:80->80/tcp, :::80->80/tcp   mynginx1
```
- テスト
```
$ curl http://localhost
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
~ 以下略 ~
```
- コンテナの停止
   - stop のあとに<CONTAINER ID>を付与する
```
$ docker stop bd29cef95bb2
bd29cef95bb2
```
- 停止確認
  - コマンドを実行し、起動していたコンテナIDが表示されていなければ問題なし
```
$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

### 何が行われたのか？
- "docker run --name mynginx1 -p 80:80 -d nginx"コマンドを実行したことにより以下の処理が行われている
  - DockerHubから"nginx"のイメージをダウンロード
  - ダウンロードしたイメージを[mynginx1]として実行
  - "-p"オプションでローカル80番ポートとnginxのデフォルトポートである80番を割当
  - "-d" バックグラウンドで実行
- ”docker images”を実行すると”nginx”というものが存在していることが確認できる
  

### 片付け
- 停止したコンテナイメージのIDを調べる
```
$ docker ps -a
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS                      PORTS     NAMES
bd29cef95bb2   nginx     "/docker-entrypoint.…"   23 minutes ago   Exited (0) 18 minutes ago             mynginx1
```
- 停止したコンテナを削除
```
$ docker rm bd29cef95bb2
```
- イメージの削除
```
$ docker rmi nginx
```
- 確認
   - "REPOSITORY"が何も無ければOK
```
$ docker images
REPOSITORY   TAG       IMAGE ID   CREATED   SIZE
```
