# ☁️ Terraform Azure Dev Environment

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![IaC](https://img.shields.io/badge/IaC-Infrastructure%20as%20Code-success)](https://en.wikipedia.org/wiki/Infrastructure_as_code)

> **Seu ambiente de desenvolvimento completo na Azure em um único comando.** 🚀

Provisione uma VM Linux na Azure totalmente configurada com Docker, VS Code Server, Node.js, Python, Go, Terraform e Azure CLI — tudo automatizado com Terraform e boas práticas de IaC.

---

## 📐 Arquitetura

```
┌──────────────────────────────────────────────────────────────────┐
│                     Azure Cloud                                  │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │              Resource Group (my-dev-env-dev-rg)            │  │
│  │                                                            │  │
│  │  ┌─────────────────────────────────────────────────────┐   │  │
│  │  │           VNet (10.0.0.0/16)                        │   │  │
│  │  │                                                     │   │  │
│  │  │  ┌──────────────────────┐  ┌─────────────────────┐  │   │  │
│  │  │  │  Public Subnet       │  │  Private Subnet     │  │   │  │
│  │  │  │  10.0.1.0/24         │  │  10.0.2.0/24        │  │   │  │
│  │  │  │                      │  │                     │  │   │  │
│  │  │  │  ┌────────────────┐  │  │  (Future expansion) │  │   │  │
│  │  │  │  │  Linux VM      │  │  │                     │  │   │  │
│  │  │  │  │  Standard_B2s  │  │  │                     │  │   │  │
│  │  │  │  │                │  │  │                     │  │   │  │
│  │  │  │  │  🐳 Docker     │  │  │                     │  │   │  │
│  │  │  │  │  📝 VS Code    │  │  │                     │  │   │  │
│  │  │  │  │  🟢 Node.js    │  │  │                     │  │   │  │
│  │  │  │  │  🐍 Python     │  │  │                     │  │   │  │
│  │  │  │  │  🔵 Go         │  │  │                     │  │   │  │
│  │  │  │  │  🏗️ Terraform  │  │  │                     │  │   │  │
│  │  │  │  │  ☁️ Azure CLI   │  │  │                     │  │   │  │
│  │  │  │  └───────┬────────┘  │  │         │           │  │   │  │
│  │  │  │          │           │  └─────────┼───────────┘  │   │  │
│  │  │  └──────────┼───────────┘            │              │   │  │
│  │  │             │                 ┌──────┴──────┐       │   │  │
│  │  │      ┌──────┴──────┐         │ NAT Gateway │       │   │  │
│  │  │      │  Public IP  │         └─────────────┘       │   │  │
│  │  │      └──────┬──────┘                                │   │  │
│  │  └─────────────┼──────────────────────────────────────┘   │  │
│  │                │                                           │  │
│  │    ┌───────────┴────────────┐                              │  │
│  │    │  Network Security Group│                              │  │
│  │    │  :22   SSH             │                              │  │
│  │    │  :8080 VS Code Server  │                              │  │
│  │    │  :3000 Node/React      │                              │  │
│  │    │  :8000 Django/FastAPI   │                              │  │
│  │    │  :8443 HTTPS           │                              │  │
│  │    └───────────┬────────────┘                              │  │
│  └────────────────┼───────────────────────────────────────────┘  │
│                   │                                              │
└───────────────────┼──────────────────────────────────────────────┘
                    │
              ┌─────┴─────┐
              │ Internet  │
              └───────────┘
```

---

## 🛠️ Ferramentas Instaladas

| Ferramenta | Versão | Descrição |
|------------|--------|-----------|
| 🐳 Docker + Compose | Latest + v2 | Containerização e orquestração |
| 📝 VS Code Server | Latest | IDE no navegador (porta 8080) |
| 🟢 Node.js | 20 LTS | Runtime JavaScript |
| 🐍 Python 3 | + pip + venv | Desenvolvimento Python |
| 🔵 Go | 1.22.4 | Linguagem Go |
| 🏗️ Terraform | Latest | Infrastructure as Code |
| ☁️ Azure CLI | Latest | Interface de linha de comando Azure |
| 🔧 Git | Pré-configurado | Controle de versão |
| 📊 htop, jq, tree | Latest | Ferramentas utilitárias |

---

## 🚀 Quick Start

### Pré-requisitos

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) instalado e autenticado (`az login`)
- Uma **Subscription ID** do Azure
- Par de chaves SSH (`~/.ssh/id_rsa.pub`)

