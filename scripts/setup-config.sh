#!/bin/bash

# Setup script for shared pre-commit configuration files
# This script downloads the latest configuration files from the repository

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

# Create .config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

log "Setting up shared configuration files (always downloading latest versions)..."

# List of config files to download
CONFIG_FILES=(
    "ansible-lint.yml:.config/ansible-lint.yml"
    "yamllint.yml:.config/yamllint.yml"
    "flake8.conf:.config/flake8.conf"
    "pyproject.toml:.config/pyproject.toml"
)

# Download and setup each config file (always overwrite)
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
    
    if curl -fsSL "https://raw.githubusercontent.com/ginanck/shared-pre-commit-hooks/refs/heads/master/configs/$source_file" -o "$target_path"; then
        success "✓ Downloaded $target_path"
    else
        error "✗ Failed to download $source_file"
        exit 1
    fi
done

# Create .gitignore entry for .config if it doesn't exist
if [[ -f ".gitignore" ]] && ! grep -q "^\.config/$" ".gitignore"; then
    log "Adding .config/ to .gitignore"
    echo "" >> .gitignore
    echo "# Shared configuration files (managed by pre-commit)" >> .gitignore
    echo ".config/" >> .gitignore
    success "✓ Added .config/ to .gitignore"
fi

success "🎉 Configuration setup complete!"
log "Config files installed in:"
for config_mapping in "${CONFIG_FILES[@]}"; do
    IFS=':' read -r source_file target_path <<< "$config_mapping"
    if [[ -f "$target_path" ]]; then
        log "  - $target_path"
    fi
done

log ""
log "Next steps:"
log "1. Review the configuration files in .config/ directory"
log "2. Customize them for your project if needed"
log "3. Run 'pre-commit run --all-files' to test the setup"