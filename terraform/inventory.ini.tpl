[all:vars]
ansible_user=kuromi
ansible_ssh_common_args="-o StrictHostKeyChecking=no"
ansible_ssh_private_key_file=~/.ssh/id_ed25519-skylab

[all]
${web_vms.guest_name} ansible_host=${web_vms.ip_address}

