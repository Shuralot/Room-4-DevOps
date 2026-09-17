# CI/CD & Cloud Infrastructure — Room 4 DevOps

[![CI](https://github.com/Shuralot/Room-4-DevOps/actions/workflows/ci.yml/badge.svg)](https://github.com/Shuralot/Room-4-DevOps/actions/workflows/ci.yml)
[![Rolling deployment](https://github.com/Shuralot/Room-4-DevOps/actions/workflows/cd.yml/badge.svg)](https://github.com/Shuralot/Room-4-DevOps/actions/workflows/cd.yml)

Repositório unificado de Engenharia de Software / DevOps cobrindo a esteira completa de entrega contínua: desde a validação com Quality Gates (CI), passando por Infrastructure as Code (Terraform & Ansible), até o deploy contínuo em Kubernetes (CD) com estratégia de **Rolling Update e Rollback**.

---

## 👥 Membros da Equipe
- **@Shuralot** Júlio Santos
- **@jfredericocavalcanti** Frederico Cavalcanti
- **@gustavolucen4** Gustavo Lucena Silva
- **@fabalmeida** Felipe Almeida
- **@holandalelis** Pedro Holanda Lelis

---

## 📋 Checklist da Atividade 2 (Lab de CD)

- [x] **Imagem versionada no Docker Hub**: Publicada com a tag do commit (short SHA) e `latest`, autenticada via Access Token.
- [x] **Alvo de deploy alcançável**: Conexão SSH segura do GitHub Actions para a EC2 rodando cluster `kind`.
- [x] **Canal validado**: Workflow `validate-ssh.yml` testando acesso ao cluster e listando namespaces.
- [x] **Manifestos Kubernetes padronizados**: `Deployment`, `Service ClusterIP` e `Ingress` (NGINX) com probes de `readiness` e `liveness`.
- [x] **Pipeline de Rolling Update (`cd.yml`)**: Pin da tag da imagem, `kubectl apply`, espera do `kubectl rollout status` e smoke test com retry via Ingress.
- [x] **Rollback funcional e testado**: Procedimento documentado e demonstrado para reverter a versão com segurança via `kubectl rollout undo` ou reexecução do workflow com a tag anterior.
- [x] **Documentação de Arquitetura**: Decisões técnicas, topologia de rede e trade-offs documentados no README.

---

## 🏗️ Arquitetura de Deploy

A infraestrutura é hospedada em uma instância AWS EC2 executando um cluster **Kubernetes (`kind`)** com controlador **Ingress NGINX** expondo a porta 80 do nó.

```
       [ Developer / Git Push ]
                  │
                  ▼
         [ GitHub Actions ]
       ┌──────────┴──────────┐
       ▼                     ▼
  [ Pipeline CI ]     [ Pipeline CD ]
  • Lint & Tests       • Resolve IP / EC2 State
  • Build Docker       • Pin Image Tag
  • Push DockerHub     • SCP Manifest / SSH kubectl apply
       │                     │
       └────── Docker Hub ───┼────────────────────────────────┐
                             │                                │
                             ▼ (SSH & Ingress)                ▼ (Docker Pull)
             ┌─────────────────────────────────────────────────────────────┐
             │                     AWS EC2 Instance                        │
             │                                                             │
             │   ┌─────────────────────────────────────────────────────┐   │
             │   │                Cluster kind (:80)                   │   │
             │   │             Ingress Controller (nginx)              │   │
             │   └───────────────────────┬─────────────────────────────┘   │
             │                           │                                 │
             │                  Namespace `todolist`                       │
             │                    [Rolling Update]                         │
             │                           │                                 │
             │                     todolist.local                          │
             │                           │                                 │
             │                           ▼                                 │
             │                   Service ClusterIP                         │
             │                           │                                 │
             │                           ▼                                 │
             │                     Pods todolist                           │
             │                                                             │
             └─────────────────────────────────────────────────────────────┘
```

### Topologia do Ambiente no Kubernetes

| Estratégia | Workflow | Namespace | Host (Ingress) | Mecanismo de Deploy |
|---|---|---|---|---|
| **Rolling Update** | `cd.yml` | `todolist` | `todolist.local` | `kubectl apply` no Deployment; Kubernetes substitui pods gradualmente após readiness. |

---

## 🔄 Estratégia de Deploy e Procedimentos de Rollback

### Rolling Update (`cd.yml`)
- **Funcionamento**: Aplica `k8s/todolist.yaml` atualizado com a tag desejada. O Kubernetes sobe a réplica nova, aguarda a verificação da `readinessProbe` em `/healthz`, e somente então remove a versão anterior.
- **Gatilhos**: Automático após sucesso do CI na branch `main` (`workflow_run`), ou manual via `workflow_dispatch`.
- **Smoke Test**: `curl -fsS -H "Host: todolist.local" http://localhost/healthz` contra o ingress do cluster com retries.
- **Rollback**:
  - **Via GitHub Actions**: Executar novamente o workflow `cd.yml` selecionando a `image_tag` da versão estável anterior.
  - **Via CLI na EC2**:
    ```bash
    kubectl rollout undo deployment/todolist -n todolist
    ```

---

## ⚙️ Workflows do Repositório

| Workflow | Arquivo | Disparo | Finalidade |
|---|---|---|---|
| **CI (Integração Contínua)** | `.github/workflows/ci.yml` | Push/PR na `main` ou Manual | Executa lint (`ruff`), matrix de testes (`pytest`), auditorias (`trivy`, `pip-audit`), build e push de tags no Docker Hub. |
| **Validate SSH** | `.github/workflows/validate-ssh.yml` | Manual | Testa canal SSH com a EC2, seleciona contexto do kind e lista namespaces. |
| **Rolling Deployment** | `.github/workflows/cd.yml` | `workflow_run` (após CI) ou Manual | Prepara/liga EC2, injeta tag no manifesto, aplica no namespace `todolist` e valida com smoke test. |
| **Provisionar Infra** | `.github/workflows/provision.yml` | Manual (`apply` ou `destroy`) | Provisionamento de IaC via Terraform e Ansible na AWS. |

---

## 💻 Como Rodar os Checks e a Aplicação Localmente

### 1. Configurar Ambiente Virtual e Dependências
```bash
# Criar ambiente virtual
python -m venv .venv

# Ativar no Windows (PowerShell):
.venv\Scripts\Activate.ps1
# Ativar no Linux/macOS:
# source .venv/bin/activate

# Instalar dependências da aplicação e ferramentas de teste
pip install -r requirements.txt -r requirements-dev.txt
```

### 2. Executar os Gates de Qualidade
```bash
# 1. Análise estática e formatação (Ruff)
ruff check .

# 2. Testes unitários com Pytest
pytest -v

# 3. Auditoria de vulnerabilidades em dependências
pip-audit -r requirements.txt
```

### 3. Rodar a Aplicação Localmente com Docker
```bash
# Build da imagem local
docker build -t app-k8s-todolist:local .

# Execução do container
docker run -d -p 5000:5000 -e APP_PORT=5000 -e APP_COLOR=purple app-k8s-todolist:local

# Testar endpoint de saúde
curl http://localhost:5000/healthz
```

---

## 🌐 Como Acessar a Aplicação pelo Navegador

Para acessar a aplicação hospedada na EC2 pelo navegador, adicione o mapeamento do host apontando para o IP público da sua EC2:

- **Linux/macOS**: `/etc/hosts`
- **Windows**: `C:\Windows\System32\drivers\etc\hosts` (como Administrador)

```text
<IP_PUBLICO_EC2> todolist.local
```

URL disponível:
- **Aplicação**: `http://todolist.local/` (UI Roxa)

---

## 🧠 Decisões Técnicas e Trade-offs

1. **Roteamento por Host e Service ClusterIP**:
   - Em vez de abrir múltiplas portas no Security Group da AWS via `NodePort`, todo o tráfego externo entra exclusivamente pela porta 80 via **Ingress NGINX**. Os pods comunicam-se internamente via `ClusterIP`.
2. **Persistência com SQLite em `emptyDir`**:
   - Escolha didática e deliberada: cada pod possui seu próprio banco efêmero em `/data/todos.db`. Por esse motivo, a estratégia **Canary não foi adotada**, pois balancear tráfego entre pods com bancos de dados isolados causaria inconsistência de dados entre requisições consecutivas.
3. **Automação e Resiliência de Infraestrutura**:
   - O pipeline `cd.yml` verifica ativamente se a instância EC2 do laboratório está parada (`stopped`), ligando-a automaticamente e obtendo o novo IP público dinâmico antes de iniciar a entrega.
4. **Segurança e Higiene**:
   - Pipelines operam com privilégios mínimos (`permissions: contents: read`), chaves SSH e senhas gerenciadas via GitHub Secrets, e actions de terceiros fixadas por commit SHA imutável.
