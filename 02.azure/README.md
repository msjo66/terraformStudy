## 뭐든지 시작은 보안/Identity 부터..
네트워크 보안으로 뚫리는 경우보다는 허술한 Identity관리(암호)로 뚫리는 경우가 훨씬 많다.
Azure에는 3가지 종류의 Identity가 있다. 일반적으로 '사람'이 portal.azure.com 같은 곳에서 interactive하게 접근하는 'User', 'Service Principal', 그리고 'Managed Identity'가 있다. '자동화'를 위해서라면 'User'를 사용하는 것은 지양해야 한다. 'User'는 개발자 PC에서 공부하는 용도로 사용하는 것으로 끝나야 한다. 'Service Principal'은 간단하게 말하면 DB Connection Pool에다가 넣는 user를 말한다. 이것은 실제 user가 아니라 WAS라는 '서비스'가 사용하는 'Principal'이다. User혹은 'Service Principal'은 당연히 접근을 위해서는 '자격증명'이 있어야 된다. 가장 흔한 자격증명이 id/password 조합이고, 그 다음이 id/secret 혹은 access key/secret이다. 그 다음으로는 '인증서'가 있겠다. OAuth에서 나온 'access token, refresh token'은 '자격증명'인가? 당연히 아니다. 이 token은 Client(Service Provider)가 Authorization Server에다가 자격 증명을 제출해서 받아낸 '암행어사의 마패'이다. 마패에는 '이름'이 쓰여져 있지 않다. 다만 '마패를 가진 사람은 말을 빌릴 수 있다' 라는 권한만 있을 뿐이다.
- Managed Identity : 개발자들이 Secret, credential, certificate, key라는 단어를 싫어하고, 관리하기를 귀찮아하고, 그 결과로 뚫린다(뚫린다는 것을 구체적으로 말하면 userid/password 조합 혹은 access key/secret 조합을 말한다. 이 두 가지 조합을 주로 '자격증명' 이라고 말한다. 물론 또다른 종류의 token이나 인증서 같은 것도 자격증명이다). 이를 좀 보완해 주기 위해서, 즉 개발자가 크게 신경을 쓰지 않도록 하기 위해서 MS에서 만든 Identity의 종류이다. 
'개발'의 관점에서 Managed Identity가 나왔기 때문에 개발자의 문장으로 요구사항을 설명해 보면, '내가 App을 만들 건데, 이 App은 Azure의 VM, App Service, Container, Function, AKS 등을 사용한다. 이 각종 서비스가 또다른 Azure의 서비스들인 각종 API, KeyVault, Storage, SQL, CosmosDB 와 같은 서비스에 접근을 해야 되는데.. 이 때 그냥 접근을 할 수 없으니까 여기서 각 소스 서비스들이 타겟 서비스에 접근하기 위한 자격 증명이 필요하다. 그런데 이 자격 증명들을 관리하기가 너무 귀찮다' 이다. 실제로는 Managed Identity는 'Service Principal'을 좀 더 관리하기 쉽게 만든 것이다.
    1. portal.azure.com에서 'Managed Identity'를 만든다.(이렇게 만드는 것을 User Assigned Managed Identity라고 한다.)
    2. SP이기 때문에 살펴보면 'Client ID'라는 정보가 있다. 이 SP에는 어떠한 암호/token 같은 것은 없다. 
    3. 접근을 당할 서비스(Storage Account, AKS등)로 들어가서 IAM 항목에서 'create role assignment'를 눌러서 적당한 Role을 assign한다.
    4. 접근을 할 서비스에다가 Managed Identity를 부여한다. 그러면 접근할 서비스는 접근당할 서비스에대해 RBAC으로 권한을 획득한 것이다.

    Managed Identity가 여러면(보안및 사용성)에서 좋지만 모든 서비스가 MI를 지원하지는 않는다. [여기](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/managed-identities-status)를 찾아봐야 함.

여기까지의 내용을 보면, terraform이 Azure Resource들을 관리를 하려면, terraform 실행환경이 azure 내의 리소스여야 한다(즉, 소스가 azure resource여야 한다).


### Terraform 없이 해왔던 부분을 import해서 거기서 부터 시작하기

1. [aztfexport](https://github.com/Azure/aztfexport/releases)를 이용해 기존 것 import해오기
```
aztfexport resource-group <그룹명>
#  각 resource에 대한 변수 매핑을 위해서 화살표 키로 아래위로 움직이면서 변수명을 적절하게 수정한다.
# s를 통해 저장한 후 w를 통해 import한다.
```
2. state 저장소를 azure storage account로 바꾸기
  아래와 같은 명령을 통해 state를 저장할 컨테이너 만들기
```
#rg-tfstate == resourcegroup-terraform-state
az group create -l koreacentral -n rg-tfstate 
az storage account create -n msjo66sttfstateimport -g rg-tfstate 
#sttfstateimport == storage-terraform-state-import
az storage container create -n tfstate --account-name msjo66sttfstateimport
```
3. import를 통해 생성된 terraform.tf에서 backend를 azure storage로 바꾸기
```
terraform {
  backend "azurerm" {
    container_name       = "tfstate"
    key                  = "myIaC" #blob file 명
    resource_group_name  = "rg-tfstate"
    storage_account_name = "msjo66sttfstateimport"
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

### Terraform의 resource 항목내의 lifecycle(수명주기)는 많이 써먹을 듯 하다.
- create_before_destroy : 삭제하기 전에 먼저 생성한 후 replace. 파일 같은 것은 이렇게 하면 마지막에는 결국 지워져 버림.
- prevent_destroy : 파일 같은 것은 지우고 새로 만들기 때문에 이게 설정이 되어 있으면서 resource를 수정하게 되면 오류가 발생함
- ignore_changes : resource에 대해서 여러가지 수정을 했지만, 실제로 어떤 부분은 바꾸지 않기를 바라는 경우가 있다. 그 인수 여기에 나열하면 됨
- precondition/postcondition
```
resource "local_file" "abc" {
    content = "lifecycle test -step 4" # 수정된 부분
    lifecycle {
        ignore_changes = [
            content
        ]
    }
}
```
이렇게 하면 변경이 되지 않는다. (하지만 이렇게 ignore_change를 하게 되는 것이 IaC라는 관점에서 맞나? 이미 code와 타겟의 상태가 여기서부터 어긋나기 시작하는 것 아닌가?)

```
variable "file_name" {
    default = "step0.txt"
}

resource "local_file" "step6" {
    content = "lifecycle = step 6"
    filename = "${path.module}/${var.file_name}

    lifecycle {
        precondition {
            condition = var.file_name == "step6.txt"
            error_message = "file name is not \"step6.txt\""
        }
    }
}
```