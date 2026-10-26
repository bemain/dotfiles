# pytest Coverage & Configuration — Reference

Coverage tooling, pytest configuration files, CLI invocation, marker registration. For when you are wiring up `pytest`/`coverage` for a project, configuring `pyproject.toml`/`pytest.ini`, or running specific test subsets.

## Coverage Requirements

- **Target**: 80%+ code coverage
- **Critical paths**: 100% coverage required
- Use `pytest --cov` to measure coverage

```bash
pytest --cov=mypackage --cov-report=term-missing --cov-report=html
```

## pytest.ini

```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts =
    --strict-markers
    --disable-warnings
    --cov=mypackage
    --cov-report=term-missing
    --cov-report=html
markers =
    slow: marks tests as slow
    integration: marks tests as integration tests
    unit: marks tests as unit tests
```

## pyproject.toml

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = [
    "--strict-markers",
    "--cov=mypackage",
    "--cov-report=term-missing",
    "--cov-report=html",
]
markers = [
    "slow: marks tests as slow",
    "integration: marks tests as integration tests",
    "unit: marks tests as unit tests",
]
```

## Marker Selection

```bash
# Run only fast tests
pytest -m "not slow"

# Run only integration tests
pytest -m integration

# Run integration or slow tests
pytest -m "integration or slow"

# Run tests marked as unit but not slow
pytest -m "unit and not slow"
```

## CLI Cheatsheet

```bash
# Run all tests
pytest

# Run specific file
pytest tests/test_utils.py

# Run specific test
pytest tests/test_utils.py::test_function

# Run with verbose output
pytest -v

# Run with coverage
pytest --cov=mypackage --cov-report=html

# Run only fast tests
pytest -m "not slow"

# Run until first failure
pytest -x

# Run and stop on N failures
pytest --maxfail=3

# Run last failed tests
pytest --lf

# Run tests with pattern
pytest -k "test_user"

# Run with debugger on failure
pytest --pdb
```

## Directory Structure

```
tests/
├── conftest.py                 # Shared fixtures
├── __init__.py
├── unit/                       # Unit tests
│   ├── __init__.py
│   ├── test_models.py
│   ├── test_utils.py
│   └── test_services.py
├── integration/                # Integration tests
│   ├── __init__.py
│   ├── test_api.py
│   └── test_database.py
└── e2e/                        # End-to-end tests
    ├── __init__.py
    └── test_user_flow.py
```
