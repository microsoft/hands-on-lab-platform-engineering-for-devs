#/bin/bash

#Set Variables
export LOCATION="westeurope"
RANDOM_NUMBER=$(shuf -i 10000-99999 -n 1)
export DEVCENTER_NAME="mydevcenter-"$RANDOM_NUMBER
export RESOURCE_GROUP="rg-plateng-for-devs"
export SUBSCRIPTION_ID="XXXXXXXX"
export PROJECT_NAME="frontend-project"
export KV_NAME="kv"$RANDOM_NUMBER
export REPO_URL="https://github.com/ikhemissi/hands-on-lab-platform-engineering-for-devs.git"
export PAT_TOKEN="github_pat_11ABTRVVY0nOXfkwMj8sy9XXXX" # read-only one one repo containing the devcenter folder with ADE definitions (and optionally tasks)

#Az Login
az login
az account set -s $SUBSCRIPTION_ID --only-show-errors


# register provider
az provider register -n 'Microsoft.DevCenter' -o none
az provider register -n 'Microsoft.Storage' -o none
az provider register -n 'Microsoft.LoadTestService' -o none
az provider register -n 'Microsoft.OperationalInsights' -o none
az provider register -n 'microsoft.insights' -o none
az provider register -n 'Microsoft.Web' -o none


#Az config w/ start-job wrapper to block warning messages
az config set extension.use_dynamic_install=yes_without_prompt
az extension add --name devcenter --allow-preview true

# create main resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# creating Keyvault
az keyvault create -n $KV_NAME -l $LOCATION -g $RESOURCE_GROUP --enable-rbac-authorization true -o none --only-show-errors
KEYVAULT_RESOURCE_ID=$(az keyvault show -g $RESOURCE_GROUP -n $KV_NAME --query id -o tsv)
az role assignment create --role "Key Vault Administrator" --assignee "@lab.CloudPortalCredential(User1).Username" --scope $KEYVAULT_RESOURCE_ID -o none

# creating devcenter
az devcenter admin devcenter create --location $LOCATION --name $DEVCENTER_NAME --resource-group $RESOURCE_GROUP -o none

# Enabling managed identity on DevCenter
az devcenter admin devcenter update --name $DEVCENTER_NAME --identity-type SystemAssigned --resource-group $RESOURCE_GROUP -o none 

# Create environment types
az devcenter admin environment-type create --dev-center-name "$DEVCENTER_NAME" --name "PROD" --resource-group "$RESOURCE_GROUP" -o none 
az devcenter admin environment-type create --dev-center-name "$DEVCENTER_NAME" --name "TEST" --resource-group "$RESOURCE_GROUP" -o none 
az devcenter admin environment-type create --dev-center-name "$DEVCENTER_NAME" --name "DEV" --resource-group "$RESOURCE_GROUP" -o none 

# create a project
DEVCENTER_ID=$(az devcenter admin devcenter show --name $DEVCENTER_NAME --resource-group $RESOURCE_GROUP --query id -o tsv)
az devcenter admin project create --location $LOCATION --description "This is my first project." --dev-center-id "$DEVCENTER_ID" --name $PROJECT_NAME --resource-group "$RESOURCE_GROUP" --max-dev-boxes-per-user "3" -o none

# Retrieving managed identity
OID=$(az ad sp list --display-name $DEVCENTER_NAME --query [].id -o tsv)
az role assignment create --role "Key Vault Secrets User" --assignee "$OID" --scope $KEYVAULT_RESOURCE_ID -o none

# create a DevBox
az devcenter admin devbox-definition create --location $LOCATION --image-reference id="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DevCenter/devcenters/$DEVCENTER_NAME/galleries/default/images/microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2" --os-storage-type "ssd_256gb" --sku name="general_i_8c32gb256ssd_v2" --name "WebDevBox" --dev-center-name "$DEVCENTER_NAME" --resource-group "$RESOURCE_GROUP" -o none
az devcenter admin devbox-definition create --location $LOCATION --image-reference id="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DevCenter/devcenters/$DEVCENTER_NAME/galleries/default/images/microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2" --os-storage-type "ssd_512gb" --sku name="general_i_32c128gb512ssd_v2" --name "SuperPowerfulDevBox" --dev-center-name "$DEVCENTER_NAME" --resource-group "$RESOURCE_GROUP" -o none

# create pools
az devcenter admin pool create --location $LOCATION --devbox-definition-name "WebDevBox" --pool-name "DevPool" --project-name $PROJECT_NAME --resource-group $RESOURCE_GROUP --local-administrator "Enabled" --virtual-network-type "Managed" --managed-virtual-network-regions "westeurope" -o none
az devcenter admin pool create --location $LOCATION --devbox-definition-name "SuperPowerfulDevBox" --pool-name "DevPoolPowerFull" --project-name $PROJECT_NAME --resource-group $RESOURCE_GROUP --local-administrator "Enabled" --virtual-network-type "Managed" --managed-virtual-network-regions "westeurope" -o none

# create environment type
OWNER_ROLE_ID=$(az role definition list -n "Owner" --scope /subscriptions/$SUBSCRIPTION_ID --query '[].name' -o tsv)
az devcenter admin project-environment-type create --name "DEV" --resource-group $RESOURCE_GROUP --project-name $PROJECT_NAME --roles "{`"$OWNER_ROLE_ID`":{}}" --identity-type "SystemAssigned" --deployment-target-id "/subscriptions/$SUBSCRIPTION_ID" --status "Enabled"  -o none

# create secret using PAT given in secrets
az keyvault secret set --vault-name $KV_NAME --name GHPAT --value $PAT_TOKEN -o none
SECRETID=$(az keyvault secret show --vault-name $KV_NAME --name GHPAT --query id -o tsv)

# add catalog
az devcenter admin catalog create --git-hub path="/devcenter/ade" branch="main" secret-identifier=$SECRETID uri=$REPO_URL -n "MyCatalog" -d $DEVCENTER_NAME -g $RESOURCE_GROUP -o none
          