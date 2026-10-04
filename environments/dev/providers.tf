terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
   resource_group_name  = "demo_rg"
   storage_account_name = "demostg1344"
   container_name       = "democ"
   key                  = "dev.tfstate"
  }
}

provider "azurerm" {
  features {}
}
