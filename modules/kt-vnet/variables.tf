# variable "geography" {
#     description = "배포할 대상 리전이 있는 지역"
#     default = "Korea"
# }
variable "resource_group_name" {}
variable "location" {}
variable "vnet_name" {}
variable "address_space" {
    type = list(string)
}
variable "subnets" {
    type = map(object({
      name = string
      address_prefixes = list(string)
    }))
}