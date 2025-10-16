#!/bin/bash

# Array of IAM user names
IAM_USERS=("user1" "user2" "user3" "user4" "user5")
ADMIN_GROUP="admin"
ADMIN_POLICY_ARN="arn:aws:iam::aws:policy/AdministratorAccess"

# Function to check and create IAM users
create_iam_users() {
    for USER in "${IAM_USERS[@]}"; do
        if aws iam get-user --user-name "$USER" >/dev/null 2>&1; then
            echo "User $USER already exists. Skipping..."
        else
            if aws iam create-user --user-name "$USER" >/dev/null 2>&1; then
                echo "User $USER created successfully."
            else
                echo "Failed to create user $USER."
            fi
        fi
    done
}

# Function to check and create IAM admin group
create_admin_group() {
    if aws iam get-group --group-name "$ADMIN_GROUP" >/dev/null 2>&1; then
        echo "Group $ADMIN_GROUP already exists. Skipping..."
    else
        if aws iam create-group --group-name "$ADMIN_GROUP" >/dev/null 2>&1; then
            echo "Group $ADMIN_GROUP created successfully."
        else
            echo "Failed to create group $ADMIN_GROUP."
        fi
    fi
}

# Function to attach admin policy to group
attach_admin_policy() {
    if aws iam list-attached-group-policies --group-name "$ADMIN_GROUP" | grep -q "$ADMIN_POLICY_ARN"; then
        echo "Policy already attached to $ADMIN_GROUP. Skipping..."
    else
        if aws iam attach-group-policy --group-name "$ADMIN_GROUP" --policy-arn "$ADMIN_POLICY_ARN" >/dev/null 2>&1; then
            echo "AdministratorAccess policy attached to $ADMIN_GROUP."
        else
            echo "Failed to attach policy to $ADMIN_GROUP."
        fi
    fi
}

# Main execution
create_iam_users
create_admin_group
attach_admin_policy
