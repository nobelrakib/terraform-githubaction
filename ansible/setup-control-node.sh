#!/bin/bash

# K3s Multi-Node Cluster - Control Node Setup Script
# This script sets up the control node EC2 instance for running Ansible playbooks

set -e

echo "=== K3s Multi-Node Cluster - Control Node Setup ==="
echo "This script will install Ansible and prepare the control node"
echo ""

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt install -y ansible python3-pip git curl wget

# Verify Ansible installation
echo "Verifying Ansible installation..."
ansible --version

# Create project directory
#echo "Creating project directory..."
#mkdir -p ~/k3s-cluster
#cd ~/k3s-cluster

# Create inventory template in YAML format
echo "Creating inventory template in YAML format..."
cat > inventory-multi-node.yml << 'EOF'
---
all:
  children:
    k3s_masters:
      hosts:
        k3s-master-01:
          ansible_host: 10.0.2.26
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/k3s-cluster/dev-key.pem
          node_role: master
          node_type: control-plane
    
    k3s_workers:
      hosts:
        k3s-worker-01:
          ansible_host: 10.0.2.193
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/k3s-cluster/dev-key.pem

        
         
    
    k3s_cluster:
      children:
        k3s_masters:
        k3s_workers:
  
  vars:
    ansible_python_interpreter: /usr/bin/python3
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
    ansible_timeout: 30
EOF

# Create ansible.cfg for better defaults
echo "Creating Ansible configuration..."
cat > ansible.cfg << 'EOF'
[defaults]
host_key_checking = False
inventory = inventory-multi-node.yml
remote_user = ubuntu
private_key_file = ~/k3s-cluster/dev-key.pem
timeout = 30
gathering = smart
fact_caching = memory

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes
EOF


# Create a test script
echo "Creating connectivity test script..."
cat > test-connectivity.sh << 'EOF'
#!/bin/bash

# Test connectivity to all nodes
echo "Testing connectivity to all nodes..."
ansible all -m ping

echo ""
echo "Testing connectivity with verbose output..."
ansible all -m ping -v

echo ""
echo "Displaying inventory structure..."
ansible-inventory --list -y
EOF

chmod +x test-connectivity.sh

# Create a deployment script
echo "Creating deployment script..."
cat > deploy-cluster.sh << 'EOF'
#!/bin/bash

# Deploy K3s cluster
echo "Deploying K3s multi-node cluster..."
ansible-playbook k3s-multi-node-cluster.yml

echo ""
echo "Cluster deployment completed!"
echo "Check the output above for any errors."
EOF

chmod +x deploy-cluster.sh

# Create a script to show inventory
echo "Creating inventory display script..."
cat > show-inventory.sh << 'EOF'
#!/bin/bash

# Display inventory structure and details
echo "=== K3s Cluster Inventory ==="
echo ""
echo "Inventory structure:"
ansible-inventory --list -y

echo ""
echo "Master nodes:"
ansible k3s_masters --list-hosts

echo ""
echo "Worker nodes:"
ansible k3s_workers --list-hosts

echo ""
echo "All nodes:"
ansible all --list-hosts
EOF

chmod +x show-inventory.sh

echo ""
echo "=== Control Node Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Transfer your SSH key to this control node:"
echo "   scp -i ~/.ssh/dev-key.pem ~/.ssh/dev-key.pem ubuntu@<CONTROL_NODE_IP>:~/k3s-cluster/dev-key.pem"
echo ""
echo "2. Transfer the Ansible playbook:"
echo "   scp -i ~/.ssh/dev-key.pem k3s-multi-node-cluster.yml ubuntu@<CONTROL_NODE_IP>:~/k3s-cluster/"
echo ""
echo "3. Edit the inventory file with your node IPs:"
echo "   nano ~/k3s-cluster/inventory-multi-node.yml"
echo ""
echo "4. Set correct permissions for SSH key:"
echo "   chmod 600 ~/k3s-cluster/dev-key.pem"
echo ""
echo "5. Test connectivity:"
echo "   cd ~/k3s-cluster && ./test-connectivity.sh"
echo ""
echo "6. Show inventory structure:"
echo "   cd ~/k3s-cluster && ./show-inventory.sh"
echo ""
echo "7. Deploy the cluster:"
echo "   cd ~/k3s-cluster && ./deploy-cluster.sh"
echo ""
echo "For detailed instructions, see README-K3s-Multi-Node.md" 