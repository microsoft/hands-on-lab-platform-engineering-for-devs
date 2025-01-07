# Pre-Build

```powershell
$providers = @(
    "Microsoft.DevCenter",
    "Microsoft.Storage",
    "Microsoft.LoadTestService",
    "Microsoft.OperationalInsights",
    "microsoft.insights",
    "Microsoft.Web"
)

foreach ($provider in $providers) {
    Register-AzResourceProvider -ProviderNamespace $provider
    Start-Sleep -Seconds 30
}
```


# First Displayble

Deploy resources
```powershell
#Set Variables
$LOCATION = "westeurope"
$DEVCENTER_NAME = "mydevcenter-@lab.LabInstance.Id"
$RESOURCE_GROUP = "rg-plateng"
$SUBSCRIPTION_ID = "@lab.CloudSubscription.Id"
$PROJECT_NAME = "myproject"
$DEVBOX_NAME = "mydevbox-@lab.LabInstance.Id"
$KV_NAME = "kv@lab.LabInstance.Id"
$PAT_TOKEN = "github_pat_11ABTRVVY0nOXfkwMj8sy9XXXXXX" # read-only one one repo
$REPO_URL="https://github.com/microsoft/hands-on-lab-platform-engineering-for-devs.git"

#Az Login
start-job -name azLogin -ScriptBlock {az login -u "@lab.CloudPortalCredential(User1).Username" -p "@lab.CloudPortalCredential(User1).Password" --only-show-errors} | Out-Null
wait-job -name azLogin | Out-Null
az account set -s @lab.CloudSubscription.Id --only-show-errors

#Az config w/ start-job wrapper to block warning messages
start-job -name azConfig -ScriptBlock {az config set extension.use_dynamic_install=yes_without_prompt} | Out-Null
wait-job -name azConfig | Out-Null
az extension add --name devcenter --allow-preview true

# create main resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# creating Keyvault
az keyvault create -n $KV_NAME -l $LOCATION -g $RESOURCE_GROUP --enable-rbac-authorization true -o none --only-show-errors
$KEYVAULT_RESOURCE_ID = (az keyvault show -g $RESOURCE_GROUP -n $KV_NAME --query id -o tsv)
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
$DEVCENTER_ID = (az devcenter admin devcenter show --name $DEVCENTER_NAME --resource-group $RESOURCE_GROUP --query id -o tsv)
az devcenter admin project create --location $LOCATION --description "This is my first project." --dev-center-id "$DEVCENTER_ID" --name $PROJECT_NAME --resource-group "$RESOURCE_GROUP" --max-dev-boxes-per-user "3" -o none

# Retrieving managed identity
$OID = (az ad sp list --display-name $DEVCENTER_NAME --query [].id -o tsv)
# DevCenter should be able to read secrets from KeyVault
az role assignment create --role "Key Vault Secrets User" --assignee "$OID" --scope $KEYVAULT_RESOURCE_ID -o none
# DevCenter must be able to deploy and assign role at subscription level
az role assignment create --role "Owner" --assignee "$OID" --scope "/subscriptions/$SUBSCRIPTION_ID" -o none

# create a DevBox
az devcenter admin devbox-definition create --location $LOCATION --image-reference id="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DevCenter/devcenters/$DEVCENTER_NAME/galleries/default/images/microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2" --os-storage-type "ssd_256gb" --sku name="general_i_8c32gb256ssd_v2" --name "WebDevBox" --dev-center-name "$DEVCENTER_NAME" --resource-group "$RESOURCE_GROUP" -o none
az devcenter admin devbox-definition create --location $LOCATION --image-reference id="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DevCenter/devcenters/$DEVCENTER_NAME/galleries/default/images/microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2" --os-storage-type "ssd_512gb" --sku name="general_i_32c128gb512ssd_v2" --name "SuperPowerfulDevBox" --dev-center-name "$DEVCENTER_NAME" --resource-group "$RESOURCE_GROUP" -o none

# create pools
az devcenter admin pool create --location $LOCATION --devbox-definition-name "WebDevBox" --pool-name "WebDevPool" --project-name $PROJECT_NAME --resource-group $RESOURCE_GROUP --local-administrator "Enabled" --virtual-network-type "Managed" --managed-virtual-network-regions "westeurope" -o none
az devcenter admin pool create --location $LOCATION --devbox-definition-name "SuperPowerfulDevBox" --pool-name "WebDevPoolPowerful" --project-name $PROJECT_NAME --resource-group $RESOURCE_GROUP --local-administrator "Enabled" --virtual-network-type "Managed" --managed-virtual-network-regions "westeurope" -o none

# create environment type
$OWNER_ROLE_ID = (az role definition list -n "Owner" --scope /subscriptions/$SUBSCRIPTION_ID --query '[].name' -o tsv)
az devcenter admin project-environment-type create --name "DEV" --resource-group $RESOURCE_GROUP --project-name $PROJECT_NAME --roles "{`"$OWNER_ROLE_ID`":{}}" --identity-type "SystemAssigned" --deployment-target-id "/subscriptions/$SUBSCRIPTION_ID" --status "Enabled"  -o none

# create secret using PAT given in secrets
az keyvault secret set --vault-name $KV_NAME --name GHPAT --value $PAT_TOKEN -o none
$SECRETID = (az keyvault secret show --vault-name $KV_NAME --name GHPAT --query id -o tsv)

# add role assignment. without it, even the owner of the devcenter can not create devboxes
$ENTRA_ID_USER_ID = (az ad user show --id "@lab.CloudPortalCredential(User1).Username" --query id -o tsv)
$PROJECT_ID = (az devcenter admin project show --name $PROJECT_NAME --resource-group $RESOURCE_GROUP --query id -o tsv)
az role assignment create --role "DevCenter Dev Box User" --assignee $ENTRA_ID_USER_ID --scope $PROJECT_ID -o none 
az role assignment create --role "Deployment Environments User" --assignee $ENTRA_ID_USER_ID --scope $PROJECT_ID -o none 
az role assignment create --role "DevCenter Project Admin"  --assignee $ENTRA_ID_USER_ID  --scope $PROJECT_ID -o none 

# add catalog
az devcenter admin catalog create --git-hub path="/devcenter/ade" branch="main" secret-identifier=$SECRETID uri=$REPO_URL -n "MyCatalog" -d $DEVCENTER_NAME -g $RESOURCE_GROUP -o none
          
# create a dev box for the user
az devcenter dev dev-box create --pool-name "WebDevPool" --name $DEVBOX_NAME --project-name $PROJECT_NAME --dev-center $DEVCENTER_NAME --no-wait
```

Install NodeJS

``` powershell
# install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# install NodeJS full
choco install -y --force nodejs-lts 
```