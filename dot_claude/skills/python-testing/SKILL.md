---
name: python-testing
description: Python testing strategies using pytest, TDD methodology, fixtures, mocking, parametrization, and coverage requirements.
metadata:
  origin: ECC
---

# Python Testing Patterns

Testing strategies for Python applications using `pytest` and TDD.

## Core Testing Philosophy

### TDD Cycle

Vertical slices — one behaviour at a time:

1. **RED**: Write a failing test for the desired behavior
2. **GREEN**: Write minimal code to make the test pass
3. **REFACTOR**: Improve code while keeping tests green

Never write all tests then all implementation. Loop RED → GREEN per behaviour, then refactor only after every test is GREEN.

### AAA Pattern

Every test structures as Arrange / Act / Assert with blank lines between the three blocks:

```python
def test_addition():
    # Arrange
    a, b = 2, 3

    # Act
    result = add(a, b)

    # Assert
    assert result == 5
```

### What Makes a Good Test

- Tests through the module's public interface, not internals
- Survives renames and refactors of private helpers
- Reads like a specification of behaviour
- One behaviour per test — if the name needs "and", split it
- Test names describe the behaviour: `test_returns_empty_list_when_no_users_match`, `test_raises_value_error_on_negative_age`

### Coverage Target

- 80%+ overall; 100% on critical paths
- Run `pytest --cov=mypackage --cov-report=term-missing`

## DO / DON'T

### DO

- Follow TDD (red-green-refactor) one slice at a time
- Test one behaviour per test
- Use descriptive names: `test_user_login_with_invalid_credentials_fails`
- Use fixtures to eliminate setup duplication
- Mock external dependencies
- Test edge cases: empty inputs, `None`, boundary conditions
- Keep tests fast — mark slow ones and exclude from the default run

### DON'T

- Test implementation details (private functions, internal state)
- Catch exceptions in tests — use `pytest.raises`
- Share state between tests
- Test third-party code
- Use `print` for debug — use assertions and `pytest -v`
- Over-mock — brittle tests die on every refactor
- Use complex conditionals inside a test

## Assertion Idioms

```python
# Equality / identity
assert result == expected
assert value is None
assert flag is True

# Membership
assert item in collection

# Exception with message match
with pytest.raises(ValueError, match="invalid input"):
    validate_input("invalid")

# Exception attributes
with pytest.raises(CustomError) as exc_info:
    raise CustomError("error", code=400)
assert exc_info.value.code == 400

# Type
assert isinstance(result, str)
```

## Markers

```python
@pytest.mark.slow
def test_slow_operation(): ...

@pytest.mark.integration
def test_api_integration(): ...
```

Register every custom marker in `pytest.ini`/`pyproject.toml` (the `--strict-markers` option turns unknown markers into errors). For marker registration and `pytest -m` selection syntax, see [COVERAGE.md](COVERAGE.md).

## Branch references

- When writing reusable test setup, `conftest.py`-shared state, fixture scopes, `autouse`, or `tmp_path` patterns, see [FIXTURES.md](FIXTURES.md).
- When isolating a unit from collaborators with `patch`, `Mock`, `MagicMock`, `autospec`, or `mock_open`, see [MOCKING.md](MOCKING.md).
- When running the same test against multiple inputs or backends with `@pytest.mark.parametrize` or parametrised fixtures, see [PARAMETRIZE.md](PARAMETRIZE.md).
- When testing `async def` functions, coroutines, or async fixtures with `pytest-asyncio`, see [ASYNC.md](ASYNC.md).
- When configuring `pytest.ini` / `pyproject.toml`, choosing `pytest` CLI flags, setting up coverage reporting, or organising the `tests/` tree, see [COVERAGE.md](COVERAGE.md).

**Remember**: Tests are code too. Keep them clean, readable, and maintainable. Good tests catch bugs; great tests prevent them.
