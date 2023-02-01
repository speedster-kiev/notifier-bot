terraform {
  cloud {
    organization = "terraformftw"

    workspaces {
      name = "bot_name"
    }
  }
}