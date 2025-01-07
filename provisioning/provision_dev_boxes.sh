#/bin/bash

USERS_FILE="users.csv"
DEV_CENTER="web-dev-center"
RESOURCE_GROUP="rg-plateng-for-devs"
PROJECT_NAME="frontend-project"
POOL_NAME="WebDevBox"
DEVBOX_PREFIX="DevBox-"

# Give rights to each user to create dev boxes
az login
while IFS=, read -r USER PASSWORD
do
    # add role assignment. without it, even the owner of the devcenter can not create devboxes
    ENTRA_ID_USER_ID=$(az ad user show --id $USER --query id -o tsv)
    PROJECT_ID=$(az devcenter admin project show --name $PROJECT_NAME --resource-group $RESOURCE_GROUP --query id -o tsv)
    az role assignment create --role "DevCenter Dev Box User" --assignee $ENTRA_ID_USER_ID --scope $PROJECT_ID -o none 
    az role assignment create --role "Deployment Environments User" --assignee $ENTRA_ID_USER_ID --scope $PROJECT_ID -o none 
    #az role assignment create --role "DevCenter Project Admin"  --assignee $ENTRA_ID_USER_ID  --scope $PROJECT_ID -o none 

done < $USERS_FILE


# Read the users.csv file and create a dev box for each user
while IFS=, read -r user password
do
    echo "Connecting as $user..."
    az login --username $user --password $password > /dev/null 2>&1

    DEVBOX_NAME=$DEVBOX_PREFIX$(uuidgen)
    echo "Creating Dev Box $DEVBOX_NAME for $user..."

    az devcenter dev dev-box create --pool-name $POOL_NAME --name $DEVBOX_NAME --project-name $PROJECT_NAME --dev-center $DEV_CENTER --no-wait
done < $USERS_FILE