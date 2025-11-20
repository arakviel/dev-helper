# Gitleaks Global Setup

This setup configures Gitleaks globally for git repositories to automatically scan for secrets and sensitive information.

## What was installed

1. **Gitleaks** - Secret scanning tool installed via Homebrew
2. **Global configuration** - `.gitleaks.toml` configuration file in your home directory
3. **Pre-commit hooks template** - Automatic secret scanning for new git repositories
4. **Installation script** - Tool to add gitleaks hooks to existing repositories
5. **Security tools folder** - `Helpers/Security/` contains all gitleaks-related files

## Quick Start

From the project root directory, run:

```bash
./Helpers/Security/install-gitleaks-hooks.sh
```

## Configuration Details

### Global Configuration (`~/.gitleaks.toml`)

The configuration includes rules for detecting:

-   API keys
-   Passwords
-   Private keys
-   AWS credentials
-   GitHub tokens
-   Slack tokens
-   Generic secrets

### Git Template Setup

-   Git template directory: `~/.git-template/hooks/`
-   Pre-commit hook automatically scans staged files
-   Applied to all new repositories initialized with `git init`

## Usage

### For New Repositories

When you create a new git repository, the pre-commit hook will be automatically installed:

```bash
cd /path/to/new/project
git init
# Gitleaks hook is automatically installed
```

### For Existing Repositories

Use the installation script to add gitleaks hooks to existing repositories:

```bash
cd /path/to/existing/repo
/path/to/Dev/Helpers/Security/install-gitleaks-hooks.sh
```

Or if you're already in the Dev workspace:

```bash
./Helpers/Security/install-gitleaks-hooks.sh
```

### Manual Hook Installation

You can also manually copy the hook:

```bash
cp ~/.git-template/hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## How it Works

1. **Pre-commit Hook**: Before each commit, gitleaks scans staged files
2. **Secret Detection**: Uses regex patterns to identify potential secrets
3. **Automatic Blocking**: Prevents commits containing secrets
4. **Clear Feedback**: Provides informative messages about any issues found

## Testing the Setup

Create a test file with a fake secret to verify the setup:

```bash
echo 'api_key = "test123456789012345678901234567890123456"' > test-secrets.txt
git add test-secrets.txt
git commit -m "Test commit with fake secret"
```

This should be blocked by gitleaks with an error message.

## Manual Scanning

You can also run gitleaks manually on any repository:

```bash
# Scan the entire repository
gitleaks git

# Scan only staged files (like the pre-commit hook does)
gitleaks git --pre-commit

# Scan a specific directory
gitleaks dir /path/to/directory
```

## Configuration Customization

To customize the rules, edit the global configuration file:

```bash
nano ~/.gitleaks.toml
```

Or create a project-specific configuration in the repository root:

```bash
cp ~/.gitleaks.toml .gitleaks.toml
# Or copy from the Security folder:
cp /path/to/Dev/Helpers/Security/.gitleaks.toml .gitleaks.toml
# Edit the local copy as needed
```

## Troubleshooting

### Hook not executing

-   Ensure the hook file is executable: `chmod +x .git/hooks/pre-commit`
-   Check git configuration: `git config --global init.templatedir`

### Gitleaks not found

-   Verify installation: `gitleaks version`
-   Check PATH: `which gitleaks`

### False positives

-   Add exceptions to `.gitleaksignore` in your repository
-   Modify rules in the configuration file
-   Use `gitleaks:allow` comments in code (if supported)

## Security Notes

-   This setup helps prevent accidental commits of secrets
-   It's not a substitute for proper secret management practices
-   Regularly update gitleaks to get the latest detection rules
-   Consider using dedicated secret management tools for production environments