### 1. Clone o repositório

```bash
git clone https://github.com/SEU_USUARIO/terraform-azure-dev-environment.git
cd terraform-azure-dev-environment
```

### 2. Configure as variáveis

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edite o `terraform.tfvars` com seus valores:

```hcl
# Azure Subscription
subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# ⚠️ IMPORTANTE: Restrinja ao seu IP para segurança!
# Descubra seu IP: curl ifconfig.me
allowed_ssh_cidr = "SEU_IP/32"

# Configuração Git
git_user_name  = "Seu Nome"
git_user_email = "seu@email.com"
```

### 3. Autentique no Azure

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### 4. Deploy

```bash
# Inicializar o Terraform
make init

# Visualizar as mudanças
make plan

# Aplicar a infraestrutura
make apply
```

### 5. Acesse seu ambiente

```bash
# Ver os outputs
make output

# Acessar via SSH
make ssh

# Ou acesse o VS Code Server no navegador
# http://<vm-public-ip>:8080
```

> 💡 **Dica:** A senha do VS Code Server está em `/home/azuredev/.config/code-server/config.yaml` na VM. Acesse com:
> ```bash
> ssh azuredev@<IP> cat ~/.config/code-server/config.yaml
> ```

### 6. Destruir (quando terminar)

```bash
make destroy
```

---

## 📁 Estrutura do Projeto

```
terraform-azure-dev-environment/
├── main.tf                          # Módulo raiz - Resource Group + módulos
├── variables.tf                     # Variáveis de entrada do projeto
├── outputs.tf                       # Outputs (IP, SSH, VS Code URL)
├── versions.tf                      # Terraform >= 1.5 + azurerm ~> 4.0
├── terraform.tfvars.example         # Exemplo de configuração
├── Makefile                         # Comandos automatizados
├── .gitignore                       # Arquivos ignorados pelo Git
├── LICENSE                          # Licença MIT
├── README.md                        # Este arquivo
└── modules/
    ├── networking/                   # Módulo de rede
    │   ├── main.tf                  # VNet, subnets, NSG, NAT Gateway
    │   ├── variables.tf             # Variáveis de rede
    │   └── outputs.tf               # Outputs de rede
    └── compute/                     # Módulo de computação
        ├── main.tf                  # VM, NIC, Public IP
        ├── variables.tf             # Variáveis de computação
        ├── outputs.tf               # Outputs de computação
        └── scripts/
            └── user_data.sh         # Cloud-init bootstrap script
```

---

## ⚙️ Variáveis

| Variável | Tipo | Default | Descrição |
|----------|------|---------|-----------|
| `subscription_id` | string | — | ID da subscription Azure **(obrigatório)** |
| `location` | string | `eastus` | Região Azure |
| `project_name` | string | `dev-environment` | Nome do projeto |
| `environment` | string | `dev` | Ambiente |
| `vnet_address_space` | string | `10.0.0.0/16` | Address space da VNet |
| `public_subnet_prefix` | string | `10.0.1.0/24` | Prefixo da subnet pública |
| `private_subnet_prefix` | string | `10.0.2.0/24` | Prefixo da subnet privada |
| `allowed_ssh_cidr` | string | `*` | CIDR permitido para acesso |
| `vm_size` | string | `Standard_B2s` | Tamanho da VM |
| `disk_size_gb` | number | `30` | Tamanho do disco OS (GB) |
| `admin_username` | string | `azuredev` | Usuário admin da VM |
| `public_key_path` | string | `~/.ssh/id_rsa.pub` | Caminho da chave pública SSH |
| `git_user_name` | string | `Developer` | Nome para config do Git |
| `git_user_email` | string | `dev@example.com` | Email para config do Git |

