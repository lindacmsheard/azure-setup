# About

Configure a blank subscription with the basics
- a utility storage account to enable terraform backend management in azure - created manually
- a resource group with storage account and data lake - created with terraform.



## Set defaults
```
az config set defaults.location=uksouth
```

## Manually created

### util rg
```
 az group create -n util --tags creationSource=manual
```

### utilstorage

```
az storage account create -g util -n lcmgutilstorage --tags creationSource=manual --sku Standard_LRS
```

### terraform container

```
az storage container create  --account-name lcmgutilstorage -n terraform --auth-mode login
```

## run terraform
```
terraform init -backend-config=./main-backend.tfvars
```

```
terraform plan
//-> review

terraform apply
```