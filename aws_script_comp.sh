#!/bin/bash

# Environment variable
ENVIRONMENT=$1

# --- Step 1: Check number of arguments ---
check_num_of_args() {
  echo "Checking the number of arguments..."
  if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <environment>"
    exit 1
  fi
}

# --- Step 2: Activate Environment ---
activate_infra_environment() {
  echo "Activating environment: $ENVIRONMENT"
  case "$ENVIRONMENT" in
    local)
      echo "Running script for Local Environment..."
      ;;
    testing)
      echo "Running script for Testing Environment..."
      ;;
    production)
      echo "Running script for Production Environment..."
      ;;
    *)
      echo "Invalid environment specified. Please use 'local', 'testing', or 'production'."
      exit 2
      ;;
  esac
}

# --- Step 3: Check AWS CLI ---
check_aws_cli() {
  if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it before proceeding."
    exit 3
  fi
}

# --- Step 4: Check AWS Profile ---
check_aws_profile() {
  if [ -z "$AWS_PROFILE" ]; then
    echo "AWS profile environment variable is not set."
    exit 4
  fi
}

# --- Step 5: Create EC2 Instances ---
create_ec2_instances() {
  echo "Creating EC2 instances..."
  instance_type="t2.micro"
  ami_id="ami-0cd59ecaf368e5ccf"
  count=2
  region="eu-west-2"
  key_name="MyKeyPair"

  aws ec2 run-instances \
    --image-id "$ami_id" \
    --instance-type "$instance_type" \
    --count "$count" \
    --key-name "$key_name" \
    --region "$region"

  if [ $? -eq 0 ]; then
    echo "EC2 instances created successfully."
  else
    echo "Failed to create EC2 instances."
    exit 5
  fi
}

# --- Step 6: Create S3 Buckets ---
create_s3_buckets() {
  echo "Creating S3 buckets for departments..."
  company="datawise"
  region="eu-west-2"
  departments=("Marketing" "Sales" "HR" "Operations" "Media")

  for department in "${departments[@]}"; do
    bucket_name="${company}-${department,,}-data-bucket"
    echo "Creating bucket: $bucket_name ..."
    aws s3api create-bucket \
      --bucket "$bucket_name" \
      --region "$region" \
      --create-bucket-configuration LocationConstraint="$region"

    if [ $? -eq 0 ]; then
      echo "S3 bucket '$bucket_name' created successfully."
    else
      echo "Failed to create S3 bucket '$bucket_name'."
    fi
  done
}

# --- Step 7: IAM Management Section ---

# Define IAM User Names Array
IAM_USERS=("alice" "bob" "charlie" "david" "emma")

# Create IAM Users
create_iam_users() {
  echo "Creating IAM users..."
  for user in "${IAM_USERS[@]}"; do
    aws iam create-user --user-name "$user"
    if [ $? -eq 0 ]; then
      echo "IAM user '$user' created successfully."
    else
      echo "Failed to create IAM user '$user' (might already exist)."
    fi
  done
}

# Create IAM Group
create_iam_group() {
  echo "Creating IAM group 'admin'..."
  aws iam create-group --group-name admin 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "IAM group 'admin' created successfully."
  else
    echo "IAM group 'admin' may already exist."
  fi
}

# Attach Administrative Policy to Group
attach_admin_policy_to_group() {
  echo "Attaching AdministratorAccess policy to 'admin' group..."
  aws iam attach-group-policy \
    --group-name admin \
    --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
  if [ $? -eq 0 ]; then
    echo "Policy attached successfully."
  else
    echo "Failed to attach policy."
  fi
}

# Assign Users to Group
assign_users_to_group() {
  echo "Assigning users to 'admin' group..."
  for user in "${IAM_USERS[@]}"; do
    aws iam add-user-to-group \
      --user-name "$user" \
      --group-name admin
    if [ $? -eq 0 ]; then
      echo "User '$user' added to group 'admin'."
    else
      echo "Failed to add user '$user' to group (might already be added)."
    fi
  done
}

# --- MAIN EXECUTION ---
check_num_of_args "$@"
activate_infra_environment
check_aws_cli
check_aws_profile
create_ec2_instances
create_s3_buckets
create_iam_users
create_iam_group
attach_admin_policy_to_group
assign_users_to_group

echo "✅ Infrastructure and IAM setup completed successfully!"
