### Stroage Account를 만들었을 때 함께 생성되는 것들

1. storage account "a2pcpstgacct01" : 만들고자 하는 storage account
2. private endpoint "pe-a2pcpstgacct01" : Azure Storage Account 서비스가 내부적으로 privatelink를 가지고 있으니 이를 사용하기 위해 consumer쪽에서 만들어야 하는 endpoint
    - pe를 위한 Nic "pe-a2pcpstgacct01.nic.a02f7911-3e84-45b2-b55b-0f2e59c922cf" : pe의 정체는 network interface 이며 이것이 private DNS zone에 연결이 되어야 하기 때문에 nic가 만들어짐. 그런데 이 nic는 pe에 composition 관계로 붙어 있기 때문에 이름을 우리가 원하는 대로 정할 수 없음. pe를 만들고 난 결과로 나오게 됨(terraform의 argument가 아니라 attribute임)
    - dns configuration : 
                    Customer visible 영역에 위 Nic와, ip, 그리고 fqdn (a2pcpstgacct.blob.core.windows.net) 이 설정되어 있음
                    Custom DNS records 영역에 위 fqdn과 ip가 있음
3. private dns zone "privatelink.blob.core.windows.net"
4. private DNS zone을 vnet에 붙이기 위한 vnet link "pdns-to-vnet01"
5. private dns zone에 A record 하나 생성됨 "a2pcpstgacct.privatelink.blob.core.windows.net"

### Terraform module을 만든 절차

1. gui에서 storage account를 생성한다.
    - 생성할 때 private access만 선택하여 만들었음
2. aztfexport를 이용해 같이 만들어지는 resource를 모두 export한다.
3. main.tf를 보고 재사용을 위한 입력값을 위한 variables.tf를 만든다.
4. main.tf에 있는 실제 값들을 variables.tf에 맞춰서 sample.tfvars를 만든다.
5. gui에서 만든 것들을 삭제하고 실제로 terraform을 이용해서 만들어 지는 지 확인한다.
6. 제대로 만들어 졌으면 tfstate및 aztfexport와 관련된 쓰레기를 정리한다.
7. module 이름을 정한다.
8. module 폴더를 module root folder로 옮긴다.
9. 사용한다.