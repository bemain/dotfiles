# Agent Orchestration

## Available Agents

Located in `~/.claude/agents/`:

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| architect | System design, module structure, seam placement | Architectural decisions, planning new features |
| code-architect | Implementation blueprints from codebase analysis | Before writing code for a complex feature |
| tdd-guide | Test-driven development, vertical slices | Implementing a planned feature or fix test-first — one test at a time |
| code-reviewer | Code quality, security, maintainability | After writing or modifying code |
| security-reviewer | OWASP vulnerability analysis | Before commits touching auth, input, DB, crypto |
| build-error-resolver | Diagnose and fix build, type, lint, test failures | When any build step fails |
| python-reviewer | Python-specific review (PEP 8, type hints, security) | After modifying Python code |
| cpp-reviewer | C++ memory safety, concurrency, modern idioms | After modifying C++ code |
| doc-updater | Codemaps, READMEs, documentation freshness | After architectural or interface changes |
| homelab-architect | Home and small-lab network planning | Homelab network design or changes |

## Immediate Agent Usage

Use without waiting for the user to ask:

1. Feature implementation — use **code-architect** to design the approach, **tdd-guide** to implement it
2. Code written or modified — use **code-reviewer** immediately after
3. Security-sensitive code changed — use **security-reviewer** before commit
4. Build fails — use **build-error-resolver**
5. Architectural decision — use **architect**

## Skills vs Agents

Some tasks are better handled by skills (invoked via `/skill-name`) than agents:

| Task | Use instead |
|------|-------------|
| E2E testing | `/browser-qa` skill |
| Architecture refactor opportunities | `/improve-codebase-architecture` skill |
| Dead code cleanup | `/improve-codebase-architecture` skill |
| TDD protocol reference | `/tdd` skill |

## Parallel Task Execution

For independent work, launch agents in parallel in a single message:

```
# GOOD: parallel
Launch in parallel:
1. security-reviewer on the auth module
2. code-reviewer on the API handler
3. build-error-resolver on the failing type check

# BAD: sequential when there is no dependency
Run security-reviewer, then code-reviewer, then build-error-resolver
```

## Multi-Perspective Analysis

For complex or high-stakes changes, use split-role sub-agents to get independent reads:
- Factual reviewer — what does the code actually do?
- Security analyst — what can go wrong with untrusted input?
- Interface critic — does the module interface make sense to a caller?
- Consistency reviewer — does this fit the existing codebase patterns?
