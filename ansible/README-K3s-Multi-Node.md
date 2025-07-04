# K3s Multi-Node Cluster Setup with Ansible

This project contains Ansible playbooks to automatically deploy a multi-node K3s cluster on EC2 Ubuntu instances. The playbook runs from a separate control node EC2 instance.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Control Node   │    │   Master Node   │    │  Worker Node 1  │    │  Worker Node 2  │
│                 │    │                 │    │                 │    │                 │
│ - Ansible       │    │ - K3s Server    │    │ - K3s Agent     │    │ - K3s Agent     │
│ - SSH Keys      │    │ - kubectl       │    │ - Workloads     │    │ - Workloads     │
│ - Inventory     │    │ - Helm          │    │                 │    │                 │
│                 │    │ - Traefik       │    └─────────────────┘    └─────────────────┘
│                 │    │ - MetalLB       │
└─────────────────┘    └─────────────────┘
```

## Prerequisites

### Control Node (Ansible Runner)
- **1 EC2 Ubuntu instance** (t3.medium or larger)
- **Ansible installed:** `sudo apt update && sudo apt install -y ansible`
- **SSH key pair** for accessing target nodes
- **Python 3.x**

### Target Nodes (K3s Cluster)
- **1 Master Node + Multiple Worker Nodes** (Ubuntu 20.04/22.04)
- **Minimum specs per node:**
  - 2 vCPUs
  - 4 GB RAM
  - 20 GB storage
- **Security Groups:** 
  - Allow SSH (port 22) from Control Node
  - Allow K3s API (port 6443) between nodes
  - Allow NodePort range (30000-32767)
  - Allow LoadBalancer ports (80, 443)
- **IAM Role:** EC2 instances should have appropriate permissions

## Setup Instructions

### 1. Control Node Setup
SSH to your control node EC2 instance and run:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Ansible
sudo apt install -y ansible

# Install Python pip
sudo apt install -y python3-pip

# Verify Ansible installation
ansible --version

# Create project directory
mkdir k3s-cluster && cd k3s-cluster
```

### 2. Transfer Files to Control Node
Upload the following files to your control node:
- `k3s-multi-node-cluster.yml`
- `inventory-multi-node.yml`
- Your SSH private key (e.g., `your-key.pem`)

```bash
# From your local machine
scp -i ~/.ssh/your-key.pem k3s-multi-node-cluster.yml ubuntu@<CONTROL_NODE_IP>:~/k3s-cluster/
scp -i ~/.ssh/your-key.pem inventory-multi-node.yml ubuntu@<CONTROL_NODE_IP>:~/k3s-cluster/
scp -i ~/.ssh/your-key.pem ~/.ssh/your-key.pem ubuntu@<CONTROL_NODE_IP>:~/k3s-cluster/your-key.pem
```

### 3. Configure Inventory
On the control node, edit `inventory-multi-node.yml`:

```yaml
---
all:
  children:
    k3s_masters:
      hosts:
        k3s-master-01:
          ansible_host: <MASTER_EC2_PRIVATE_IP>
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/k3s-cluster/your-key.pem
          node_role: master
          node_type: control-plane
    
    k3s_workers:
      hosts:
        k3s-worker-01:
          ansible_host: <WORKER1_EC2_PRIVATE_IP>
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/k3s-cluster/your-key.pem
          node_role: worker
          node_type: compute
        k3s-worker-02:
          ansible_host: <WORKER2_EC2_PRIVATE_IP>
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/k3s-cluster/your-key.pem
          node_role: worker
          node_type: compute
        k3s-worker-03:
          ansible_host: <WORKER3_EC2_PRIVATE_IP>
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/k3s-cluster/your-key.pem
          node_role: worker
          node_type: compute
    
    k3s_cluster:
      children:
        k3s_masters:
        k3s_workers:
  
  vars:
    ansible_python_interpreter: /usr/bin/python3
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
    ansible_ssh_pipelining: true
    ansible_timeout: 30
    k3s_version: "v1.28.5+k3s1"
    cluster_name: "k3s-cluster"
    domain: "cluster.local"
```

**Important:** Use **private IPs** for better security and performance.

### 4. Set Proper Permissions
```bash
# Set correct permissions for SSH key
chmod 600 ~/k3s-cluster/your-key.pem

# Verify file permissions
ls -la ~/k3s-cluster/
```

