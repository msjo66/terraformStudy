

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