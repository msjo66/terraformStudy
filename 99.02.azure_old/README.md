### 기존에 만들어 놓은 azure resource를 tf로 import 해오기

1. 기존 azure resource의 state를 저장해 놓을 곳을 azure storage account에 준비한다.
```
az group create -l koreacentral -n rg-tfstate #rg-tfstate == resourcegroup-terraform-state
az storage account create -n msjo66sttfstateimport -g rg-tfstate #sttfstateimport == storage-terraform-state-import
az storage container create -n tfstate --account-name msjo66sttfstateimport # tfstate == terraform-state
```

2. import 해와야 할 azure resource를 조사한다. (이름, 종류, id)
```
az resource list --resource-group kt-cn-edu-rg --query "[].{name:name resourceGroup:resourceGroup type:type id:id}"

[
  {
    "id": "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/virtualNetworks/VNet1",
    "name": "VNet1",
    "resourceGroup": "kt-cn-edu-rg",
    "type": "Microsoft.Network/virtualNetworks"
  },
  {
    "id": "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/routeTables/VNet1-route-table",
    "name": "VNet1-route-table",
    "resourceGroup": "kt-cn-edu-rg",
    "type": "Microsoft.Network/routeTables"
  }
]
```

3. azure exporter [설치](https://github.com/Azure/aztfexport/releases)
```
brew install aztfexport
```

4. terraform export 실행
```
aztfexport resource-group <그룹명>

# 찾은 리소스가 쭉 나온다. 여기서 화살표키를 이용해 선택한 후(엔터), 변수명을 제대로 기입한다. 그리고 끝나면 's(Save)' 후 'w(Export)' 하면 main.tf와 export 해 온 resource들이 aztfexportResourceMapping.json 으로 나온다.
```

5. 위 값들을 참조해서 main.tf를 확실히 검토한 후