# Python 2.7.18 Development Environment

A production-ready Docker image providing Python 2.7.18 development environment built from source.

## Features

- **Latest Python 2.7**: CPython 2.7.18 compiled from source with optimizations
- **Security**: Non-root user by default, minimal attack surface
- **Optimized Size**: Multi-stage build for minimal final image size
- **Development Ready**: Includes common dev tools (git, curl, wget, vim)
- **OCI Compliant**: Full metadata labels for container registries

## Quick Start

```bash
# Pull the image
docker pull aeliux/python2-dev:2.7.18

# Run interactive shell
docker run -it --rm aeliux/python2-dev:2.7.18

# Mount your project
docker run -it --rm -v $(pwd):/workspace aeliux/python2-dev:2.7.18

# Run a Python script
docker run -it --rm -v $(pwd):/workspace aeliux/python2-dev:2.7.18 python2 script.py
```

## Building

```bash
# Build the image
docker build -t python2-dev:2.7.18 .

# Build with BuildKit (recommended)
DOCKER_BUILDKIT=1 docker build -t python2-dev:2.7.18 .

# Using make (recommended)
make build

# Build without cache
make build-no-cache
```

## Image Details

- **Base Image**: debian slim images
- **Python Version**: 2.7.18
- **Included Tools**: git, curl, wget, vim, less, nano

## Python Environment

The image includes:
- Python 2.7.18 with optimizations enabled
- pip 20.3.4 (latest compatible with Python 2.7)
- setuptools 44.1.1
- wheel 0.37.1
- All packages from `requirements.txt`

## Environment Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `PYTHON_VERSION` | 2.7.18 | Python version |
| `PIP_NO_CACHE_DIR` | 1 | Disable pip cache |
| `PIP_DISABLE_PIP_VERSION_CHECK` | 1 | Disable version check |
| `LANG` | C.UTF-8 | Locale setting |
| `LC_ALL` | C.UTF-8 | Locale setting |

## Usage Examples

### Interactive Development

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -u $(id -u):$(id -g) \
  python2-dev:2.7.18 bash
```

### Run Tests

```bash
docker run --rm -v $(pwd):/workspace python2-dev:2.7.18 \
  python2 -m pytest tests/
```

## Security Notes

⚠️ **Python 2.7 End of Life**: Python 2.7 reached end-of-life on January 1, 2020. This image is provided for legacy application development only. Consider migrating to Python 3 for new projects.

- Minimal runtime dependencies to reduce attack surface
- No unnecessary build tools in final image
- Regular security updates to base Debian packages recommended

## License

Python 2.7.18 is distributed under the Python Software Foundation License.

## Maintenance

- Python 2.7.18 is the final release of Python 2.7
- Security updates should focus on base Debian packages
- This is a development image and should not be used in production without additional hardening

## GitHub & Docker Hub

This project is available on:
- **GitHub**: [github.com/aeliux/python2-dev](https://github.com/aeliux/python2-dev)
- **Docker Hub**: [hub.docker.com/r/aeliux/python2-dev](https://hub.docker.com/r/aeliux/python2-dev)

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Acknowledgments

Built with CPython source from the Python Software Foundation.
