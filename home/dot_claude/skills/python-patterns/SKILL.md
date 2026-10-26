---
name: python-patterns
description: Pythonic idioms, PEP 8 standards, type hints, and best practices for building robust, efficient, and maintainable Python applications.
metadata:
  origin: ECC
---

# Python Development Patterns

Idiomatic Python patterns for building robust, efficient, and maintainable applications.

## Core Principles

1. **Readability counts.** Code should be obvious — clear names over clever ones.
2. **Explicit is better than implicit.** Avoid magic; be clear about what your code does.
3. **EAFP, not LBYL.** Prefer `try/except` over pre-condition checks.

```python
# Good: Readable
def get_active_users(users: list[User]) -> list[User]:
    return [user for user in users if user.is_active]

# Bad: Clever but confusing
def get_active_users(u):
    return [x for x in u if x.a]
```

## Never

- Mutable default arguments
- Bare `except:`
- `from module import *`
- `type(obj) == SomeType` (use `isinstance`)
- `value == None` (use `is None`)
- Manual `f = open(...)` / `f.close()` (use `with`)
- String concatenation in loops (use `"".join(...)`)

Rationale for any of the above: see [RATIONALE.md](RATIONALE.md).

## Core Idioms

### EAFP

```python
# Good: EAFP style
def get_value(dictionary: dict, key: str, default_value: Any = None) -> Any:
    try:
        return dictionary[key]
    except KeyError:
        return default_value

# Bad: LBYL (Look Before You Leap) style
def get_value(dictionary: dict, key: str, default_value: Any = None) -> Any:
    if key in dictionary:
        return dictionary[key]
    else:
        return default_value
```

LBYL races with concurrent mutation; EAFP doesn't.

### Context Managers

```python
with open(path, 'r') as f:
    contents = f.read()
```

Custom context manager via `@contextlib.contextmanager`:

```python
from contextlib import contextmanager

@contextmanager
def timer(name: str):
    start = time.perf_counter()
    yield
    print(f"{name} took {time.perf_counter() - start:.4f}s")
```

For class-based context managers with transactional semantics (commit/rollback), use `__enter__`/`__exit__` and return `False` from `__exit__` to propagate exceptions.

### Comprehensions and Generators

```python
# Simple filter+transform: comprehension
names = [user.name for user in users if user.is_active]

# Lazy / large input: generator expression
total = sum(x * x for x in range(1_000_000))

# Streaming I/O: generator function
def read_lines(path: str) -> Iterator[str]:
    with open(path) as f:
        for line in f:
            yield line.strip()
```

If a comprehension grows past one filter or one transform, expand it to a `for` loop or generator function.

### Specific Exception Handling

```python
def load_config(path: str) -> Config:
    try:
        with open(path) as f:
            return Config.from_json(f.read())
    except FileNotFoundError as e:
        raise ConfigError(f"Config file not found: {path}") from e
    except json.JSONDecodeError as e:
        raise ConfigError(f"Invalid JSON in config: {path}") from e
```

Always chain with `raise ... from e` to preserve the traceback. Define a `class AppError(Exception)` base and subclass per failure mode (`ValidationError`, `NotFoundError`) when one module raises several distinct kinds of error.

## Quick Idiom Index

| Idiom | Use for |
|-------|---------|
| EAFP | Exception-based control flow |
| Context managers (`with`) | Resource management |
| List comprehensions | Simple transformations |
| Generators | Lazy evaluation, large datasets |
| Type hints | Function signatures |
| Dataclasses | Data containers |
| `__slots__` | Memory optimisation |
| f-strings | String formatting (3.6+) |
| `pathlib.Path` | Path operations (3.4+) |
| `enumerate` | Index-element pairs in loops |

## Branch references

- When writing function signatures, generics, `Protocol` classes, `TypeVar` bounds, or any non-trivial annotation, see [TYPING.md](TYPING.md).
- When defining dataclasses, `NamedTuple` records, `__post_init__` validation, or `__slots__` optimisations, see [DATA-MODELING.md](DATA-MODELING.md).
- When writing function decorators, parameterised decorators, or class-based decorators, see [DECORATORS.md](DECORATORS.md).
- When writing threaded I/O, multiprocessing CPU work, or `async/await` coroutines, see [ASYNC.md](ASYNC.md).
- When setting up project layout, `pyproject.toml`, `__init__.py` exports, or running `black`/`ruff`/`mypy`/`bandit`, see [PACKAGING.md](PACKAGING.md).

**Remember**: Python code should be readable, explicit, and follow the principle of least surprise. When in doubt, prioritise clarity over cleverness.
