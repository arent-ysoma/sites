# lab2-2 ECSクラスタ作成とBlue/Greenデプロイ
[lab2-1](container2-1.md)でコンテナイメージの準備までできた。   
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


