#!/bin/bash

# Define the name of the IAM group and SageMaker domain and role ARN
IAM_GROUP_NAME="workshop"
DOMAIN_ID="d-fysmgh7nkwv7"
ROLE_ARN="arn:aws:iam::000527353527:role/service-role/AmazonSageMaker-ExecutionRole-20230920T221343"
DEFAULT_STUDIO_APP_NAME="default"
PROFILE="aiml"
KERNEL_APP_NAME="datascience"
KERNEL_INSTANCE_TYPE="ml.t3.medium"
KERNEL_IMAGE_ARN="arn:aws:sagemaker:us-east-1:081325390199:image/sagemaker-data-science-310-v1"

# Loop through each user in the users.txt file
while IFS= read -r username; do
    # Create IAM user
    aws iam create-user --user-name "$username" --profile "$PROFILE"
    aws iam create-login-profile --user-name "$username" --password "workshop123" --password-reset-required

    # Add the user to the IAM group
    aws iam add-user-to-group --user-name "$username" --group-name "$IAM_GROUP_NAME" --profile "$PROFILE"

    # Create SageMaker user profile
    aws sagemaker create-user-profile \
        --domain-id "$DOMAIN_ID" \
        --user-profile-name "$username" \
        --user-settings "{\"ExecutionRole\":\"$ROLE_ARN\"}" \
        --profile "$PROFILE"

    echo "User $username created and added to the $IAM_GROUP_NAME group with a SageMaker profile."

    # Create Application Default Studio Application
    aws sagemaker create-app \
        --domain-id "$DOMAIN_ID" \
        --app-name "$DEFAULT_STUDIO_APP_NAME" \
        --user-profile-name "$username" \
        --app-type "JupyterServer" \
        --profile "$PROFILE"

    # Create Kernel Application
    aws sagemaker create-app \
        --domain-id "$DOMAIN_ID" \
        --app-name "$KERNEL_APP_NAME" \
        --user-profile-name "$username" \
        --app-type "KernelGateway" \
        --resource-spec "SageMakerImageArn=$KERNEL_IMAGE_ARN,InstanceType=$KERNEL_INSTANCE_TYPE" \
        --profile "$PROFILE"

    echo "Applications created for user $username."

done <users.txt

echo "Script completed."
echo "Console: https://aiml-workshop.signin.aws.amazon.com/console"
