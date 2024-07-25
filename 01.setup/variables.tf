variable "geography" {
    description = "배포할 대상 리전이 있는 지역"
    default = "Korea"
}

variable "tf-state-info" {
    description = "Terraform State 공유를 위한 Storage Account가 있는 resource group"
    type = map(string)
    default = {
        rg-name=""
        account-name=""
        container-name=""
        account-tier="Standard"
        account-replication-type="LRS"
    }
}