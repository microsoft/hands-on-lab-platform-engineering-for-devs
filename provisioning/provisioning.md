# Provisioning Environment

## Deploying the DevCenter resources

One script  ([deploy.sh](deploy.sh)) is available to deploy:
- A devcenter with pools, definitions, catalog, projects, etc

## Create devbox on behalf of users

This project contains a shell script to provision Dev Boxes for a list of users.

### Files

[provision_dev_boxes.sh](provision_dev_boxes.sh): This is the main script that creates Dev Boxes for each user in the users.csv file.
users.csv: This file contains a list of email addresses of users for whom the Dev Boxes will be created.

### How to use

- Make sure you have Azure CLI installed and configured on your machine.
- Update the users.csv file with the email addresses of the users for whom you want to create Dev Boxes as well as their passwords.
- Run the provision_dev_boxes.sh script with the following command:
The script will read the users.csv file, log in to the Azure portal for each user, generate a unique name for the Dev Box using uuidgen, and then create the Dev Box in the specified development center.

> **Note**: The script does not block and does not check if the creation of the Dev Box was successful. It simply launches the creation command and moves on to the next user.