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

log "Setting up shared configuration files..."

# Check if any config files exist and ask user once
EXISTING_FILES=()
CONFIG_FILES=(
    "ansible-lint.yml:.config/ansible-lint.yml"
    "yamllint.yml:.config/yamllint.yml"
    "flake8.conf:.config/flake8.conf"
    "pyproject.toml:.config/pyproject.toml"
)

# Check for existing files
for config_mapping in "${CONFIG_FILES[@]}"; do
    IFS=':' read -r source_file target_path <<< "$config_mapping"
    if [[ -f "$target_path" ]]; then
        EXISTING_FILES+=("$target_path")
    fi
done

# Ask user once if they want to overwrite existing files
OVERWRITE_ALL=false
if [[ ${#EXISTING_FILES[@]} -gt 0 ]]; then
    warn "Found existing configuration files:"
    for file in "${EXISTING_FILES[@]}"; do
        warn "  - $file"
    done
    echo
    read -p "Do you want to overwrite existing files with the latest versions? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        OVERWRITE_ALL=true
        log "Will overwrite existing files with latest versions"
    else
        log "Will skip existing files"
    fi
fi

# Download and setup each config file
for config_mapping in "${CONFIG_FILES[@]}"; do
    IFS=':' read -r source_file target_path <<< "$config_mapping"
    
    # Create target directory
    target_dir=$(dirname "$target_path")
    mkdir -p "$target_dir"
    
    # Skip if file exists and user doesn't want to overwrite
    if [[ -f "$target_path" ]] && [[ "$OVERWRITE_ALL" = false ]]; then
        log "Skipping $target_path (already exists)"
        continue
    fi
    
    # Show message for existing files being overwritten
    if [[ -f "$target_path" ]] && [[ "$OVERWRITE_ALL" = true ]]; then
        warn "Overwriting $target_path with latest version"
    fi
    
    # Download config file
    log "Downloading $source_file to $target_path"
    
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

# Create a local ansible.cfg that points to the shared config
if [[ ! -f "ansible.cfg" ]]; then
    log "Creating ansible.cfg with shared configuration paths"
    cat > ansible.cfg << 'EOF'
[defaults]
# Use shared configuration files
ansible_lint_config = .config/ansible-lint.yml

[inventory]
# Add your inventory configuration here

[ssh_connection]
# Add your SSH configuration here
EOF
    success "✓ Created ansible.cfg"
else
    warn "ansible.cfg already exists, skipping creation"
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