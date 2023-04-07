# lab2-2 ECSクラスタ作成
- [lab2-1](container2-1.md)でコンテナイメージの準備まで行った。    
- 次にECSクラスタを作成し、作成したイメージをクラスタにデプロイするところまでやってみる。
- 作業内容に "*** (CLI)"と記載があるものはcoud9のターミナルから作業を行う
---
## 前準備

---
## ALB作成
### ALBに設定するセキュリティグループの作成 (CLI)
- インターネットからHTTPとHTTPSを許可するグループを作成
  - ”VPCID= ~ ”はハンズオンを行うVPCIDが１つの場合利用、複数ある環境であれば予めVPCIDを確認しておくこと
```
VPCID=`aws ec2 describe-vpcs | jq -r '.Vpcs[].VpcId'`
aws ec2 create-security-group --group-name SG-ALB --description "Internet to ALB" --vpc-id ${VPCID}
aws ec2 describe-security-groups | jq -r '.SecurityGroups[] | [.GroupName, .GroupId] | @csv'
```
- 作成したグループにインバウンドルールを追加
```
SGID=`aws ec2 describe-security-groups --filters Name=group-name,Values=SG-ALB | jq -r ' .SecurityGroups[].GroupId'`
aws ec2 authorize-security-group-ingress --group-id ${SGID} --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id ${SGID} --protocol tcp --port 443 --cidr 0.0.0.0/0
```
- 確認
```
aws ec2 describe-security-groups --filters Name=group-name,Values=SG-ALB | \
jq -r '.SecurityGroups[].IpPermissions[] | [ .IpProtocol, .ToPort, .IpRanges[].CidrIp ] |  @csv'
```

### ターゲットグループ作成 (CLI)
Blue/Green デプロイを行うため、２つ作成を行う
- 変数代入
```
VPCID=`aws ec2 describe-vpcs | jq -r '.Vpcs[].VpcId'`
```
- gorup1 ECSBGA
```
aws elbv2 create-target-group --name ECSBGA --protocol HTTP --port 80 --target-type ip --vpc-id ${VPCID}
```
- gorup2 ECSBGB
```
aws elbv2 create-target-group --name ECSBGB --protocol HTTP --port 80 --target-type ip --vpc-id ${VPCID}
```
- 確認
```
aws elbv2 describe-target-groups
```

### ALB作成 (CLI)
- 事前変数作成
  - 利用するサブネットID、SG、の指定が必要なので変数化しておく
  - subnetIDは[Name]タグでフィルターしているので環境に応じてvaluesの値を変更する
    - 自分の環境では"base-aza"と"base-azc"を作成してある
  - ALB作成時に最低２つのサブネットが必要である
```
SGID=`aws ec2 describe-security-groups --filters Name=group-name,Values=SG-ALB | jq -r ' .SecurityGroups[].GroupId'`
SUBNETID1=`aws ec2 describe-subnets --filters "Name=tag:Name,Values=base-aza" | jq -r '.Subnets[].SubnetId'`
SUBNETID2=`aws ec2 describe-subnets --filters "Name=tag:Name,Values=base-azc" | jq -r '.Subnets[].SubnetId'`
```
- ALB作成
```
aws elbv2 create-load-balancer \
--name ALB-ECS \
--subnets ${SUBNETID1} ${SUBNETID2} \
--security-groups ${SGID} \
--scheme internet-facing \
--type application \
--ip-address-type ipv4
```
- リスナー作成 (HTTP)前の変数設定
  - ターゲットグループは”ECABGA”を指定する
```
aws elbv2 create-listener \
--load-balancer-arn $(aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerArn" --output text --names ALB-ECS) \
--protocol HTTP \
--port 80 \
--default-actions Type=forward,TargetGroupArn=$(aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupArn" --output text --name ECSBGA)
```

### ALBからECSに接続許可するセキュリティグループ作成 (CLI)
- ALBからECSクラスタに接続するためにソースがALBからのセキュリティグループが必要なので作成する
 - ”VPCID= ~ ”はハンズオンを行う、VPCIDが１つの場合利用、複数ある環境であれば予めVPCIDを確認しておくこと
