#!/bin/bash

# Define the SageMaker domain ID
DOMAIN_ID="d-fysmgh7nkwv7"
PROFILE="aiml"
IAM_GROUP_NAME="workshop"

# Loop through each user in the users.txt file
while IFS= read -r username; do
    # Delete SageMaker Studio Applications
    aws sagemaker list-apps --domain-id-equals "$DOMAIN_ID" --query "Apps[*].[AppType, AppName, UserProfileName]" --output text --profile "$PROFILE" | while read app; do
        apptype=$(echo "$app" | awk '{print $1}')
        appname=$(echo "$app" | awk '{print $2}')
        userprofilename=$(echo "$app" | awk '{print $3}')

        if [ "$userprofilename" == "$username" ]; then
            echo "Deleting Studio Application $appname for user $username ..."
            aws sagemaker delete-app --domain-id "$DOMAIN_ID" --app-type "$apptype" --app-name "$appname" --user-profile-name "$userprofilename" --profile "$PROFILE"
        fi
    done

    # Delete SageMaker User Profiles
    aws sagemaker delete-user-profile --domain-id "$DOMAIN_ID" --user-profile-name "$username" --profile "$PROFILE"
    echo "Deleted SageMaker User Profile for user $username."

    # Delete IAM user
    aws iam remove-user-from-group --group-name "$IAM_GROUP_NAME" --user-name "$username" --profile "$PROFILE"
    aws iam delete-login-profile --user-name "$username" --profile "$PROFILE"
    aws iam delete-user --user-name "$username" --profile "$PROFILE"
    echo "Deleted IAM user $username."

done <users.txt

echo "Script completed."
