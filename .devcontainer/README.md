# Devcontainer Configuration

This directory contains the devcontainer configuration for developing the FlatPack Rails engine.

## What's Included

### Services

- **PostgreSQL 16** - Primary database service
  - Default database: `app_development`
  - Credentials: `postgres/postgres`
  - Port: 5432

- **Redis 7** - Cache and background job processing
  - Port: 6379
  - URL: `redis://redis:6379/0`

- **Ruby 3.2.3** - Rails application runtime
  - Pre-installed gems via bundler
  - Port 3000 forwarded for Rails server

### VS Code Extensions

The devcontainer automatically installs:

- **Shopify.ruby-lsp** - Ruby language server for intelligent code completion
- **KoichiSasada.vscode-rdbg** - Ruby debugging support
- **bradlc.vscode-tailwindcss** - Tailwind CSS IntelliSense

## Usage

### GitHub Codespaces

1. Navigate to the repository on GitHub
2. Click the "Code" dropdown
3. Select "Create codespace on main"
4. Wait for the container to build and initialize

### VS Code Dev Containers

1. Install the "Dev Containers" extension in VS Code
2. Open the repository in VS Code
3. When prompted, click "Reopen in Container"
4. Wait for the container to build and initialize

## Post-Creation Setup

The devcontainer automatically runs the following setup after creation:

```bash
git lfs install
cd test/dummy
bundle install
bundle exec rails db:prepare
bundle exec rails tailwindcss:build
```

This ensures:
- Git LFS is configured
- All Ruby dependencies are installed
- Database is created and migrated
- Tailwind CSS assets are built

## Database Configuration

The dummy app's `config/database.yml` is configured to automatically switch between:

- **PostgreSQL** when `DB_HOST` environment variable is present (devcontainer)
- **SQLite** when running locally outside the devcontainer

This allows seamless development in both environments without manual configuration changes.

## Running the Application

Once the devcontainer is ready:

```bash
cd test/dummy
bin/dev
```

Access the application at http://localhost:3000

## Running Tests

```bash
bundle exec rake test
```

## Troubleshooting

### Database Connection Issues

If you encounter database connection errors:

```bash
cd test/dummy
bundle exec rails db:prepare
```

### Missing Dependencies

If gems are missing:

```bash
cd test/dummy
bundle install
```

### Tailwind CSS Not Building

If styles are not loading:

```bash
cd test/dummy
bundle exec rails tailwindcss:build
```

## Customization

### Adding System Dependencies

Edit `.devcontainer/Dockerfile` to add additional system packages:

```dockerfile
RUN apt-get update -qq && \
    apt-get install -y \
    your-package-here \
    && rm -rf /var/lib/apt/lists/*
```

### Adding VS Code Extensions

Edit `.devcontainer/devcontainer.json` under `customizations.vscode.extensions`:

```json
"extensions": [
  "Shopify.ruby-lsp",
  "your-extension-id"
]
```

### Modifying Services

Edit `.devcontainer/docker-compose.yml` to add or modify services.

## Environment Variables

The following environment variables are automatically set in the devcontainer:

- `RAILS_ENV=development`
- `BUNDLE_PATH=/usr/local/bundle`
- `DB_HOST=db`
- `DB_USER=postgres`
- `DB_PASSWORD=postgres`
- `DB_NAME=app_development`
- `DB_PORT=5432`
- `REDIS_URL=redis://redis:6379/0`
- `CODESPACES=true`

## Notes

- The workspace is mounted at `/workspace` inside the container
- Bundle gems are cached in a Docker volume for faster rebuilds
- PostgreSQL and Redis data are persisted in Docker volumes
- The container runs as `root` user for maximum flexibility
