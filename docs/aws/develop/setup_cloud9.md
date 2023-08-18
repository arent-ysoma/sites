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

今回はLambda関数を事前にcloud9でテストしたいので、最新のサポート対象であるPython3.11をインストールする

- インストール可能なバージョン一覧に存在するか確認
  ```
  $ pyenv install --list | grep 3.11.*
  ```
- インストール前に必要そうなパッケージ準備
   - **"openssl-devel"は"openssl11-devel"とコンフリクトしてしまうので予めアンインストールしておくこと！**
  ```  
  $ sudo yum -y update
  $ sudo yum remove -y openssl-devel
  $ sudo yum -y install gcc make patch zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl11-devel tk-devel libffi-devel xz-devel
  ```
- インストール
  ```
  $ pyenv install 3.11.1
  ```
- 確認
  ```
  $ pyenv versions
  * system (set by /home/ec2-user/.pyenv/version)
  3.11.1
  ```
- 切り替えと確認
  ```
  $ pyenv global 3.11.1
  $ pyenv versions
  system
  * 3.11.1 (set by /home/ec2-user/.pyenv/version)
  ```
- pipのアップデート
  ```
  $ pip install --upgrade pip
  ```

## AWS CLIのアップデート

今回は特に不要だが、環境を最新にしておくためやっておく

- 現在のバージョン確認
  ```
  $ aws --version
  aws-cli/1.18.147 Python/2.7.18 Linux/4.14.309-231.529.amzn2.x86_64 botocore/1.18.6 <- 古いなｗ
  ```
- アンインストール
  ```
  $ sudo pip uninstall awscli -y
  ```
- ２系のインストール
  ```
  $ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  ```
- シェルの再起動とバージョン確認
  ```
  source ~/.bashrc
  $ aws --version
  aws-cli/2.13.10 Python/3.11.4 Linux/4.14.309-231.529.amzn2.x86_64 exe/x86_64.amzn.2 prompt/off
  ```
