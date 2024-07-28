# 내가 만드는 모듈 작성 방식

[AVM(Azure Verified Module)](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/)에서 잘 만들어서 재사용 가능한 테라폼 모듈이 있다. 이 모듈들을 우리의 환경과 좀 더 알맞게 사용하기 위해 대충 [데코레이터 패턴](https://gmlwjd9405.github.io/2018/07/09/decorator-pattern.html)으로 만들어야 하지 않을까 해서 이렇게 샘플로 한 번 만들어 봤다.
  가짜 개발자이다 보니 제대로 만드는 것인 지도 모르겠고, 데코레이터 패턴인 지도 모르겠지만 AVM의 모듈을 고칠 능력은 없고 하지만 우리 환경에 맞게 뭔가 좀 기능을 단순화 하거나 추가하려고 하면 이런 식으로 구조를 만들어서 차차 기능을 개선/추가 하면 되지 않을까 생각된다.

[kt-vnet](./kt-vnet/)을 보면 아래와 같은 구조로 되어 있다.
```
kt-vnet
├── main.tf
├── output.tf
├── sample.tfvars
├── sample.tfvars.sample
└── variables.tf
```
다른 사람들의 테라폼 코드 파일 구조는 main.tf, provider.tf, terraform.tf, variables.tf, output.tf 로 구성으로 되어 있는 것을 볼 수 있다. 하지만 여기서는 provider와 terraform을 간단하게 main.tf로 merge시켰다. 사용자가 집중해야할 파일은 인풋과 아웃풋에 대한 설명인 variables.tf와 output.tf이기 때문이다.

sample.tfvars는 module을 작성할 때의 테스트용으로 사용한 파일이다. tfvars 파일에는 민감 정보가 들어 있을 수 있기 때문에 .gitignore에 포함되어 있다. 따라서 사용자가 알기 쉽도록 sample.tfvars.sample과 같이 샘플 tfvars를 만들어 주고, 이 파일에 민감 정보가 없도록 하여 사용자가 사용하기 쉽도록 설명을 해 주자.