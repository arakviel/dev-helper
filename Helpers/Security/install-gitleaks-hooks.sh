#!/bin/bash
# Script to install gitleaks pre-commit hook for existing repositories

echo "Installing gitleaks pre-commit hook for existing repositories..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    echo "Please run this script from the root directory of a git repository"
    exit 1
fi

# Copy the global configuration to the repository if it doesn't exist
if [ ! -f ".gitleaks.toml" ]; then
    echo "📋 Copying gitleaks configuration to repository..."
    cp "$(dirname "$0")/.gitleaks.toml" .gitleaks.toml
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Create the pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Gitleaks pre-commit hook
#
# This hook will scan staged files for secrets before allowing the commit.

# Check if gitleaks is installed
if ! command -v gitleaks &> /dev/null; then
    echo "Error: gitleaks is not installed or not in PATH"
    exit 1
fi

echo "🔍 Scanning for secrets with Gitleaks..."

# Run gitleaks on staged files
if ! gitleaks git --pre-commit; then
    echo "❌ Gitleaks found secrets in your staged files!"
    echo "Please remove the secrets and try again."
    exit 1
fi

echo "✅ No secrets found. Commit allowed."
exit 0
EOF

# Make the hook executable
chmod +x .git/hooks/pre-commit

echo "✅ Gitleaks pre-commit hook installed successfully!"
echo "The hook will now scan for secrets before each commit."