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
      - ELBやRDS等オートスケールで拡張するサービスを利用する場合は特に注意！
      - IPアドレスは １〜３、255である  
      - [参考](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/subnet-sizing.html)
   
- [InternetGateway](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/VPC_Internet_Gateway.html)
   - VPC とインターネットとの間の通信を可能にする VPC コンポーネント
   - これがないとVPCからインターネットに出ることができない
   - 作成をしたら明示的にVPCにアタッチするのとこのあと説明するルートテーブルで指定する必要がある 

- [RouteTable](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/VPC_Route_Tables.html)
   - サブネットまたはゲートウェイからのネットワークトラフィックの経路を判断する、ルートと呼ばれる一連のルール
   - サブネットはここに関連付けを行わないとサブネット間での通信はできない
   - 外部に通信する場合はインターネットゲートウェイやNATゲートウェイをルートテーブルで指定する必要がある
   - 概要図に記載の[Router]は暗黙的なものであるため設計や作成をする必要はない

- [NatGateway](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/vpc-nat-gateway.html)
   - プライベートIPしか付与してないEC2等が外に通信するために必要なゲートウェイ
   - NatGatewayはパブリックサブネットに設置され、付与されたElasticIPでインターネットゲートウェイから外部に通信を行う。
   - NatGatewayを利用しなくてもパブリックサブネット上にNat処理を行うサーバを用意すれば外部への通信は可能である
 
---
## VPC設計のポイントまとめ
- VPCは小さく作りすぎない
- NW設計は他ネットワークと接続することを考慮し、既存NWとかぶらないレンジを利用する
- サブネットは最低２つ必要
   - 冗長化を考慮する必要がない場合は１つでも良いが、設計は必ず２つ以上のaz違いのサブネットを用意する
   - また小さくしすぎない
- インターネットゲートウェイは明示的にVPCにアタッチする必要がある
- ルートテーブルを作成したらサブネットの関連付けとインターネット向けのテーブル作成を忘れずに！

---

次へ
