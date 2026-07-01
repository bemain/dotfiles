# Python Anti-Patterns — Rationale

The "why" behind the anti-pattern list in `python-patterns/SKILL.md`. Reach for this when you need to justify a fix, explain a rule in review, or understand the failure mode behind a banned idiom.

## Mutable Default Arguments

```python
# Bad: Mutable default arguments
def append_to(item, items=[]):
    items.append(item)
    return items

# Good: Use None and create new list
def append_to(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items
```

The default list is created once at function-definition time and shared across every call.

## type() vs isinstance()

```python
# Bad: Checking type with type()
if type(obj) == list:
    process(obj)

# Good: Use isinstance
if isinstance(obj, list):
    process(obj)
```

`type()` doesn't account for subclasses; `isinstance()` does.

## == None vs is None

```python
# Bad: Comparing to None with ==
if value == None:
    process()

# Good: Use is
if value is None:
    process()
```

`None` is a singleton — identity comparison is faster and unambiguous.

## from module import *

```python
# Bad: from module import *
from os.path import *

# Good: Explicit imports
from os.path import join, exists
```

Wildcard imports pollute the namespace and break static analysis.

## Bare except

```python
# Bad: Bare except
try:
    risky_operation()
except:
    pass

# Good: Specific exception
try:
    risky_operation()
except SpecificError as e:
    logger.error(f"Operation failed: {e}")
```

A bare `except` catches `KeyboardInterrupt` and `SystemExit`, silently swallowing signals the user expects to terminate the program.

## Manual Resource Management

```python
# Good: Using context managers
def process_file(path: str) -> str:
    with open(path, 'r') as f:
        return f.read()

# Bad: Manual resource management
def process_file(path: str) -> str:
    f = open(path, 'r')
    try:
        return f.read()
    finally:
        f.close()
```

`with` is shorter and harder to get wrong on exception paths.

## String Concatenation in Loops

```python
# Bad: O(n²) due to string immutability
result = ""
for item in items:
    result += str(item)

# Good: O(n) using join
result = "".join(str(item) for item in items)
```

Strings are immutable, so every `+=` allocates a fresh string and copies the prior contents.
