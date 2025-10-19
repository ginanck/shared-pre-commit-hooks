# Shared Pre-commit Hooks

A collection of shared pre-commit configurations and development tools for consistent code quality across projects.

## Purpose

This repository aims to standardize and streamline code quality practices across different project types by providing:

🎯 **Consistent Quality Standards**: Pre-configured hooks that enforce coding standards, security practices, and formatting rules across all your projects.

🔧 **Ready-to-Use Configurations**: Drop-in `.pre-commit-config.yml` files for popular technology stacks (Ansible, OpenTofu/Terraform, Python) that work out of the box.

⚡ **Developer Productivity**: Eliminate the need to research, configure, and maintain pre-commit hooks for each new project. Simply download and use.

🛡️ **Security by Default**: Integrated security scanning tools like `gitleaks` and `hadolint` to catch vulnerabilities before they reach your repository.

🌍 **Multi-Technology Support**: Comprehensive tool management via `mise.toml` that covers infrastructure as code, containerization, security, and general development tools.

Whether you're working on personal projects or enterprise applications, these shared configurations ensure that code quality checks are consistent, comprehensive, and easy to implement across your entire development workflow.

## Auto-Release System

This repository features automatic versioning and release creation through GitHub Actions. When PRs are merged to the `master` branch:

🔄 **Automatic Version Increment**: Based on PR title/labels

- `feat`, `feature`, `minor` → Minor release (v1.0.0 → v1.1.0)
- `major`, `breaking` → Major release (v1.0.0 → v2.0.0)  
- Everything else → Patch release (v1.0.0 → v1.0.1)

🏷️ **Auto-Generated Tags & Releases**: Creates git tags and GitHub releases with changelog

**Example PR titles:**

- `feat: add new security hooks` → v1.1.0
- `fix: resolve ansible-lint issue` → v1.0.1
- `major: breaking change to hook structure` → v2.0.0

## Table of Contents

- [Auto-Release System](#auto-release-system)
- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
  - [Install pyenv](#install-pyenv)
  - [Setup Python Environment](#setup-python-environment)
  - [Install mise](#install-mise)
  - [Install Development Tools](#install-development-tools)
- [Usage](#usage)
  - [Quick Setup (One-liner)](#quick-setup-one-liner)
  - [Manual Download (Alternative Method)](#manual-download-alternative-method)
  - [Install Pre-commit](#install-pre-commit)
  - [Run Hooks](#run-hooks)
- [Available Configurations](#available-configurations)

---

## Prerequisites

Before setting up the development environment, install the required system dependencies.

### macOS

```bash
# Install Xcode command line tools
xcode-select --install

# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required packages
brew install openssl readline sqlite3 xz zlib tcl-tk
```

### Fedora/RHEL/CentOS

```bash
dnf install make gcc zlib-devel bzip2 bzip2-devel readline-devel \
    sqlite sqlite-devel openssl-devel tk-devel libffi-devel \
    xz-devel libuuid-devel gdbm-devel libnsl2-devel
```

### Ubuntu/Debian

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils \
    tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev -y
```

---

## Environment Setup

### Install pyenv

Install pyenv to manage Python versions:

```bash
curl https://pyenv.run | bash
```

Add pyenv to your shell profile:

**For Bash:**

```bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
```

**For Zsh:**

```bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
```

Reload your shell:

```bash
exec $SHELL
```

### Setup Python Environment

Install Python 3.9.21 and create a virtual environment:

```bash
# Install Python 3.9.21
pyenv install 3.9.21

# Install pyenv-virtualenv plugin (if not already installed)
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv

# Create virtual environment
pyenv virtualenv 3.9.21 venv

# Activate virtual environment
pyenv activate venv
```

### Install mise

Install mise for managing development tools:

```bash
curl https://mise.run | sh
```

Add mise to your shell profile:

**For Bash:**

```bash
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
```

**For Zsh:**

```bash
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
```

Reload your shell:

```bash
exec $SHELL
```

### Install Development Tools

Clone this repository and install all required tools:

```bash
# Clone the repository
git clone https://github.com/ginanck/shared-pre-commit-hooks.git
cd shared-pre-commit-hooks

# Trust the mise.toml file first
mise trust

# Install all tools from mise.toml
mise install

# Install Python packages
pip install -r requirements.txt
```

---

## Usage

### Quick Setup (One-liner)

For automated setup of configurations and dependencies:

**For Ansible projects:**

```bash
curl -fsSL https://raw.githubusercontent.com/ginanck/shared-pre-commit-hooks/refs/heads/master/scripts/setup-config.sh | bash -s ansible
```

**For Terraform/OpenTofu projects:**

```bash
curl -fsSL https://raw.githubusercontent.com/ginanck/shared-pre-commit-hooks/refs/heads/master/scripts/setup-config.sh | bash -s terraform
```

### Install Pre-commit

Install pre-commit hooks in your repository:

```bash
# Install pre-commit hooks
pre-commit install

# Install commit message hooks (optional)
pre-commit install --hook-type commit-msg
```

### Run Hooks

Execute pre-commit hooks manually:

```bash
# Run all hooks on all files
pre-commit run --all-files

# Run specific hook on all files
pre-commit run ansible-lint --all-files
pre-commit run terraform_fmt --all-files

# Run hooks on staged files only
pre-commit run

# Run specific hook on specific files
pre-commit run flake8 --files path/to/file.py
```

---

## Available Configurations

This repository provides pre-configured setups for different project types:

### Ansible Configuration

- **ansible-lint**: Linting for Ansible playbooks and roles
- **yamllint**: YAML file validation
- **trailing-whitespace**: Remove trailing whitespace
- **end-of-file-fixer**: Ensure files end with newline

### OpenTofu/Terraform Configuration

- **terraform_fmt**: Format Terraform files
- **terraform_validate**: Validate Terraform syntax
- **terraform_docs**: Generate documentation
- **tflint**: Terraform linting
- **checkov**: Security scanning for Infrastructure as Code

### Python Configuration

Available in `configs/python/`:

- **flake8**: Python linting (configured in `flake8.conf`)
- **black**: Code formatting
- **isort**: Import sorting
- **pyproject.toml**: Modern Python project configuration

### Custom Configurations

You can also use the individual configuration files in the `configs/` directory:

- `configs/ansible-lint.yml`
- `configs/yamllint.yml`
- `configs/flake8.conf`
- `configs/pyproject.toml`

### Pre-commit Configuration Exclusions

To prevent pre-commit hooks from linting their own configuration files (which can cause circular validation issues), the following exclusions are built into the configurations:

**Files excluded from linting:**

- `.pre-commit-config.yaml` (main pre-commit configuration)
- `.pre-commit-config*.yaml` (variant configurations)
- `.pre-commit-hooks.yaml` (hook definitions)

**Affected hooks:**

- `ansible-lint`: Excluded via `exclude_paths` in `configs/ansible-lint.yml`
- `yamllint`: Excluded via `ignore` pattern in `configs/yamllint.yml`
- `trailing-whitespace`: Excluded via `exclude` pattern in example configurations

This prevents common issues like:

- YAML linting errors on pre-commit config formatting
- Trailing whitespace checks modifying pre-commit configs
- Ansible-lint attempting to parse non-Ansible YAML files

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
