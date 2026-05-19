# Variáveis
RESOURCE_GROUP="rg-clyvoliana"
VM_NAME="vm-clyvoliana"
LOCATION="eastus"
VM_SIZE="Standard_B2s"
ADMIN_USER="clyvoliana"
ADMIN_PASSWORD="Clyvolianasenha123."

echo "Iniciando o provisionamento do Projeto Clyvo..."

# 1. Criar Resource Group
echo "Criando Resource Group..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# 2. Provisionar VM Linux
echo "Provisionando Máquina Virtual Linux..."
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image Ubuntu2404 \
  --size $VM_SIZE \
  --authentication-type password \
  --admin-username $ADMIN_USER \
  --admin-password $ADMIN_PASSWORD \
  --tags "owner=Clyvo" "purpose=DevOps"

# 3. Abrir portas necessárias
echo "Abrindo porta 8080 - API Spring Boot"
az vm open-port \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --port 8080 \
  --priority 1001

echo "Abrindo porta 1521 - Oracle Database"
az vm open-port \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --port 1521 \
  --priority 1002

# 4. Obter IP público
echo "Obtendo IP público da VM..."
PUBLIC_IP=$(az vm show \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --show-details \
  --query publicIps \
  --output tsv)

echo "IP Público da VM: $PUBLIC_IP"

# 5. Instalar ferramentas
echo "Instalar Git e nano"
az vm run-command invoke \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --command-id RunShellScript \
  --scripts "
    sudo apt-get update -y
    sudo apt-get install -y git nano curl wget unzip
  "

echo "Instalar Docker"
az vm run-command invoke \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --command-id RunShellScript \
  --scripts "
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  "

echo "Configurar Docker"
az vm run-command invoke \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --command-id RunShellScript \
  --scripts "
    sudo systemctl start docker
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    sudo usermod -aG docker clyvoliana
  "

echo ""
echo "============================="
echo "VM CONFIGURADA COM SUCESSO!"
echo "============================="
echo ""
echo "Softwares instalados:"
echo "Git"
echo "nano"
echo "Azure CLI"
echo "Docker (configurado)"
echo ""
echo "Para conectar via SSH execute:"
echo "ssh $ADMIN_USER@$PUBLIC_IP"
echo ""
echo "Senha: $ADMIN_PASSWORD"
echo ""
echo "============================="
echo "ATENÇÃO: Ao conectar pela primeira vez na VM rode o comando abaixo no terminal:"
echo "newgrp docker"
echo "============================================"
