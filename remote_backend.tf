terraform {
  cloud {
    organization = "scwlua-test"
    workspaces {
      name = "Terraform-Demo4-NotasComplicatedApp-Networks"
    }
  }
}