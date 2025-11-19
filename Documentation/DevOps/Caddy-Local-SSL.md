# Caddy Local Development Setup

## Overview

Caddy is a powerful, easy-to-configure web server that automatically provides HTTPS. This guide shows how to set up local domains with HTTPS using Caddy for development purposes.

## Installation

### macOS

```bash
brew install caddy
```

### Linux

```bash
# Using apt (Ubuntu/Debian)
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/trusted.gpg.d/caddy-stable.asc
echo 'deb [signed-by=/usr/share/keyrings/caddy-stable-archive-keyring.gpg] https://dl.cloudsmith.io/public/caddy/stable/debian/ any-version main' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy

# Using yum (CentOS/RHEL)
sudo yum install yum-plugin-copr
sudo yum copr enable @caddy/caddy
sudo yum install caddy
```

## Basic Configuration

### 1. Create Caddyfile

Create a file named `Caddyfile` in your project root:

```caddy
# Basic local development setup
localhost {
    reverse_proxy localhost:3000
    tls internal
}

# API backend
api.localhost {
    reverse_proxy localhost:8080
    tls internal
}

# Multiple services
web.localhost {
    reverse_proxy localhost:3000
    tls internal
}

admin.localhost {
    reverse_proxy localhost:3001
    tls internal
}
```

### 2. Run Caddy

```bash
# Start Caddy in the background
caddy run &

# Or run in foreground
caddy run

# Stop Caddy
caddy stop
```

### 3. Auto-start Setup

```bash
# Install Caddy as systemd service (Linux)
sudo caddy install-admin
sudo caddy start

# For macOS, use launchd
sudo caddy fmt --overwrite
sudo caddy adapt --config /etc/caddy/Caddyfile --pretty
```

## Advanced Configuration

### Multiple Projects

```caddy
# Project 1
app1.test {
    reverse_proxy localhost:3000
    tls internal
}

# Project 2
app2.test {
    reverse_proxy localhost:3001
    tls internal
}

# API for Project 1
api.app1.test {
    reverse_proxy localhost:8080
    tls internal
}

# API for Project 2
api.app2.test {
    reverse_proxy localhost:8081
    tls internal
}
```

### Static File Serving

```caddy
# Static site
static.localhost {
    root /path/to/your/static/files
    file_server
    tls internal
}
```

### PHP Development

```caddy
# PHP with FastCGI
php.localhost {
    root /path/to/php/project
    php_fastcgi localhost:9000
    file_server
    tls internal
}
```

### Docker Integration

```caddy
# Docker containers
docker-app.localhost {
    reverse_proxy docker-container:3000
    tls internal
}
```

## SSL Certificate Management

### Internal Certificates (Recommended for Development)

```caddy
# Caddy will automatically generate self-signed certificates
localhost {
    reverse_proxy localhost:3000
    tls internal
}
```

### Custom Certificates

```caddy
# Using custom certificates
localhost {
    reverse_proxy localhost:3000
    tls /path/to/cert.pem /path/to/key.pem
}
```

## Hosts File Configuration

### macOS/Linux

Edit `/etc/hosts`:

```bash
sudo nano /etc/hosts
```

Add your domains:

```
127.0.0.1   localhost
127.0.0.1   api.localhost
127.0.0.1   app1.test
127.0.0.1   app2.test
127.0.0.1   static.localhost
127.0.0.1   php.localhost
```

### Windows

Edit `C:\Windows\System32\drivers\etc\hosts` as administrator.

## Browser Setup

### Chrome/Chromium

1. Visit `chrome://flags/#allow-insecure-localhost`
2. Enable "Allow invalid certificates for resources loaded from localhost"

### Firefox

1. Go to Preferences → Privacy & Security
2. Scroll to Certificates section
3. Click "View Certificates"
4. Import Caddy's certificate (usually found in `~/.local/share/caddy`)

## Useful Commands

### Check Configuration

```bash
# Validate Caddyfile syntax
caddy validate

# Show adapted configuration
caddy adapt
```

### Manage Caddy

```bash
# Reload configuration
caddy reload

# Get status
caddy status

# View logs
caddy logs
```

### API Management

```bash
# Load configuration via API
curl -X POST http://localhost:2019/load \
  -H "Content-Type: application/json" \
  -d '{"apps":{"http":{"servers":{"example":{"listen":[":443"],"routes":[{"match":[{"host":["example.com"]}],"handle":[{"handler":"static_response","body":"Hello, world!"}]}]}}}}}'

# Get current config
curl http://localhost:2019/config/
```

## Troubleshooting

### Common Issues

1. **Port 443 already in use**

    ```bash
    # Check what's using port 443
    sudo lsof -i :443

    # Stop the conflicting service or use different port
    ```

2. **Certificate errors**

    ```bash
    # Clear Caddy data
    rm -rf ~/.local/share/caddy

    # Restart Caddy
    caddy stop && caddy run
    ```

3. **Hosts file not working**

    ```bash
    # Flush DNS cache (macOS)
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder

    # Flush DNS cache (Linux)
    sudo systemd-resolve --flush-caches

    # Flush DNS cache (Windows)
    ipconfig /flushdns
    ```

### Debug Mode

```bash
# Run with debug logging
caddy run --debug
```

## Security Notes

⚠️ **Important for Development:**

-   `tls internal` generates self-signed certificates
-   These certificates will show as "not secure" in browsers
-   Click "Proceed anyway" or add exception for development domains
-   Never use `tls internal` in production

## Example Project Structure

```
my-project/
├── Caddyfile
├── frontend/
│   └── (React/Vue/Angular app on port 3000)
├── backend/
│   └── (Node.js/Python/PHP app on port 8080)
└── README.md
```

## Quick Start Script

Create `setup-caddy.sh`:

```bash
#!/bin/bash
echo "Setting up Caddy for local development..."

# Install Caddy if not present
if ! command -v caddy &> /dev/null; then
    echo "Installing Caddy..."
    brew install caddy
fi

# Create Caddyfile
cat > Caddyfile << EOF
localhost {
    reverse_proxy localhost:3000
    tls internal
}

api.localhost {
    reverse_proxy localhost:8080
    tls internal
}
EOF

# Add to hosts file
echo "Adding domains to hosts file..."
echo "127.0.0.1   localhost api.localhost" | sudo tee -a /etc/hosts

echo "Starting Caddy..."
caddy run &

echo "Setup complete! Visit https://localhost and https://api.localhost"
```

Run the script:

```bash
chmod +x setup-caddy.sh
./setup-caddy.sh
```

## Resources

-   [Caddy Documentation](https://caddyserver.com/docs/)
-   [Caddyfile Tutorial](https://caddyserver.com/docs/caddyfile/tutorial)
-   [Automatic HTTPS](https://caddyserver.com/docs/automatic-https)
