- AWSアカウントのデフォルトで有効になっているリージョンのすべてのVPC（サブネット、IGW）を削除する
- 下記の内容をAWS CLIが利用できる環境(CloudShell等）に貼り付ければ実行できる。
- すでに削除されている場合はスキップしてくれる。
```
aws --output text ec2 describe-regions --query "Regions[].[RegionName]" \
| while read region; do
  aws --region ${region} --output text \
    ec2 describe-vpcs --query "Vpcs[?IsDefault].[VpcId]" \
  | while read vpc; do
    echo "# deleting vpc: ${vpc} in ${region}"
   
    ### IGW
    aws --region ${region} --output text \
      ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=${vpc} \
      --query "InternetGateways[].[InternetGatewayId]" \
    | while read igw; do
      echo "## deleting igw: ${igw} in ${vpc}, ${region}"
      echo "--> detatching"
      aws --region ${region} --output json \
        ec2 detach-internet-gateway --internet-gateway-id ${igw} --vpc-id ${vpc}
      echo "--> deleteing"
      aws --region ${region} --output json \
        ec2 delete-internet-gateway --internet-gateway-id ${igw}
    done
   
    ### Subnet
    aws --region ${region} --output text \
      ec2 describe-subnets  --filters Name=vpc-id,Values=${vpc} \
      --query "Subnets[].[SubnetId]" \
    | while read subnet; do
      echo "## deleting subnet: ${subnet} in ${vpc}, ${region}"
      aws --region ${region} --output json \
        ec2 delete-subnet --subnet-id ${subnet}
    done
   
    ### VPC
    echo "## finally, deleting vpc: ${vpc} in ${region}"
    aws --region ${region} --output json \
      ec2 delete-vpc --vpc-id ${vpc}  
  done
done
```
