# AWS RI(预留实例)&SP(节省计划)

# 一、[**预留实例**（RI）](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/ec2-reserved-instances.html)

相比按需型实例定价，预留实例可大幅节约您的 Amazon EC2 成本。预留实例不是物理实例，而是对账户中使用的按需型实例所应用的账单折扣。这些按需型实例必须与特定属性（例如实例类型和区域）匹配才能享受账单折扣

**标准预留实例**

    与按需实例的定价相比，标准预留实例可为您提供大幅折扣（最高可达 72%），并能按 1 年或 3 年的使用期进行购买。客户能够灵活地更改其标准预留实例的可用区、实例大小以及联网类型。

### 1.1. [**实例大小的支持**](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/ri-modifying.html#ri-modification-instancemove)

每个Reserved Instance都有_实例大小占用空间_，该空间由预留中实例大小的标准化因子和实例数量决定。只要预留的实例大小占用空间保持不变，您就可以将预留分配给相同实例系列中的不同实例大小。

|  **实例大小**  |  **标准化因子**  |
| --- | --- |
|  nano  |  0.25  |
|  micro  |  0.5  |
|  small  |  1  |
|  medium  |  2  |
|  large  |  4  |
|  xlarge  |  8  |
|  2xlarge  |  16  |
|  3xlarge  |  24  |
|  4xlarge  |  32  |
|  ……  |  ……  |

在以下示例中，您有 1 个具有 2 个 t2.micro 实例（1 个单位）的预留和 1 个具有 1 个 t2.small 实例（1 个单位）的预留。如果您将这些预留合并到具有 1 个 t2.medium 实例（2 个单位）的单个预留中，则新预留的占用空间等于合并预留的占用空间

![image](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/images/ri-modify-merge.png)

您还可以修改预留以将其拆分为多个预留。在以下示例中，您有 1 个具有 t2.medium 实例（2 个单位）的预留。您可以将该预留划分为两个预留，其中之一具有 2 个 t2.nano 实例（.5 个单位），另一个具有 3 个 t2.micro 实例（1.5 个单位）。

![image](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/images/ri-modify-divide.png)

**可转换预留实例**

   如果需要额外的灵活度（例如能够在预留实例有效期内使用不同实例系列、操作系统或租期），请购买可转换预留实例。 与按需实例的定价相比，可转换预留实例可为您提供大幅折扣（最高可达 66%），并能按 1 年或 3 年的有效期进行购买。

### 2.1. [**交换部分 可转换预留实例**](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/ri-convertible-exchange.html#ri-split-convertible)

您可以将一个或多个 可转换预留实例 与具有不同配置的其他 可转换预留实例（包括实例系列、操作系统和租期）进行交换。

在本示例中，您有一个在预留中有四个实例的 t2.micro 可转换预留实例。将两个 t2.micro 实例与一个 m4.xlarge 实例交换：

1.  修改 t2.micro 可转换预留实例，方法为将其拆分为两个 t2.micro 可转换预留实例，每一个都包含两个实例。
    
2.  将其中一个新 t2.micro 可转换预留实例 与一个 m4.xlarge 可转换预留实例 交换。
    

![image](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/images/ri-split-cri-multiple.png)

在本示例中，您拥有一个 t2.large 可转换预留实例。将其更改为一个较小的 t2.medium 实例和一个 m3.medium 实例：

1.  修改 t2.large 可转换预留实例，方法为将其拆分为两个 t2.medium 可转换预留实例。单个 t2.large 实例具有两个 t2.medium 实例相同的实例大小占用空间。
    
2.  将其中一个新 t2.medium 可转换预留实例 与一个 m3.medium 可转换预留实例 交换。
    

![image](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/images/ri-split-cri-single.png)

**参考文档：**

