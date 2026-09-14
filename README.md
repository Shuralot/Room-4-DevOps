# CI/CD — Room 4 DevOps

[![CI](https://github.com/Shuralot/Room-4-DevOps/actions/workflows/ci.yml/badge.svg)](https://github.com/Shuralot/Room-4-DevOps/actions/workflows/ci.yml)

## 👥 Membros da Equipe
- **@Shuralot** (Owner) Júlio
-  **@jfredericocavalcanti**
- **@gustavolucen4**

---

## 🚀 Pipeline de CI (Integração Contínua)

O pipeline foi construído no **GitHub Actions** (`.github/workflows/ci.yml`) atuando como um **Quality Gate** que impede código quebrado ou vulnerável de entrar na branch principal (`main`).

### 🛡️ Quality Gates Implementados
1. **Linting (`ruff`)**: Análise estática de código e formatação.
2. **Matrix de Testes (`pytest`)**: Execução paralela em Python `3.10`, `3.11` e `3.12` com `fail-fast: false`.
3. **Dependency Cache**: Cache de dependências `pip` (`~/.cache/pip`) para acelerar a execução dos PRs.
4. **Reusable Workflow (`_reusable-test.yml`)**: Isolamento e reutilização dos steps de teste via `workflow_call`.
5. **Auditoria de CVEs (`pip-audit`)**: Verificação de vulnerabilidades conhecidas em dependências Python.
6. **Container & Filesystem Security Scan (`trivy`)**: Análise de vulnerabilidades do sistema com severidade `HIGH` e `CRITICAL`.
7. **Environment com Required Reviewer**: Deploy protegido em ambiente `staging` que aguarda aprovação manual.
8. **Segurança do Pipeline**:
   - Menor privilégio explícito (`permissions: contents: read`).
   - Pinning de Actions por commit SHA imutável.
9. **Build & Push Docker Hub**: Publicação automática com tags `latest` e hash curto do commit.
10. **Notificações**: Webhook automático reportando sucesso ou falha no canal do time.

---

## 💻 Como Rodar os Gates Localmente

Para validar antes de abrir um Pull Request:

```bash
# 1. Criar e ativar ambiente virtual
python -m venv .venv
# Windows:
.venv\Scripts\activate
# Linux/macOS:
# source .venv/bin/activate

# 2. Instalar dependências
pip install -r requirements.txt -r requirements-dev.txt

# 3. Executar os gates locais
ruff check .
pytest -v
pip-audit -r requirements.txt