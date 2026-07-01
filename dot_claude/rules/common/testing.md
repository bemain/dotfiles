# Testing Requirements

## Minimum Test Coverage: 80%

Test Types (ALL required):
1. **Unit Tests** — Individual functions and module internals through their public interface
2. **Integration Tests** — Multi-module behavior, database operations, API endpoints
3. **E2E Tests** — Critical user flows (use `/browser-qa` skill)

## Test-Driven Development

Use the **tdd-guide** agent or `/tdd` skill for feature work and bug fixes.

**Core principle**: Tests verify behavior through public interfaces, not implementation details. A test that breaks when you rename an internal function was testing implementation, not behavior.

**Vertical slices — one test at a time:**

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4
  GREEN: impl1, impl2, impl3, impl4

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
```

**Workflow:**
1. Confirm which behaviors matter most — you cannot test everything
2. Write ONE test (tracer bullet) → confirm it fails → implement minimally → confirm it passes
3. Repeat for each remaining behavior
4. Refactor only after all tests are GREEN

## Agent and Skill Support

| Task | Use |
|------|-----|
| TDD for new feature or bug fix | **tdd-guide** agent or `/tdd` skill |
| Test failures to diagnose | **build-error-resolver** agent |
| E2E testing | `/browser-qa` skill |

## Troubleshooting Test Failures

1. Use **build-error-resolver** agent
2. Check test isolation — does the test depend on external state?
3. Determine: is the implementation wrong, or is the test asserting on internals?
4. Fix the implementation first; fix the test only if it is testing implementation details

## Test Structure (AAA Pattern)

```typescript
test('calculates similarity correctly', () => {
  // Arrange
  const vector1 = [1, 0, 0]
  const vector2 = [0, 1, 0]

  // Act
  const similarity = calculateCosineSimilarity(vector1, vector2)

  // Assert
  expect(similarity).toBe(0)
})
```

### Test Naming

Describe the behavior, not the implementation:

```typescript
test('returns empty array when no markets match query', () => {})
test('throws error when API key is missing', () => {})
test('falls back to substring search when Redis is unavailable', () => {})
```

## What Makes a Good Test

- Tests through the module's public interface only
- Survives internal refactors (renaming internals does not break it)
- Reads like a specification — states what the system does, not how
- Fails only when behavior changes, not when implementation changes
