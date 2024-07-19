terraform {
  required_version = "> 1.3.0" # 물결표시는 가장 자리수가 낮은 부분에 대해서라는 뜻. 따라서 ~> 1.3.0은 1.3.x는 허용한다는 뜻

  cloud {
    hostname = "app.terraform.io"
    organization = "msjo66-helloworld"
    workspaces {
      name = "terraformStudy"
    }
  }
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">= 3.0.0"
    }

    local = {
        source = "hashicorp/local"
        version = ">=2.0.0"
    }
  }
}
resource "local_file" "abc" {
  content         = "abc!"
  filename        = "${path.module}/abc.txt"
  file_permission = "0600"
}

resource "local_file" "def" {
  filename = "${path.module}/def.txt"
  content = "def!"
}