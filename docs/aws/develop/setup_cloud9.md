# cloud9で開発環境を用意する
## 主旨
- cloud9でboto3(AWS SDK for Python)を利用したい
- boto3のバージョンによってはPythonの新しいものを利用する必要がある
- そのための準備

## pyenvの導入
- pytenvとは同じ環境に複数のpythonバージョンを利用できるようにするものである
- cloud9のPythonはデフォルトで3.7.X ぽいので環境を変更せずに上位バージョンを利用できるようにする

### 手順
- pyenvのインストール
  ```
  $ git clone https://github.com/pyenv/pyenv.git ~/.pyenv
  ```
- 確認
  ```
  $ ~/.pyenv/bin/pyenv --version
  pyenv 2.3.24
  ```
- パス通し
  ```
  $ cat << 'EOT' >> ~/.bashrc
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
  EOT
  ```
- 設定の反映
  ```
  $ source ~/.bashrc
  ```
- 確認
  ```
  $ pyenv versions
  * system (set by /home/ec2-user/.pyenv/version)
  ```
## Python 3.11のインストール

今回はLambda関数を事前にcloud9でテストしたいため、最新のサポート対象であるPython3.11をインストールする

- インストール可能なバージョン一覧に存在するか確認
  ```
  $ pyenv install --list | grep 3.11.*
  ```
- インストール前に必要そうなパッケージ準備
  ```
  $ sudo yum -y update
  ```
- 存在が確認できたのでインストール
  ```
  $ pyenv install 3.11.1