[**预留实例定价表**](https://aws.amazon.com/cn/ec2/pricing/reserved-instances/pricing/)
>与按需实例定价相比，节省计划也可以显著节省您的Amazon EC2成本。有了储蓄计划，您就可以保证一个一致的使用量，以每小时美元计算。这为您提供了使用最能满足您的需求并继续节省资金的实例配置的灵活性，而不是对特定的实例配置做出承诺。有关详细信息，请参阅AWS储蓄计划用户指南。

[RI覆盖率报告](https://docs.aws.amazon.com/zh_cn/cost-management/latest/userguide/ce-default-reports.html#ce-coverage-views)

# 二、[**节省计划（savings plans）**](https://docs.aws.amazon.com/zh_cn/savingsplans/latest/userguide/what-is-savings-plans.html)

[Savings Plans](http://aws.amazon.com/savingsplans/) 是另一种灵活的定价模式，最高可使您节省 72% 的 AWS 计算使用费。这种定价模式为 Amazon EC2 实例的使用提供了更低的价格，而不考虑实例系列、大小、操作系统、租赁或 AWS 区域，同时适用于 AWS Fargate 和 AWS Lambda 的使用。

Savings Plans 与 EC2 预留实例一样，相比按需型实例，能够节省大量成本，以换取在一年或三年内使用特定数量计算能力的承诺（以美元/小时为单位）。您可以注册一年或三年期的 Savings Plans，并利用 AWS Cost Explorer 中的建议、性能报告和预算警报，轻松管理您的计划。

**Compute Savings Plans（计算SP）**

Compute Savings Plans 的灵活性最高，最高可帮助您节省 66% 的费用。这些计划会自动应用于 EC2 实例用量，不分**实例系列**、大小、可用区、区域、操作系统或租期，并且还适用于 Fargate 和 Lambda 的使用。 例如，注册 Compute Savings Plans 后，您可以随时从 C4 实例更改为 M5 实例，将工作负载从欧洲（爱尔兰）区域转移到欧洲（伦敦）区域，或者将工作负载从 EC2 迁移到 Fargate 或 Lambda，并继续自动支付 Savings Plans 价格。

**EC2 Instance Savings Plans (EC2 SP)**

EC2 Instance Savings Plans 可提供最低的价格，最高可提供 72% 的折扣，以换取在**单个区域内**使用单个实例系列的承诺（例如在弗吉尼亚北部区域使用 M5 实例）。这会自动降低您在该区域的选定实例系列成本，不分可用区、实例大小、操作系统或租期。借助 EC2 Instance Savings Plans，您可以灵活地在该区域的一个实例系列中更改实例的使用情况。例如，您可以从运行 Windows 的 c5.xlarge 实例迁移到运行 Linux 的 c5.2xlarge 实例，并自动享受 Savings Plan 价格。

SageMaker Savings Plans

Amazon SageMaker 是一项完全托管的机器学习服务。借 SageMaker助，数据科学家和开发人员可以快速、轻松地构建和训练机器学习模型，然后将模型部署到生产就绪的托管环境中。

**SageMaker储蓄计划**可节省高达按需费率的64％。

**参考文档：**

[Savings Plans定价表](https://aws.amazon.com/cn/savingsplans/compute-pricing/)

[SP覆盖率报告](https://docs.aws.amazon.com/zh_cn/savingsplans/latest/userguide/ce-sp-usingCR.html)

# 三、RI和SP折扣比较

[https://calculator.aws/#/addService/ec2-enhancement](https://calculator.aws/#/addService/ec2-enhancement)

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/meonaApd80wQnXxj/img/bb7c9524-8d55-428c-b43c-eb432339bf45.png)

![image](https://alidocs.oss-cn-zhangjiakou.aliyuncs.com/res/meonaApd80wQnXxj/img/dd3bb181-86c0-40d4-8f6a-2881c6be87c0.png)

标准预留实例 = EC2 Instance Savings Plans

可转换预留实例 = Compute Savings Plans

您可以继续购买 RI 以保持与现有成本管理流程的兼容性，同时您的 RI 将与 Savings Plans 结合来降低您的总体费用。但随着您的 RI 到期，我们建议您注册 Savings Plans，因为这些计划能够提供与 RI 相同的成本节省，同时还具有更高的灵活性。

[Amazon EC2 预留实例和其他 AWS 预留模型](https://docs.aws.amazon.com/zh_cn/whitepapers/latest/cost-optimization-reservation-models/savings-plans.html)

## [**使用Savings Plans计算帐单**](https://docs.aws.amazon.com/zh_cn/savingsplans/latest/userguide/sp-applying.html#calc-bills-sp)

1.  在应用 Amazon EC2 预留实例 (RI) 后，savings plans适用于您的使用量
    
2.  **EC2 实例储蓄计划**在**计算储蓄计划**之前适用，因为**计算储蓄计划**具有更广泛的适用性
    
3.  在_整合账单系列_中，储蓄计划首先应用于所有者账户的使用量，然后应用于其他账户的使用量。只有在启用共享时才会出现这种情况

## 同时购买SP和RI时覆盖率计算
>可按建议购买/续费
 - 10台机器 9台买SP匹配，1台买RI匹配。SP和RI覆盖率都为100% 
 - 10台机器 全买SP匹配，不买RI(不计算覆盖率)。RI覆盖率为0%
 ```
 Savings Plans 覆盖明细(2024-02-27 — 2024-02-27) ：
 服务   实例系列    区域         SP覆盖的支付      按需支出     覆盖率
 EC2	c5	      us-west-2	  US$71.40	       US$59.16	   55%
 ```
 * sp续费计算方式
 ```
 # 以c5.large为参照：0.062(sp费率)  0.085(按需价)
 1. c5系统实例27日一天按需支出$59.16,等于每小时支出（$59.16 % 24 = $2.465）
 2. c5每小时按需支出 除以 c5.large按需价 等于c5.large数量（$2.465 % $0.085 = 29个c5.large）
 3. c5.large的sp费率 * 个数 = 总sp承诺价（ $0.062 * 29 = $1.798）
 c5的sp续订总sp承诺价：$1.798
 ```