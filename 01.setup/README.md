## 이 실습의 목표 : Azure Resource 관리를 위한 Terraform 환경 만들기
1. Terraform의 state는 중요하며, 협업을 위해 공유되어야 하기 때문에 Azure의 Blob Store를 이용하기로 한다.
2. Subscription 하위의 모든 Azure Resource는 Terraform으로 관리되어야 한다.
3. Terraform Machine자체도 Azure Resource로써 관리되어야 한다.

대략적으로 아래와 같은 모양을 목표로 한다.
![](./Terraform%20샘플%20환경.drawio.png)

이 예제가 생각보다 복잡한 이유는 아래와 같다.
- Terraform으로 Azure Resource를 관리하려고 하는데, Terraform Machine과 State 공유 저장소 모두 Azure Resource의 일부이다. 따라서 닭과 달걀의 문제가 있다.
- 보안을 신경쓰지 않도록 하기 위해 Terraform Machine이 안전한 곳에서 실행될 수 있도록 관리하는 Azure Subscription내에 들어가려고 한다.

기본 개념
- Tenant : 간단하게 말하면 Azure Active Directory(혹은 EntraID) 인스턴스 하나를 말한다. 여기에 App, 사용자, 그룹, 권한 등의 정보가 담겨있다.
- Subscription : 리소스, 서비스를 만들고 설치할 수 있는 논리적인 컨테이너. 비용관리의 단위이다. 하나의 Subscription은 하나의 Tenant에 속한다.
여기서 terraform 으로 관리하는 범위는 Subscription내에 있는 'Resource Group'과 그 하위 리소스들이다.

```
az>> az account list
[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "0000-0000-0000-2222-0000",
    "id": "0000-000-00-000-00000000000",
    "isDefault": true,
    "managedByTenants": [],
    "name": "Helloworld Subscription",
    "state": "Enabled",
    "tenantDefaultDomain": "minsoojogmail.onmicrosoft.com",
    "tenantDisplayName": "기본 디렉터리",
    "tenantId": "0000-0000-0000-2222-0000",
    "user": {
      "name": "xxxxx@gmail.com",
      "type": "user"
    }
  }
]
az>> az account subscription list
[
  {
    "authorizationSource": "RoleBased",
    "displayName": "Helloworld Subscription",
    "id": "/subscriptions/0000-000000-0000000000000000000-0000-00000000000",
    "state": "Enabled",
    "subscriptionId": "0000-000000-0000000000000000000-0000-00000000000",
    "subscriptionPolicies": {
      "locationPlacementId": "Public_2014-09-01",
      "quotaId": "PayAsYouGo_2014-09-01",
      "spendingLimit": "Off"
    }
  }
]
```

위 3가지 목표를 달성하기 위해서는 아래와 같은 절차로 진행했다.(꼭 이 방법 말고 다른 방법도 있을 수 있다)

