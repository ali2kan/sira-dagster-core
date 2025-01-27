# Dagster Core Docker Deployment

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[![Docker Build](https://github.com/ali2kan/sira-dagster-core/actions/workflows/docker-build.yml/badge.svg)](https://github.com/ali2kan/sira-dagster-core/actions/workflows/docker-build.yml)

</div>

A production-ready Docker deployment setup for Dagster Core, providing a robust orchestration environment for data pipelines. This repository contains the core infrastructure components needed to run Dagster in a containerized environment.

## 🏗️ Distributed Architecture

This repository is part of a distributed Dagster setup that consists of two main components:

1. **Core Infrastructure (This Repository)**:
   - Dagster webserver and daemon processes
   - Core infrastructure configuration
   - Base monitoring and scheduling
   - Database and storage management

2. **Code Locations (Separate Repository)**:
   - Contains actual pipeline definitions
   - Separate deployment lifecycle
   - Independent versioning
   - Flexible scaling options
   - [View Code Location Template Repository](https://github.com/ali2kan/sira-dagster-code-location)

### Why Distributed?

- **Separation of Concerns**: Core infrastructure changes less frequently than pipeline code
- **Independent Scaling**: Scale code locations based on workload without affecting core
- **Simplified Development**: Teams can work on pipelines without touching core infrastructure
- **Better Resource Management**: Allocate resources specifically to computation needs
- **Easier Maintenance**: Update core components without affecting running pipelines

### Using Together

1. Deploy this core infrastructure first
2. Deploy code locations using the [companion repository](https://github.com/ali2kan/sira-dagster-code-location)
3. Code locations will automatically register with this core instance

Example distributed setup:

```txt
Infrastructure Layer (This Repo)
├── Dagster Webserver (Port 3000)
├── Dagster Daemon
└── Shared Storage/Database

Pipeline Layer (Separate Repo)
├── Code Location Server 1 (Pipeline Group A)
├── Code Location Server 2 (Pipeline Group B)
└── Code Location Server N (Pipeline Group X)
```

## 🏗️ Architecture

The deployment consists of two main services:

- **Dagster Webserver**: Provides the web UI and API endpoints
- **Dagster Daemon**: Handles background processing, scheduling, and sensor evaluations

### Directory Structure

```txt

sira-dagster-core/
├── core/
│   ├── dagster_home/          # Dagster instance configuration
│   │   ├── dagster.yaml       # Main Dagster configuration
│   │   └── workspace.yaml     # Workspace configuration
│   ├── io_manager_storage/    # Persistent storage for IO managers
│   └── storage/              # General Dagster storage
├── .vscode/                  # VS Code configuration
├── docker-compose.yml        # Docker services definition
├── Dockerfile               # Docker image definition
├── requirements.txt         # Python dependencies
└── various config files     # (.env, .flake8, etc.)

```

## 🚀 Quick Start

1. Create a Docker network for Dagster:

```bash
docker network create dagster_network
```

2. Configure your environment:

```bash
cp .env.example .env
# Edit .env with your specific configuration
```

3. Start the services:

```bash
docker-compose up -d
```

4. Access the Dagster UI at `http://localhost:3000`

## 🔧 Configuration

### Docker Compose Configuration

The `docker-compose.yml` defines two main services:

1. **webserver_dagster**:
   - Runs the Dagster web interface
   - Exposes port 3000
   - Mounts necessary volumes for persistence
   - Configurable through environment variables

2. **daemon_dagster**:
   - Runs the Dagster daemon process
   - Handles background tasks and scheduling
   - Shares configuration with the webserver

### Environment Variables

Key environment variables (defined in `.env`):

- `DAGSTER_POSTGRES_*`: PostgreSQL connection details
- `AWS_*`: AWS credentials for S3 storage
- `DAGSTER_CURRENT_IMAGE`: Docker image reference

### Dagster Configuration

The `dagster.yaml` configuration includes:

- Run launcher configuration
- Storage settings (PostgreSQL)
- Compute log management (S3)
- Scheduler settings

## 📦 Docker Image

The Dockerfile creates a minimal Python 3.12 image with:

- Essential Dagster dependencies
- Custom configuration mounting
- Workspace setup

### Building the Image

```bash
# Using docker-bake.hcl for multi-platform builds
docker buildx bake -f docker-bake.hcl
```

## 🔒 Security Considerations

- Sensitive information is managed through environment variables
- Docker volumes are used for persistent storage
- Network isolation through Docker networking
- Proper permission management for mounted volumes

## 📝 Development Setup

The repository includes comprehensive development configurations:

- VS Code settings for Python and YAML
- Linting configurations (flake8, yamllint)
- Editor configurations (.editorconfig)
- Git ignore patterns

## 🛠️ Customization

### Adding New Pipelines

Update `workspace.yaml` to add new pipeline locations. See our [Code Location Template](https://github.com/ali2kan/sira-dagster-code-location) for implementation examples:

```yaml
load_from:
  - grpc_server:
      host: your-host
      port: your-port
      location_name: "your-pipeline"
```

### Scaling

Adjust the `run_coordinator` settings in `dagster.yaml` to control concurrent runs:

```yaml
run_coordinator:
  config:
    max_concurrent_runs: 5
```

## 🤝 Contributing

We welcome contributions to improve the Dagster Core deployment setup! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on:

- Code of conduct
- Development setup
- Submission process
- Coding standards

### Development Process

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request using our [PR template](.github/PULL_REQUEST_TEMPLATE.md)

## 🔒 Security

Security is important to us. If you discover any security-related issues, please follow our [Security Policy](SECURITY.md) for proper reporting procedures.

### Security Features

- Containerized deployment
- Environment-based configuration
- No hardcoded credentials
- Regular dependency updates via Renovate
- Multi-architecture support

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Usage Terms

- Free for commercial and personal use
- No warranty provided
- Attribution required when redistributing

## 🐛 Known Issues and Limitations

- Currently supports PostgreSQL for storage
- S3 is required for compute logs
- Multi-platform support is limited to amd64 and arm64

## 🔄 Maintenance

Regular maintenance tasks:

- Update Python dependencies in `requirements.txt`
- Check for Dagster version updates
- Monitor Docker image size
- Review security patches

## 📚 Additional Resources

- [Dagster Documentation](https://docs.dagster.io)
- [Docker Documentation](https://docs.docker.com)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Dagster Code Location Template](https://github.com/ali2kan/sira-dagster-code-location)

## 🤖 CI/CD and Automation

### GitHub Actions

The repository includes automated workflows for building and publishing multi-architecture Docker images:

#### Docker Build Workflow

- **File**: `.github/workflows/docker-build.yml`
- **Triggers**:
  - Push to `main` branch
  - Any tag starting with `v` (e.g., `v1.0.0`)
  - Pull requests to `main`
- **Actions**:
  1. Builds multi-architecture images (linux/amd64, linux/arm64)
  2. Pushes to GitHub Container Registry (ghcr.io)
  3. Tags images based on:
     - Branch name
     - PR number (for pull requests)
     - Semantic version (for version tags)
     - Git SHA
- **Usage**:

  ```bash
  # Images are automatically built and tagged
  # To pull the latest image:
  docker pull ghcr.io/[your-username]/sira-dagster-core:latest

  # To pull a specific version:
  docker pull ghcr.io/[your-username]/sira-dagster-core:v1.0.0
  ```

### Dependency Management

#### Renovate Bot

- **File**: `renovate.json`
- **Purpose**: Automated dependency updates
- **Features**:
  - Automatically updates:
    - Python dependencies in `requirements.txt`
    - Base Docker image in `Dockerfile`
    - GitHub Actions versions
  - Groups Dagster-related updates together
  - Automatically merges minor/patch updates
  - Creates PRs for major updates
- **Configuration Highlights**:

  ```json
  {
    "packageRules": [
      {
        "matchPackagePatterns": ["^dagster"],
        "groupName": "dagster packages"
      }
    ]
  }
  ```

### Update Schedule

- Dependencies are checked weekly
- Minor updates are auto-merged
- Major updates require manual review
- Security updates are prioritized

### Monitoring Updates

1. Check the "Pull Requests" tab for pending updates
2. Review the Renovate dashboard for upcoming updates
3. Check GitHub Actions tab for build status

### Manual Triggers

```bash
# Manually trigger a new Docker build
git tag v1.0.0
git push origin v1.0.0

# This will trigger the workflow to:
# 1. Build new multi-arch images
# 2. Tag them with v1.0.0
# 3. Push to container registry
```
