#!/bin/bash

# Setup script for shared pre-commit configuration files
# This script downloads the latest configuration files from the repository
# Usage: ./setup-config.sh [ansible|terraform|opentofu]

set -euo pipefail

# Configuration
REPO_URL="https://api.github.com/repos/ginanck/shared-pre-commit-hooks/contents/configs"
CONFIG_DIR=".config"
TEMP_DIR=$(mktemp -d)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[setup-configs]${NC} $1"
}

success() {
    echo -e "${GREEN}[setup-configs]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[setup-configs]${NC} $1"
}

error() {
    echo -e "${RED}[setup-configs]${NC} $1" >&2
}

cleanup() {
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

# Parse command line arguments
PROJECT_TYPE="${1:-}"

# Validate project type
case "$PROJECT_TYPE" in
    "ansible")
        log "Setting up Ansible project configuration..."
        PRE_COMMIT_CONFIG="https://raw.githubusercontent.com/ginanck/shared-pre-commit-hooks/master/examples/pre-commit-config-ansible.yaml"
        CONFIG_FILES=(
            "ansible-lint.yml:.config/ansible-lint.yml"
            "yamllint.yml:.config/yamllint.yml"
            "flake8.conf:.config/flake8.conf"
            "pyproject.toml:.config/pyproject.toml"
        )
        ;;
    "terraform"|"opentofu")
        log "Setting up Terraform/OpenTofu project configuration..."
        PRE_COMMIT_CONFIG="https://raw.githubusercontent.com/ginanck/shared-pre-commit-hooks/master/examples/pre-commit-config-opentofu.yaml"
        CONFIG_FILES=()  # No additional config files needed for Terraform
        ;;
    "")
        error "❌ Please specify a project type: ansible, terraform, or opentofu"
        echo "Usage: $0 [ansible|terraform|opentofu]"
        echo ""
        echo "Examples:"
        echo "  $0 ansible    # Setup Ansible project with linter configs"
        echo "  $0 terraform  # Setup Terraform project"
        echo "  $0 opentofu   # Setup OpenTofu project"
        exit 1
        ;;
    *)
        error "❌ Unknown project type: $PROJECT_TYPE"
        echo "Supported types: ansible, terraform, opentofu"
        exit 1
        ;;
esac

# Create .config directory if needed
if [[ ${#CONFIG_FILES[@]} -gt 0 ]]; then
    mkdir -p "$CONFIG_DIR"
fi

log "Setting up $PROJECT_TYPE project configuration (always downloading latest versions)..."

# Download pre-commit configuration file
log "Downloading pre-commit configuration..."
if [[ -f ".pre-commit-config.yaml" ]]; then
    warn "Overwriting existing .pre-commit-config.yaml"
fi

if curl -fsSL "$PRE_COMMIT_CONFIG" -o ".pre-commit-config.yaml"; then
    success "✓ Downloaded .pre-commit-config.yaml"
else
    error "✗ Failed to download pre-commit configuration"
    exit 1
fi

# Download and setup each config file (only if there are config files to download)
if [[ ${#CONFIG_FILES[@]} -gt 0 ]]; then
    log "Downloading configuration files..."
    for config_mapping in "${CONFIG_FILES[@]}"; do
        IFS=':' read -r source_file target_path <<< "$config_mapping"
        
        # Create target directory
        target_dir=$(dirname "$target_path")
        mkdir -p "$target_dir"
        
        # Show message for existing files being overwritten
        if [[ -f "$target_path" ]]; then
            warn "Overwriting existing file: $target_path"
        fi
        
        # Download config file (always overwrite)
        log "Downloading latest $source_file to $target_path"
        
        if curl -fsSL "https://raw.githubusercontent.com/ginanck/shared-pre-commit-hooks/master/configs/$source_file" -o "$target_path"; then
            success "✓ Downloaded $target_path"
        else
            error "✗ Failed to download $source_file"
            exit 1
        fi
    done
else
    log "No additional configuration files needed for $PROJECT_TYPE projects"
fi

# Create .gitignore entry for .config if it doesn't exist and we downloaded config files
if [[ ${#CONFIG_FILES[@]} -gt 0 ]] && [[ -f ".gitignore" ]] && ! grep -q "^\.config/$" ".gitignore"; then
    log "Adding .config/ to .gitignore"
    echo "" >> .gitignore
    echo "# Shared configuration files (managed by pre-commit)" >> .gitignore
    echo ".config/" >> .gitignore
    success "✓ Added .config/ to .gitignore"
fi

success "🎉 $PROJECT_TYPE project setup complete!"
log "Files installed:"
log "  - .pre-commit-config.yaml"

if [[ ${#CONFIG_FILES[@]} -gt 0 ]]; then
    for config_mapping in "${CONFIG_FILES[@]}"; do
        IFS=':' read -r source_file target_path <<< "$config_mapping"
        if [[ -f "$target_path" ]]; then
            log "  - $target_path"
        fi
    done
fi

log ""
log "Next steps:"
log "1. Install pre-commit: pip install pre-commit"
log "2. Install pre-commit hooks: pre-commit install"
if [[ ${#CONFIG_FILES[@]} -gt 0 ]]; then
    log "3. Review the configuration files in .config/ directory"
    log "4. Customize them for your project if needed"
    log "5. Run 'pre-commit run --all-files' to test the setup"
else
    log "3. Run 'pre-commit run --all-files' to test the setup"
fi