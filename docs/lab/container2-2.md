# lab2-2 ECSクラスタ作成とBlue/Greenデプロイ
[lab2-1](container2-1.md)でコンテナイメージの準備まで行った。    
次にECSクラスタを作成し、作成したイメージをクラスタにデプロイするところまでやってみる。

---
## 前準備

---
## ALB作成
### ALBに設定するセキュリティグループの作成
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

### ターゲットグループ作成
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

### ALB作成
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
  - [こののファイル](https://github.com/YoichiSoma/sites/blob/main/docs/lab/lab2/2-2/task.json)の内容をコピーしてcloud9に貼り付ける
  - 作成はcloud9かcloud shellが望ましい
  - [sed]コマンドを利用して、変数代入を行うため
- ファイルのアカウントIDを利用しているIDに変換
```
ACCID=`aws sts get-caller-identity --query "Account" --output text`
sed -i "s/account-id/${ACCID}/g" ~/environment/container-test/task.json
```
- タスク登録
```
aws ecs register-task-definition --cli-input-json file://~/environment/container-test/task.json
```