---

## 📤 Outputs

| Output | Descrição |
|--------|-----------|
| `resource_group_name` | Nome do Resource Group |
| `vm_public_ip` | IP público da VM |
| `vscode_server_url` | URL do VS Code Server |
| `ssh_command` | Comando SSH pronto para usar |
| `vnet_id` | ID da VNet criada |
| `vm_name` | Nome da VM |

---

## 💰 Estimativa de Custos

| Recurso | Custo Estimado (East US) |
|---------|--------------------------|
| VM Standard_B2s (2 vCPU, 4GB RAM) | ~$30.37/mês |
| Premium SSD 30GB (P4) | ~$5.28/mês |
| Public IP (Static/Standard) | ~$3.65/mês |
| NAT Gateway | ~$32.40/mês |
| **Total estimado** | **~$71.70/mês** |

> 💡 **Dica:** Destrua o ambiente quando não estiver usando: `make destroy`

> 💡 **Alternativa econômica:** Use `Standard_B1s` (~$7.59/mês) para tarefas leves, ou remova o NAT Gateway se não precisar da subnet privada (-$32/mês).

---

## 🔒 Boas Práticas de Segurança

Este projeto implementa:

- ✅ **Autenticação somente SSH** — Senha desabilitada
- ✅ **Disco Premium criptografado** — Dados em repouso protegidos
- ✅ **NSG restritivo** — Apenas portas necessárias abertas
- ✅ **Subnet privada** — Preparada para workloads isolados
- ✅ **NAT Gateway** — Acesso à internet sem exposição
- ✅ **Resource Group dedicado** — Isolamento de recursos

> ⚠️ **IMPORTANTE:** Sempre restrinja `allowed_ssh_cidr` ao seu IP público (`SEU_IP/32`). Nunca use `*` em produção!

---

## 🧰 Makefile Commands

```bash
make help      # Lista todos os comandos disponíveis
make init      # Inicializa o Terraform
make plan      # Mostra o plano de execução
make apply     # Aplica a infraestrutura
make destroy   # Destrói toda a infraestrutura
make fmt       # Formata os arquivos .tf
make validate  # Valida a configuração
make output    # Mostra os outputs
make ssh       # Conecta via SSH na VM
make clean     # Remove arquivos locais do Terraform
```

---

## 🔄 Recursos Azure Provisionados

| Recurso | Tipo Azure | Descrição |
|---------|-----------|-----------|
| Resource Group | `azurerm_resource_group` | Container lógico para todos os recursos |
| Virtual Network | `azurerm_virtual_network` | Rede virtual isolada |
| Public Subnet | `azurerm_subnet` | Subnet para recursos com acesso público |
| Private Subnet | `azurerm_subnet` | Subnet para recursos isolados |
| NSG | `azurerm_network_security_group` | Firewall de rede (5 regras) |
| NAT Gateway | `azurerm_nat_gateway` | Acesso à internet para subnet privada |
| Public IP (VM) | `azurerm_public_ip` | IP estático para a VM |
| Public IP (NAT) | `azurerm_public_ip` | IP estático para o NAT Gateway |
| NIC | `azurerm_network_interface` | Interface de rede da VM |
| Linux VM | `azurerm_linux_virtual_machine` | Ubuntu 24.04 LTS |

---

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -m 'feat: adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 🌟 Se este projeto te ajudou, deixe uma ⭐!

<p align="center">
  <b>Feito com ❤️ e Terraform</b>
</p>
