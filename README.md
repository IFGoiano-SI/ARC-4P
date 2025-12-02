# Laboratório de Redes - IFGoiano

Projeto de simulação de uma rede completa usando Docker, desenvolvido para fins educacionais no Instituto Federal Goiano.

## 📋 Sobre o Projeto

Este laboratório simula uma infraestrutura de rede empresarial completa com todos os serviços essenciais: DHCP, DNS, Web, FTP e NFS. Ideal para estudar e testar configurações de rede em um ambiente isolado e controlado.

## 🏗️ Topologia da Rede

```
Internet (Bridge Docker)
        |
   [ROUTER/GATEWAY]
   (198.18.0.254)
        |
    ┌───┴───────────────────────────────┐
    │   Rede Interna (198.18.0.0/24)   │
    └───┬───────────────────────────────┘
        │
        ├── DHCP Server    (198.18.0.10)
        ├── DNS Server     (198.18.0.11)
        ├── Web Server     (198.18.0.12)
        ├── FTP Server     (198.18.0.13)
        ├── NFS Server     (198.18.0.14)
        └── Cliente        (IP dinâmico via DHCP)
```

## 🐳 Serviços Docker

### 1. **Router/Gateway** (`router-gateway`)
- **Função:** Roteador principal que conecta a rede interna à internet
- **IP:** `198.18.0.254`
- **Por quê?** Simula um roteador real, fazendo NAT (mascaramento) para permitir que máquinas da rede interna acessem a internet
- **Tecnologia:** Ubuntu com iptables configurado para encaminhamento de pacotes

### 2. **DHCP Server** (`dhcp-server`)
- **Função:** Distribui IPs automaticamente para os clientes da rede
- **IP:** `198.18.0.10`
- **Por quê?** Essencial em qualquer rede para gerenciar endereços IP automaticamente, evitando conflitos e facilitando a administração
- **Configuração:** 
  - Range de IPs: `198.18.0.100` a `198.18.0.150`
  - Gateway padrão: `198.18.0.254`
  - DNS: `198.18.0.11`

### 3. **DNS Server** (`dns-server`)
- **Função:** Resolve nomes de domínio para endereços IP
- **IP:** `198.18.0.11`
- **Por quê?** Permite usar nomes amigáveis (como `web`) ao invés de decorar IPs. Fundamental em qualquer rede
- **Domínio:** `lab`
- **Registros:**
  - `dns` → `198.18.0.11`
  - `web` → `198.18.0.12`
  - `ftp` → `198.18.0.13`
  - `nfs` → `198.18.0.14`

### 4. **Web Server** (`web-server`)
- **Função:** Servidor HTTP usando Apache
- **IP:** `198.18.0.12`
- **Por quê?** Simula um servidor web real para hospedar sites e aplicações web. Essencial para entender como funcionam servidores HTTP
- **Acesso:** `http://web` ou `http://198.18.0.12`

### 5. **FTP Server** (`ftp-server`)
- **Função:** Servidor de transferência de arquivos
- **IP:** `198.18.0.13`
- **Por quê?** Demonstra como funciona o protocolo FTP para upload/download de arquivos em redes
- **Credenciais:**
  - Usuário: `ifgoiano`
  - Senha: `123`
- **Pasta compartilhada:** `./ftp_data`
 - **Portas expostas (host):** `21` (controle) e `30000-30059` (passivo)

### 6. **NFS Server** (`nfs-server`)
- **Função:** Compartilhamento de arquivos em rede (Network File System)
- **IP:** `198.18.0.14`
- **Por quê?** Permite que múltiplos clientes acessem os mesmos arquivos simultaneamente, como se fossem locais. Muito usado em ambientes Linux
- **Pasta compartilhada:** `./nfs_data`
 - **Porta exposta (host):** `2049` (NFSv4)

### 7. **Cliente** (`cliente`)
- **Função:** Máquina cliente que usa todos os serviços da rede
- **IP:** Dinâmico (obtido via DHCP)
- **Por quê?** Representa um computador comum na rede, permitindo testar todos os serviços do ponto de vista do usuário final
- **Ferramentas instaladas:** ping, curl, nslookup, lftp, mount (NFS), traceroute

## 🚀 Como Usar

### Iniciar o Laboratório
```bash
docker-compose up -d
```

> Observação: nas versões mais novas do Docker pode ser necessário usar `docker compose` (sem hífen).

### Acessar o Cliente
```bash
docker exec -it cliente bash
```

### Testar os Serviços

**1. Testar DNS:**
```bash
nslookup web
nslookup ftp
```

**2. Testar Web Server:**
```bash
curl http://web
curl http://198.18.0.12
```

**3. Testar FTP:**
```bash
lftp ifgoiano:123@ftp
# ou use o script
bash /root/login_ftp.sh
```

**4. Montar NFS:**
```bash
mount -t nfs nfs:/exports /mnt/nfs
# ou use o script
bash /root/mount_nfs.sh
```

### Acessar FTP e NFS a partir do host

Com o `docker-compose.yml` atual, as portas dos serviços também estão abertas no host.

**FTP (a partir do host):**

```bash
lftp ifgoiano:123@localhost:21
```

Se estiver usando um cliente gráfico de FTP, configure:
- Host: `localhost`
- Porta: `21`
- Usuário: `ifgoiano`
- Senha: `123`
- Modo: Passivo (usa as portas `30000-30059` já mapeadas)

**NFS (a partir do host Linux):**

```bash
sudo mkdir -p /mnt/nfs-lab
sudo mount -t nfs4 localhost:/exports /mnt/nfs-lab
```

Depois de usar:

```bash
sudo umount /mnt/nfs-lab
```

**5. Verificar IP obtido via DHCP:**
```bash
ip addr show eth0
```

**6. Testar conectividade:**
```bash
ping web
ping 8.8.8.8  # Testa saída para internet
traceroute web
```

### Parar o Laboratório
```bash
docker-compose down
```

### Parar e Limpar Tudo
```bash
docker-compose down -v
```

## 📂 Estrutura de Arquivos

```
lab/
├── docker-compose.yml          # Orquestração de todos os containers
├── dhcp/
│   ├── dhcp.conf              # Configuração do servidor DHCP
│   └── dhcpd.leases           # Registros de IPs concedidos
├── bind/
│   ├── named.conf.local       # Zonas DNS
│   ├── named.conf.options     # Opções do BIND
│   └── db                 # Registros da zona 'lab'
├── ftp_data/                  # Arquivos compartilhados via FTP
├── nfs_data/                  # Arquivos compartilhados via NFS
├── exports                    # Configuração de exportação NFS
├── mount_nfs.sh              # Script para montar NFS no cliente
└── login_ftp.sh              # Script para conectar ao FTP
```

## 🎓 Objetivos de Aprendizado

Este laboratório permite estudar:
- Configuração de servidores DHCP e distribuição de IPs
- Funcionamento de servidores DNS e resolução de nomes
- Roteamento de pacotes e NAT
- Configuração de servidores web (Apache)
- Protocolos de transferência de arquivos (FTP e NFS)
- Interação entre diferentes serviços de rede
- Diagnóstico de rede usando ferramentas como ping, nslookup e traceroute

## 📝 Notas

- Todos os serviços estão na mesma sub-rede `198.18.0.0/24`
- O router faz NAT permitindo acesso à internet
- Os clientes obtêm IP automaticamente via DHCP
- DNS configurado para resolver nomes dentro do domínio ``
- Ambiente totalmente isolado e seguro para experimentação

---

**Desenvolvido para fins educacionais - IFGoiano**
