# Shared Pre-commit Hooks

Ready-to-use pre-commit configurations for Ansible, Terraform, Python, Docker, and Shell projects. Includes security scanning, linting, and formatting tools with consistent configurations.

## Table of Contents

- [Quick Start](#quick-start)
- [Usage Methods](#usage-methods)
- [Available Hooks](#available-hooks)
- [Updating](#updating)

## Quick Start

Install pre-commit and the required tools in your project:

```bash
# Install pre-commit
pip install pre-commit

# The hooks require these tools to be installed:
# - For security: gitleaks, ripsecrets
# - For Ansible: ansible-lint, yamllint
# - For Python: flake8, black, isort
# - For Docker: hadolint
# - For Shell: shellcheck
# Install them via your package manager (brew, apt, dnf) or mise

# Install the git hooks
pre-commit install
```

## Usage Methods

This repository can be used in **two ways**:

### Method 1: As a Shared Pre-commit Repository

Reference this repository directly in your project's `.pre-commit-config.yaml` file. This method keeps your project lightweight and always uses the hook definitions from this repository.

**Example `.pre-commit-config.yaml` for Ansible projects:**

```yaml
repos:
  # First, download the Ansible linter config files (run once)
  - repo: https://github.com/ginanck/shared-pre-commit-hooks
    rev: v1.0.0  # Use specific version tag
    hooks:
      - id: download-configs-ansible

  # Then use the hooks from this shared repository
  - repo: https://github.com/ginanck/shared-pre-commit-hooks
    rev: v1.0.0
    hooks:
      - id: ansible-lint
      - id: yamllint
      - id: gitleaks
      - id: flake8
      - id: black
```

**Example for Terraform/OpenTofu projects:**

```yaml
repos:
  # First, download the Terraform linter config files (run once)
  - repo: https://github.com/ginanck/shared-pre-commit-hooks
    rev: v1.0.0
    hooks:
      - id: download-configs-terraform

  # Then use the hooks from this shared repository
  - repo: https://github.com/ginanck/shared-pre-commit-hooks
    rev: v1.0.0
    hooks:
      - id: terraform-fmt
      - id: tflint
      - id: gitleaks
      - id: hadolint
```

**Available hook IDs:**

**Configuration Management:**
- `download-configs-ansible` - Downloads Ansible/YAML linter config files
- `download-configs-terraform` - Downloads Terraform/OpenTofu linter config files

**Security Scanning:**
- `gitleaks` - Detects secrets in staged files (standard pre-commit usage)
- `gitleaks-commit-history` - Scans entire git commit history for secrets
- `gitleaks-current-directory` - Scans current directory for secrets
- `ripsecrets` - Fast secret scanner for credentials

**Ansible/YAML:**
- `ansible-lint` - Lints Ansible playbooks for best practices
- `yamllint` - Validates YAML syntax and formatting
- `docsible` - Generates documentation for Ansible roles

**Python:**
- `flake8` - Python linting and style checking
- `black` - Python code auto-formatting
- `isort` - Python import sorting

**Terraform/OpenTofu:**
- `terraform-fmt` - Formats Terraform/OpenTofu files
- `tflint` - Lints Terraform/OpenTofu code

**Docker:**
- `hadolint` - Lints Dockerfiles (strict)
- `hadolint-with-ignores` - Lints Dockerfiles with common rules ignored

**Shell:**
- `shellcheck` - Finds bugs in shell scripts

**Setup steps:**

```bash
# 1. Create .pre-commit-config.yaml in your project (as shown above)

# 2. Install pre-commit
pip install pre-commit

# 3. Install the hooks
pre-commit install

# 4. Download config files (one-time setup)
# For Ansible projects:
pre-commit run download-configs-ansible --hook-stage manual
# For Terraform projects:
pre-commit run download-configs-terraform --hook-stage manual

# 5. Run all hooks
pre-commit run --all-files
```

**Updating:**

```bash
# Update to latest version of this repository
pre-commit autoupdate

# Re-download config files if needed
pre-commit run download-configs-ansible --hook-stage manual  # for Ansible
pre-commit run download-configs-terraform --hook-stage manual  # for Terraform
```

### Method 2: Download Configs Locally

Download configuration files and use them with local pre-commit hooks. This method copies the configs to your project.

**For Ansible projects:**

```bash
curl -fsSL https://raw.githubusercontent.com/ginanck/shared-pre-commit-hooks/master/scripts/setup-config.sh | bash -s ansible
```
Reference as Shared Repository (Recommended)

Create `.pre-commit-config.yaml` in your project:

**For Ansible projects:**
```yaml
repos:
  - repo: https://github.com/ginanck/shared-pre-commit-hooks
    rev: v1.0.0
    hooks:
      - id: download-configs-ansible  # Run once to download configs
  - repo: https://github.com/ginanck/shared-pre-commit-hooks
    rev: v1.0.0
    hooks:
      - id: ansible-lint
      - id: yamllint
      - id: gitleaks
```

**For Terraform projects:**
```yaml
repos:
  - repo: https://github.com/ginanck/shared-pre-commit-hooks
    rev: master
    hooks:
      - id: download-configs-terraform
      - id: gitleaks-commit-history
      - id: gitleaks-current-directory

  # OpenTofu
  - repo: https://github.com/tofuutils/pre-commit-opentofu
    rev: v2.2.1
    hooks:
      - id: tofu_fmt
        name: tofu_fmt
        description: Formats OpenTofu configuration files to ensure consistent style and readability
      - id: tofu_validate
        name: tofu_validate
        description: Validates OpenTofu configuration files for syntax errors and internal consistency
```

**For Python projects:**
```yaml
repos:
  - repo: https://github.com/ginanck/shared-pre-commit-hooks
    rev: v1.0.0
    hooks:
      - id: flake8
      - id: black
      - id: isort
      - id: gitleaks
```

Run the setup:
```bash
pre-commit install
pre-commit run download-configs-ansible --hook-stage manual  # or download-configs-terraform
pre-commit run --all-files
```

Update hooks:
```bash
pre-commit autoupdate
**For Ansible projects:**

```bash
curl -fsSL https://raw.githubusercontent.com/ginanck/shared-pre-commit-hooks/master/scripts/setup-config.sh | bash -s ansible
```

**For Terraform/OpenTofu projects:**

```bash
curl -fsSL https://raw.githubusercontent.com/ginanck/shared-pre-commit-hooks/master/scripts/setup-config.sh | bash -s terraform
```

---

## Quick Commands Reference

```bash
# Check available Python versions
pyenv install -l

# List installed Python versions
pyenv versions

# Switch Python versions
pyenv shell <version>    # Current shell session
pyenv local <version>    # Current directory
pyenv global <version>   # Global default

# Virtual environment management
pyenv virtualenv <python_version> <env_name>
pyenv virtualenvs        # List environments
pyenv activate <env_name>
pyenv deactivate

# Pre-commit useful commands
pre-commit autoupdate    # Update hook versions
pre-commit clean         # Clean cached repositories
pre-commit sample-config # Generate sample config
```

---

## Contributing

Feel free to submit issues and pull requests to improve these shared configurations.

## License

See [LICENSE](LICENSE) for details.
s directly to your project:

```bash
# For Ansible
curl -fsSL https://raw.githubusercontent.com/ginanck/shared-pre-commit-hooks/master/scripts/setup-config.sh | bash -s ansible

# For Terraform
curl -fsSL https://raw.githubusercontent.com/ginanck/shared-pre-commit-hooks/master/scripts/setup-config.sh | bash -s terraform

# Install and run
pre-commit install
pre-commit run --all-files
```

Update configs:
```bash## Available Hooks

**Security**
- `gitleaks` - Detect secrets in staged files
- `gitleaks-commit-history` - Scan entire git history for secrets
- `gitleaks-current-directory` - Scan current directory for secrets
- `ripsecrets` - Fast credential scanner

**Ansible/YAML**
- `ansible-lint` - Lint Ansible playbooks
- `yamllint` - Validate YAML files
- `docsible` - Generate Ansible role documentation

**Python**
- `flake8` - Python linting
- `black` - Code formatting
- `isort` - Import sorting

**Docker**
- `hadolint` - Dockerfile linter (strict)
- `hadolint-with-ignores` - Dockerfile linter (relaxed)

**Shell**
- `shellcheck` - Shell script linter

**Configuration**
- `download-configs-ansible` - Download Ansible linter configs
- `download-configs-terraform` - Download Terraform linter config## Updating

**Method 1 (Shared Repository):**
```bash
pre-commit autoupdate
```

**Method 2 (Local Configs):**
```bash
curl -fsSL https://raw.githubusercontent.com/ginanck/shared-pre-commit-hooks/master/scripts/setup-config.sh | bash -s ansible
# or: bash -s terraform
```

## Contributing

Submit issues and pull requests at [github.com/ginanck/shared-pre-commit-hooks](https://github.com/ginanck/shared-pre-commit-hooks)