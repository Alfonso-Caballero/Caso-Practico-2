#!/bin/bash

# Aplicar configuración de Terraform
terraform init
terraform apply -auto-approve

# Ejecutar playbook de Ansible
ansible-playbook -i hosts playbook.yml