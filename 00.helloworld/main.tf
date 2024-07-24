terraform {
  required_version = "> 1.3.0" # 물결표시는 가장 자리수가 낮은 부분에 대해서라는 뜻. 따라서 ~> 1.3.0은 1.3.x는 허용한다는 뜻

  # cloud {
  #   hostname = "app.terraform.io"
  #   organization = "msjo66-helloworld"
  #   workspaces {
  #     name = "terraformStudy"
  #   }
  # }

  backend "local" {
    path = "state/terraform.tfstate"
  }

  required_providers {
    local = {
        source = "hashicorp/local"
        version = ">=2.0.0"
    }
  }
}

# variable "names" {
#   type = list(string)
#   default = [ "a","b","c" ]
# }

# resource "local_file" "abc" {
#   count = length(var.names)
#   content = "abc"
#   filename = "${path.module}/abc-${var.names[count.index]}" 
# }

# resource "local_file" "def" {
#   count = length(var.names)
#   content = local_file.abc[count.index].content

#   filename = "${path.module}/def-${element(var.names, count.index)}.txt"
  
# }

### for 문 테스트
# variable "names1" {
#   type = list(string)
#   default = [ "a","b","c" ]
# }

# output "A_upper_value" {
#   value = [for v in var.names1: upper(v)]
# }
# output "B_index_and_value" {
#   value = [for i,v in var.names1: "${i} is ${v}"]
# }
# output "C_make_object" {
#   value = {for v in var.names1: v=> upper(v)}
# }
# output "D_with_filter" {
#   value = [for v in var.names1: upper(v) if v!= "a"]
# }

resource "local_file" "b" {
  filename = "${path.module}/foo.bar"
  content = "foo!"
  
}

moved {
  from = local_file.a
  to = local_file.b
}

output "file_content" {
  value = local_file.b.content
  
}