```
VPCID=`aws ec2 describe-vpcs | jq -r '.Vpcs[].VpcId'`
aws ec2 create-security-group --group-name SG-ECS --description "ALB to ECS" --vpc-id ${VPCID}
aws ec2 describe-security-groups | jq -r '.SecurityGroups[] | [.GroupName, .GroupId] | @csv'
```
- 作成したグループにインバウンドルールを追加
```
SGID=`aws ec2 describe-security-groups --filters Name=group-name,Values=SG-ECS | jq -r ' .SecurityGroups[].GroupId'`
ALBID=`aws ec2 describe-security-groups --filters Name=group-name,Values=SG-ALB | jq -r ' .SecurityGroups[].GroupId'`
aws ec2 authorize-security-group-ingress --group-id ${SGID} --protocol tcp --port 80 --source-group ${ALBID}
```
- 確認
```
aws ec2 describe-security-groups --filters Name=group-name,Values=SG-ECS | jq -r '.SecurityGroups[].IpPermissions[] | [ .IpProtocol, .ToPort, .UserIdGroupPairs[].GroupId ] |  @csv'
```

---
## ECSクラスタ作成
### IAMロール作成
- ECSからECRにアクセスするためのロールを作成する
- 内容は以下
  - 信頼されたエンティティタイプ　:　AWS のサービス
  - ユースケース　:　Elastic Container Service - Elastic Container Service Task
  - 許可ポリシー  : AmazonECSTaskExecutionRolePolicy
  - ロール名 :  ecsTaskExecutionRole

### ECSクラスタの作成 （CLI）
```
aws ecs create-cluster --cluster-name nginx-cluster
```

### タスク定義作成
- [task.json]ファイルを作成
  - [このファイル](https://github.com/YoichiSoma/sites/blob/main/docs/lab/lab2/2-2/task.json)の内容をコピーしてcloud9に貼り付ける
  - 作成はcloud9かcloud shellが望ましい
  - [sed]コマンドを利用して、変数代入を行うため
- ファイルのアカウントIDを利用しているIDに変換 (CLI)
```
ACCID=`aws sts get-caller-identity --query "Account" --output text`
sed -i "s/account-id/${ACCID}/g" ~/environment/container-test/task.json
```
- タスク登録 (CLI)
```
aws ecs register-task-definition --cli-input-json file://~/environment/container-test/task.json
```

### service 登録
- [service.json]を作成する
- [このファイル](https://github.com/YoichiSoma/sites/blob/main/docs/lab/lab2/2-2/service.json)の内容をコピーしてcloud9に貼り付ける
- 各変数に値を設定 (CLI)
```
SGID=`aws ec2 describe-security-groups --filters Name=group-name,Values=SG-ECS-TEST --query "SecurityGroups[].GroupId" --output text`
SUBNETID1=`aws ec2 describe-subnets --filters "Name=tag:Name,Values=base-aza" | jq -r '.Subnets[].SubnetId'`
SUBNETID2=`aws ec2 describe-subnets --filters "Name=tag:Name,Values=base-azc" | jq -r '.Subnets[].SubnetId'`
TGID=`aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupArn" --output text --name ECSTSBGA`

sed -i "s/SGID/${SGID}/g" ~/environment/container-test/service.json
sed -i "s/SUBNETID1/${SUBNETID1}/g" ~/environment/container-test/service.json
sed -i "s/SUBNETID2/${SUBNETID2}/g" ~/environment/container-test/service.json
※ ターゲットグループARNはスラッシュが入っているのでsedで置換できないため、viかcloud9のエディタで編集するm()m

aws ecs create-service --cli-input-json file://~/environment/container-test/service.json
```

### 確認
- コンソールから クラスタ > 作成したクラスタ名 > サービス > 作成したサービス名 > ネットワーキングを表示し、DNS名をクリックしてコンテナの内容が表示されることを確認する
- 以下コマンドでも確認可能 (CLI)
```
aws elbv2 describe-load-balancers --query "LoadBalancers[].DNSName" --output text
curl ALB-ECS-1076678729.ap-northeast-1.elb.amazonaws.com
```
