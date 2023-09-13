az login
az group create --name nghDemo --location "East US"
az deployment group create --resource-group nghDemo --template-file ./nhg_infra.bicep
az storage blob service-properties update --account-name mystorageaccountgreen --static-website --404-document error.html --index-document index.html
az storage blob service-properties update --account-name mystorageaccountblue --static-website --404-document error.html --index-document index.html
az deployment group create --resource-group nghDemo --template-file ./frontdoor.bicep