### 5. Test Connectivity
```bash
# Test SSH connectivity to all nodes
ansible all -i inventory-multi-node.yml -m ping

# Test with verbose output if needed
ansible all -i inventory-multi-node.yml -m ping -v

# Display inventory structure
ansible-inventory --list -y -i inventory-multi-node.yml
```

### 6. Run the Playbook
```bash
# Run the playbook
ansible-playbook -i inventory-multi-node.yml k3s-multi-node-cluster.yml

# Run with verbose output for debugging
ansible-playbook -i inventory-multi-node.yml k3s-multi-node-cluster.yml -v
```

## Network Configuration

### Security Groups Setup
1. **Control Node Security Group:**
   - Inbound: SSH (22) from your IP
   - Outbound: All traffic

2. **Master Node Security Group:**
   - Inbound: SSH (22) from Control Node
   - Inbound: K3s API (6443) from Worker Nodes
   - Inbound: NodePort range (30000-32767) from Load Balancer
   - Outbound: All traffic

3. **Worker Node Security Group:**
   - Inbound: SSH (22) from Control Node
   - Inbound: K3s API (6443) from Master Node
   - Inbound: NodePort range (30000-32767) from Load Balancer
   - Outbound: All traffic

### VPC Configuration
- All nodes should be in the same VPC
- Use private subnets for worker nodes (recommended)
- Use public subnet for master node (if needed for external access)

## Post-Installation

### Access the Cluster from Control Node
```bash
# SSH to master node
ssh -i ~/k3s-cluster/your-key.pem ubuntu@<MASTER_PRIVATE_IP>

# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces
```

### Get Kubeconfig for Local Access
```bash
# From control node, copy kubeconfig to local machine
scp -i ~/k3s-cluster/your-key.pem ubuntu@<MASTER_PRIVATE_IP>:/etc/rancher/k3s/k3s.yaml ~/k3s-config.yaml

# Download to your local machine
scp -i ~/.ssh/your-key.pem ubuntu@<CONTROL_NODE_IP>:~/k3s-config.yaml ~/.kube/config

# Update server address (replace with master's public IP if needed)
sed -i 's/127.0.0.1/<MASTER_PUBLIC_IP>/g' ~/.kube/config
```

## Troubleshooting

### Common Issues
1. **SSH Connection Failed:**
   - Check security groups
   - Verify SSH key permissions (600)
   - Use private IPs for better connectivity

2. **Ansible Connection Issues:**
   ```bash
   # Test individual node
   ansible k3s-master-01 -i inventory-multi-node.yml -m ping -v
   
   # Check SSH manually
   ssh -i ~/k3s-cluster/your-key.pem ubuntu@<NODE_IP>
   ```

3. **K3s Installation Issues:**
   - Check system resources
   - Verify kernel modules are loaded
   - Check firewall rules

### Debugging Commands
```bash
# Check Ansible facts
ansible all -i inventory-multi-node.yml -m setup

# Test specific tasks
ansible-playbook -i inventory-multi-node.yml k3s-multi-node-cluster.yml --check

# Run with extra verbosity
ansible-playbook -i inventory-multi-node.yml k3s-multi-node-cluster.yml -vvv

# Display inventory structure
ansible-inventory --list -y -i inventory-multi-node.yml
```

## Security Best Practices

1. **Use Private IPs** for internal communication
2. **Restrict Security Groups** to minimum required ports
3. **Use IAM Roles** instead of access keys
4. **Regular Updates** of K3s and system packages
5. **Network Segmentation** with private subnets
6. **Backup Strategies** for etcd data

## Monitoring and Scaling

### Add More Worker Nodes
1. Launch new EC2 instances
2. Add them to the inventory file
3. Run the playbook again (only new nodes will be configured)

### Monitoring Setup
```bash
# Install monitoring stack (optional)
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```

## Cost Optimization

1. **Use Spot Instances** for worker nodes (if possible)
2. **Right-size instances** based on workload
3. **Use reserved instances** for master node
4. **Monitor resource usage** and scale accordingly

## Support
For issues and questions:
- Check K3s documentation: https://docs.k3s.io/
- Review Ansible logs for detailed error messages
- Verify network connectivity between nodes
- Check AWS CloudWatch logs for EC2 instances 