# Contributing to python2-dev

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

We are committed to providing a welcoming and inclusive environment for all contributors. Please be respectful and constructive in all interactions.

## Getting Started

1. **Fork** the repository on GitHub
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/python2-dev.git
   cd python2-dev
   ```
3. **Create a new branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Making Changes

### Before You Start
- Check existing issues and pull requests to avoid duplicate work
- For significant changes, open an issue first to discuss your approach
- Ensure your changes are compatible with Python 2.7.18

### Development Workflow

1. **Build locally** to test your changes:
   ```bash
   make build
   ```

2. **Test the image**:
   ```bash
   make test
   ```

3. **Run interactively**:
   ```bash
   make shell
   ```

## Types of Contributions

### Bug Reports
- Check if the issue already exists
- Include Python version, OS, and Docker version
- Provide clear steps to reproduce
- Include relevant error messages or logs

### Feature Requests
- Describe the feature and use case
- Explain the expected behavior
- Discuss potential implementation approaches

### Documentation
- Fix typos and improve clarity
- Add examples and use cases
- Update outdated information

### Docker Image Improvements
- Optimize build size or build time
- Improve security posture
- Add useful development tools
- Update base image versions

## Pull Request Process

1. **Update** documentation and requirements as needed
2. **Test** your changes thoroughly:
   ```bash
   make build
   make test
   ```
3. **Create a Pull Request** with:
   - Clear title describing the change
   - Description of what changed and why
   - Reference to related issues
   - Test results

4. **Respond** to review feedback constructively

## Project Structure

```
.
├── Dockerfile          # Multi-stage Docker image build
├── Makefile           # Build and test targets
├── requirements.txt   # Python 2.7 development packages
├── README.md          # Project documentation
├── CONTRIBUTING.md    # This file
├── LICENSE            # MIT License
└── .github/
    └── workflows/
        └── docker-publish.yml  # CI/CD pipeline
```

## Building and Testing

### Build Targets

```bash
make help              # Show all available targets
make build            # Build the Docker image
make build-no-cache   # Build without using cache
make test             # Run tests on the image
make shell            # Start interactive shell
make push             # Push to Docker registry (requires auth)
make clean            # Clean up built images
```

### Manual Testing

```bash
# Test Python installation
docker run --rm python2-dev:2.7.18 python2 --version

# Test pip
docker run --rm python2-dev:2.7.18 pip --version

# Test installed packages
docker run --rm python2-dev:2.7.18 pip list

# Interactive development
docker run -it --rm -v $(pwd):/workspace python2-dev:2.7.18 bash
```

## Important Notes

⚠️ **Python 2.7 End of Life**: Python 2.7 reached end-of-life on January 1, 2020. This project is maintained for legacy application development only. Consider migrating to Python 3 for new projects.

## Security

- Report security issues privately to the maintainer
- Do not open public issues for security vulnerabilities
- Use clear, descriptive language without revealing sensitive details

## License

By contributing to this project, you agree that your contributions will be licensed under its MIT License.

---

Thank you for contributing!
