# AWSの基本
- 基本的な考え方を説明

## 参考URL
- [AWS VPC](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/what-is-amazon-vpc.html)
- [AWS EC2](https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/concepts.html)

## ec2を使いたい
- ec2を起動する場合、まずはNW設計が必要である。   
- AWSの場合、新規アカウントであればデフォルトでNWが設定されているのでそのまま使うことも可能だが案件の場合ある程度設定をしておく必要がある。   
- 最低限の設計について説明する。

## NW概要
- AWSのネットワークを設計する際に必要な要素をまとめてみた   
   <img src="https://user-images.githubusercontent.com/125415634/231362383-a49f99ce-6754-4a93-a857-95d48e1ffd97.png" width="400px">

## 要素説明
- [リージョン(Region)](https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/using-regions-availability-zones.html)
   - 地理的にはなれば場所
   - 国内であれば”ap-northeast-1（東京）”でOK
   - 大阪（ap-northeast-3）もあるが、よほどDR案件でなければ選択する必要はない
      - ※ 大阪リージョンで使えない機能もあるので
- アベイラビリティゾーン( Availability Zones)
   - リージョン内の独立したデータセンタロケーション
      - [ここ](https://dev.classmethod.jp/articles/server_2_resion/)にわかりやすい説明がある
   - 大体は”AZ”（エーゼット）と約して説明することが多い
   - 東京リージョンでは以下の３つが現在利用可能
       - ap-northeast-1a
       - ap-northeast-1c
       - ap-northeast-1d
   - ※昔はbがあったらしいが、現在はない
   - アベイラビリティゾーンは以下のAWSコマンドでも調べることができる
     ```
     aws ec2 describe-availability-zones --region ap-northeast-1
     ```
- [VPC](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/what-is-amazon-vpc.html)
   - 仮想ネットワーク、オンプレミスの自社NWと考えるといいかも
   - アカウントID内にいくつでも作成することは可能だがプロダクション環境で利用する場合はアカウント毎に分けたほうが望ましい
   - VPCでCIDR ブロックを指定する
   - 段階でオンプレミスや他クラウドと接続する予定がある場合を考慮し、ユーザにヒアリングをしておく
   - 最小で/28ネットマスクで設計できるが小さすぎると将来的な拡張性や、ELBやRDS等拡張性のあるサービスに影響が出るため余裕を持った設計にすること
     - 個人的には/16ぐらいだとこのあと説明するサブネットの設計がやりやすい
   - [ここ](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/vpc-cidr-blocks.html#add-cidr-block-restrictions)に詳しい説明がある

- [Subnet](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/configure-subnets.html)
   - VPC内でネットワークを分けるためのIPアドレス範囲
   - サブネットはAZをまたぐ設計はできないため、AZごとに指定が必要
   - サブネットには２つの種類がある
      -  PublicSubnet
         - インターネットに直接出れるネットワーク
         - インタネットに直接出る必要のあるec2やelb等を設置する場所     
      -  PrivateSubnet 
         - VPC内やオンプレミスや他クラウドのプライベートネットワークのみで通信するネットワーク
         - DBサーバやキャッシュサーバ、バッチサーバ等を設置する場所
         - NAT処理を行うサーバやNATゲートウェイを経由すればインターネットに出ることは可能である
      - ※厳密にはもう１つ（VPCのみのサブネット）あるがここは考慮する必要はない
   - 設定する場合にパブリックサブネットやプライベートサブネットという指定項目はない
   - サブネットも最小/28で指定はできるが特定のIPアドレスは利用できないため、小さくても/25ぐらいまでの大きさにしておくのが望ましい
      - [参考](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/subnet-sizing.html)
   
