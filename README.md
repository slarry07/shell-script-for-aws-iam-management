# AWS IAM Automation with Bash Arrays and Functions

## Overview
This project automates IAM resource creation on AWS using the CLI. It:
- Defines an array of IAM user names
- Iterates to create multiple IAM users
- Creates an IAM group called `admin`

## Prerequisites
- AWS CLI installed and configured
- IAM credentials with permission to create users and groups

## Script

```bash
#!/bin/bash

# Array of IAM user names
IAM_USERS=("user1" "user2" "user3" "user4" "user5")

# Function to create IAM users
create_iam_users() {
    for USER in "${IAM_USERS[@]}"; do
        aws iam create-user --user-name "$USER"
    done
}

# Function to create IAM group named 'admin'
create_admin_group() {
    aws iam create-group --group-name admin
}

# Execute functions
create_iam_users
create_admin_group
