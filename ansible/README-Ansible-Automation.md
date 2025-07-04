# Ansible Infrastructure Automation

This document explains the separate Ansible automation workflow that automatically deploys K3s clusters when changes are made to the Ansible folder.

## Overview

The **ansible-infra-automation** workflow is a dedicated GitHub Actions workflow that:

1. **Triggers automatically** when changes are pushed to the `ansible/` folder
2. **Can be triggered manually** via workflow dispatch with environment selection
3. **Automatically gets EC2 instance information** from Terraform outputs
4. **Creates dynamic inventory** based on the current infrastructure
5. **Runs the K3s cluster setup playbook** to deploy the cluster

## Workflow Structure

### Two Separate Workflows

1. **terraform-iac.yml**: Handles Terraform infrastructure provisioning
2. **ansible-infra-automation.yml**: Handles Ansible configuration management

This separation provides:
- **Clear separation of concerns**
- **Independent triggering** (Terraform changes vs Ansible changes)
- **Better organization** and maintainability
- **Focused automation** for each tool

## How It Works

### Automatic Triggering
- When you push changes to any file in the `ansible/` folder, the **ansible-infra-automation** workflow automatically runs
- It first gets infrastructure information from Terraform outputs
- Then runs Ansible playbooks to configure the infrastructure

### Manual Triggering
1. Go to your GitHub repository
2. Click on **Actions** tab
3. Select the **ansible-infra-automation** workflow
4. Click **Run workflow**
5. Choose your options:
   - `run_ansible`: Set to `true` to run Ansible playbooks
   - `target_environment`: Choose `dev`, `stage`, or `prod`
6. Click **Run workflow**

## Workflow Jobs

### 1. Get Infrastructure Information
- **Job Name**: `get-infrastructure`
- **Purpose**: Retrieves EC2 instance information from Terraform outputs
- **Outputs**: Public IP, Private IPs, Database IP

### 2. Ansible Infrastructure Automation
- **Job Name**: `ansible-automation`
- **Purpose**: Main Ansible automation job
- **Dependencies**: Requires `get-infrastructure` job
- **Tasks**:
  - Setup Ansible and dependencies
  - Create SSH key for EC2 access
  - Generate dynamic inventory from Terraform outputs
  - Test connectivity to all nodes
  - Run K3s cluster setup playbook
  - Verify cluster deployment

### 3. Additional Ansible Tasks (Optional)
- **Job Name**: `additional-ansible-tasks`
- **Purpose**: Run additional playbooks or tasks
- **Trigger**: Manual workflow dispatch only
- **Dependencies**: Requires both previous jobs

## Prerequisites

### GitHub Secrets Required
You need to add the following secrets to your GitHub repository:

1. **EC2_SSH_PRIVATE_KEY**: The private SSH key for connecting to EC2 instances
   - This should be the same key used by Terraform for the EC2 instances
   - Add the entire private key content (including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`)

2. **AWS_ACCESS_KEY_ID**: AWS access key for Terraform operations
3. **AWS_SECRET_ACCESS_KEY**: AWS secret key for Terraform operations
4. **BUCKET_TF_STATE**: S3 bucket name for Terraform state

### How to Add the SSH Key Secret
1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `EC2_SSH_PRIVATE_KEY`
5. Value: Paste your entire private key content
6. Click **Add secret**

## Workflow Steps

The Ansible automation job performs the following steps:

1. **Setup Ansible**: Installs Ansible and required packages
2. **Create SSH Key**: Sets up SSH authentication for EC2 instances
3. **Create Dynamic Inventory**: Generates inventory file from Terraform outputs
4. **Create Ansible Config**: Sets up Ansible configuration
5. **Display Inventory**: Shows the inventory structure
6. **Test Connectivity**: Pings all nodes to verify connectivity
7. **Run K3s Playbook**: Executes the K3s cluster setup
8. **Verify Deployment**: Checks cluster status
9. **Get Cluster Info**: Retrieves cluster information
10. **Check Service Status**: Verifies K3s service status on all nodes

## Inventory Structure

The dynamic inventory creates the following structure:

```yaml
all:
  children:
    k3s_masters:
      hosts:
        k3s-master-01:  # Public EC2 instance
    k3s_workers:
      hosts:
        k3s-worker-01:  # First private EC2 instance
        k3s-worker-02:  # Second private EC2 instance
    k3s_cluster:
      children:
        k3s_masters:
        k3s_workers:
```

## Environment Support

The workflow supports multiple environments:
- **dev**: Development environment
- **stage**: Staging environment  
- **prod**: Production environment

You can select the target environment when manually triggering the workflow.

## Troubleshooting

### Common Issues

1. **SSH Connection Failed**
   - Ensure the `EC2_SSH_PRIVATE_KEY` secret is correctly set
   - Verify the SSH key matches the one used in Terraform
   - Check that EC2 instances are running and accessible

2. **Terraform Outputs Not Found**
   - Ensure Terraform has been applied successfully
   - Check that the EC2 module outputs are correctly defined
   - Verify the infrastructure is deployed

3. **Ansible Playbook Fails**
   - Check the workflow logs for specific error messages
   - Verify the playbook syntax and dependencies
   - Ensure all required variables are defined

### Debugging Steps

1. **Check Workflow Logs**: Review the detailed logs in GitHub Actions
2. **Test Connectivity**: The workflow includes connectivity tests
3. **Verify Inventory**: The workflow displays the inventory structure
4. **Check EC2 Status**: Ensure all instances are running and healthy

## Security Considerations

- The SSH private key is stored as a GitHub secret and is encrypted
- The key is only used during workflow execution and is not persisted
- Consider using temporary credentials or key rotation for production environments

## Customization

You can customize the Ansible automation by:

1. **Modifying the playbook**: Edit `k3s-multi-node-cluster.yml`
2. **Adding more playbooks**: Create additional playbooks in the `ansible/` folder
3. **Customizing inventory**: Modify the dynamic inventory generation
4. **Adding pre/post tasks**: Extend the workflow with additional steps
5. **Environment-specific configurations**: Use the environment variable in playbooks

## Example Usage

### Automatic Deployment
```bash
# Make changes to ansible files
git add ansible/k3s-multi-node-cluster.yml
git commit -m "Update K3s cluster configuration"
git push origin main
# ansible-infra-automation workflow will automatically trigger and deploy
```

### Manual Deployment
1. Go to GitHub Actions
2. Select **ansible-infra-automation** workflow
3. Run workflow manually with:
   - `run_ansible: true`
   - `target_environment: dev`
4. Monitor the deployment progress
5. Check the results in the workflow logs

## Integration with Terraform Workflow

The Ansible workflow integrates with the Terraform workflow by:
- Reading Terraform outputs to get infrastructure information
- Using the same AWS credentials and state bucket
- Ensuring infrastructure is available before running Ansible

This creates a complete CI/CD pipeline:
1. **Terraform** provisions the infrastructure
2. **Ansible** configures the infrastructure
3. **Both workflows** can run independently or together 