1. 최초 개발자 환경에 terraform과 azure cli를 setup 한다.
  - [Terraform 설치](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/install-cli)
  - [azure cli 설치](https://learn.microsoft.com/ko-kr/cli/azure/install-azure-cli)
2. 개발자 환경에서 Azure내에 Terraform Machine이 실행될 수 있는 환경을 Terraform을 이용해서 provision한다. 그 이후 이 machine에 접속해서 machine을 terraform이 실행될 수 있도록 구성한다(구성하는 것도 terraform을 이용해서 할 수 있다. 다음에 하는 걸로..)
  이 Terraform machine의 요구사항은 아래와 같다.
  - terraform이 azure resource를 만들 때 권한이 있는 user(identity)를 관리할 필요가 없도록 Managed System Identity를 이용한다.
  - Machine이 기동된 이후 aztfexport, az cli, terraform이 설치되어 있어야 한다.
  - IaC Source를 pull해올 수 있도록 git도 필요하다.
3. 2번까지의 작업(azure에 machine을 provision)한 state가 개발자 local pc에 저장되어 있으므로 협업을 위해 공유되어 있지 않다. 따라서, 4번 수행
4. 아래의 export/import하는 작업을 Terraform Machine에서 수행한다.
5. export/import 수행 후, Terraform Machine에서 환경변수 3개를 설정한 후 테스트해 본다.(az logout)
  - ARM_TENANT_ID=\<tenant id\>
  - ARM_SUBSCRIPTION_ID=\<subscription id\>
  - ARM_USE_MSI=true
6. 작업한 내용을 다시 git에 push하여 동기화 시켜야 한다. 그 이후 main.tf의 내용을 refactoring할 필요가 있다(변수, 데이타, 아웃풋 등)


### Terraform 없이 해왔던 부분을 import해서 거기서 부터 시작하기

1. [aztfexport](https://github.com/Azure/aztfexport/releases)를 이용해 기존 것 import해오기
```
aztfexport resource-group <그룹명>
#  각 resource에 대한 변수 매핑을 위해서 화살표 키로 아래위로 움직이면서 변수명을 적절하게 수정한다.
# s를 통해 저장한 후 w를 통해 import한다.
```
2. state 저장소를 azure storage account로 바꾸기
  아래와 같은 명령을 통해 state를 저장할 컨테이너 만들기(위에서는 terraform을 통해서 미리 생성했으므로 생략)
```
az group create -l koreacentral -n <리소스 그룹 명> 
az storage account create -n <스토리지 어카운트 명> -g <리소스 그룹 명>  
az storage container create -n <컨테이너명> --account-name <스토리지 어카운트 명>>
```
3. import를 통해 생성된 terraform.tf에서 backend를 azure storage로 바꾸기
```
terraform {
  backend "azurerm" {
    container_name       = "<컨테이너명>"
    key                  = "<state 파일 키>" #blob file 명
    resource_group_name  = "<리소스그룹명>"
    storage_account_name = "<스토리지 어카운트 명>"
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.99.0"

    }
  }
}
```
4. state 저장소 migration 하기
```
terraform init -migrate-state
```
5. apply를 통해 state를 저장하기
```
terraform apply
```



## 뭐든지 시작은 보안/Identity 부터..
네트워크 보안으로 뚫리는 경우보다는 허술한 Identity관리(암호)로 뚫리는 경우가 훨씬 많다.
Azure에는 3가지 종류의 Identity가 있다. 일반적으로 '사람'이 portal.azure.com 같은 곳에서 interactive하게 접근하는 'User', 'Service Principal', 그리고 'Managed Identity'가 있다. '자동화'를 위해서라면 'User'를 사용하는 것은 지양해야 한다. 'User'는 개발자 PC에서 공부하는 용도로 사용하는 것으로 끝나야 한다. 'Service Principal'은 간단하게 말하면 DB Connection Pool에다가 넣는 user를 말한다. 이것은 실제 user가 아니라 WAS라는 '서비스'가 사용하는 'Principal'이다. User혹은 'Service Principal'은 당연히 접근을 위해서는 '자격증명'이 있어야 된다. 가장 흔한 자격증명이 id/password 조합이고, 그 다음이 id/secret 혹은 access key/secret이다. 그 다음으로는 '인증서'가 있겠다. OAuth에서 나온 'access token, refresh token'은 '자격증명'인가? 당연히 아니다. 이 token은 Client(Service Provider)가 Authorization Server에다가 자격 증명을 제출해서 받아낸 '암행어사의 마패'이다. 마패에는 '이름'이 쓰여져 있지 않다. 다만 '마패를 가진 사람은 말을 빌릴 수 있다' 라는 권한만 있을 뿐이다.
- Managed Identity : 개발자들이 Secret, credential, certificate, key라는 단어를 싫어하고, 관리하기를 귀찮아하고, 그 결과로 뚫린다(뚫린다는 것을 구체적으로 말하면 userid/password 조합 혹은 access key/secret 조합을 말한다. 이 두 가지 조합을 주로 '자격증명' 이라고 말한다. 물론 또다른 종류의 token이나 인증서 같은 것도 자격증명이다). 이를 좀 보완해 주기 위해서, 즉 개발자가 크게 신경을 쓰지 않도록 하기 위해서 MS에서 만든 Identity의 종류이다. 
'개발'의 관점에서 Managed Identity가 나왔기 때문에 개발자의 문장으로 요구사항을 설명해 보면, '내가 App을 만들 건데, 이 App은 Azure의 VM, App Service, Container, Function, AKS 등을 사용한다. 이 각종 서비스가 또다른 Azure의 서비스들인 각종 API, KeyVault, Storage, SQL, CosmosDB 와 같은 서비스에 접근을 해야 되는데.. 이 때 그냥 접근을 할 수 없으니까 여기서 각 소스 서비스들이 타겟 서비스에 접근하기 위한 자격 증명이 필요하다. 그런데 이 자격 증명들을 관리하기가 너무 귀찮다' 이다. 실제로는 Managed Identity는 'Service Principal'을 좀 더 관리하기 쉽게 만든 것이다.
    1. portal.azure.com에서 'Managed Identity'를 만든다.(이렇게 만드는 것을 User Assigned Managed Identity라고 한다.)
    2. SP이기 때문에 살펴보면 'Client ID'라는 정보가 있다. 이 SP에는 어떠한 암호/token 같은 것은 없다. 
    3. 접근을 당할 서비스(Storage Account, AKS등)로 들어가서 IAM 항목에서 'create role assignment'를 눌러서 적당한 Role을 assign한다.
    4. 접근을 할 서비스에다가 Managed Identity를 부여한다. 그러면 접근할 서비스는 접근당할 서비스에대해 RBAC으로 권한을 획득한 것이다.

