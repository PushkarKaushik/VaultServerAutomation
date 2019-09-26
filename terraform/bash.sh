#!/bin/sh
  addr=$1
  port=$2
  user=$3

  cd ~/finalAssignment/terraform/
  sudo terraform init
  sudo terraform apply -no-color -auto-approve
  sudo touch text.txt
  sudo chmod 666 text.txt
  sudo python pyth.py > text.txt
  sudo sed -i -e '1s/^/IP1: /' text.txt
  sudo sed -i -e '2s/^/IP2: /' text.txt 
  sudo sed -i -e '3s/^/IP3: /' text.txt 
  sudo sed -i -e '4s/^/BASTION_IP: /' text.txt
  sudo bash -c 'cat text.txt >> ~/finalAssignment/ansible-config/ansible_config/vars/Debian.yml'
  sudo bash -c 'cat text.txt >> ~/finalAssignment/ansible-config/ansible_config/vars/RedHat.yml'
  cd ~/finalAssignment/ansible-config/
  ansible-playbook ansible.yml 
  cd /etc/ansible/
  sudo sed -i '/ssh_connection/r Ansible' ansible.cfg
  sudo cp -rf config  ~/.ssh/
  ansible -m ping all
  ansible -m ping all
  ansible -m ping all
  ansible -m ping all
  ansible -m ping all
  ansible-playbook ~/finalAssignment/vault-role/vault-setup.yml 
  echo "hit dns of alb"
  
