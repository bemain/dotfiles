---
name: git-workflow
description: Git workflow patterns including branching strategies, commit conventions, merge vs rebase, conflict resolution, and collaborative development best practices for teams of all sizes.
metadata:
  origin: ECC
---

# Git Workflow Patterns

Day-to-day Git operations — commit messages, branches, pull requests, and the deeper workflows (merging, conflicts, releases, hooks) they touch.

## Commit Messages

### Conventional Commits Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

### Types

| Type | Use For | Example |
|------|---------|---------|
| `feat` | New feature | `feat(auth): add OAuth2 login` |
| `fix` | Bug fix | `fix(api): handle null response in user endpoint` |
| `docs` | Documentation | `docs(readme): update installation instructions` |
| `style` | Formatting, no code change | `style: fix indentation in login component` |
| `refactor` | Code refactoring | `refactor(db): extract connection pool to module` |
| `test` | Adding/updating tests | `test(auth): add unit tests for token validation` |
| `chore` | Maintenance tasks | `chore(deps): update dependencies` |
| `perf` | Performance improvement | `perf(query): add index to users table` |
| `ci` | CI/CD changes | `ci: add PostgreSQL service to test workflow` |
| `revert` | Revert previous commit | `revert: revert "feat(auth): add OAuth2 login"` |

### Good vs Bad Examples

```
# BAD: Vague, no context
git commit -m "fixed stuff"
git commit -m "updates"
git commit -m "WIP"

# GOOD: Clear, specific, explains why
git commit -m "fix(api): retry requests on 503 Service Unavailable

The external API occasionally returns 503 errors during peak hours.
Added exponential backoff retry logic with max 3 attempts.

Closes #123"
```

Subject line: imperative mood, no period, max 50 chars. Body explains *why*, not *what*.

When reconciling a feature branch with `main`, squashing fixup commits, force-pushing, amending, or undoing a commit already pushed, see [REBASING.md](REBASING.md).

## Pull Request Workflow

### PR Title Format

```
<type>(<scope>): <description>

Examples:
feat(auth): add SSO support for enterprise users
fix(api): resolve race condition in order processing
docs(api): add OpenAPI specification for v2 endpoints
```

### PR Description Template

```markdown
## What
Brief description of what this PR does.

## Why
Motivation and context.

## How
Key implementation details worth highlighting.

## Testing
- [ ] Unit / integration tests added or updated
- [ ] Manual testing performed

Closes #123
```

### Author Checklist (before requesting review)

- Self-review completed
- CI passes (tests, lint, typecheck)
- PR size reasonable (<500 lines ideal)
- Scoped to a single feature/fix
- Description explains the change

## Branch Naming

```
feature/user-authentication
feature/JIRA-123-payment-integration
fix/login-redirect-loop
hotfix/critical-security-patch
release/1.2.0
experiment/new-caching-strategy
```

When choosing a branching model (GitHub Flow, Trunk-Based, GitFlow) for a new repo or team, see [BRANCHING.md](BRANCHING.md).

## Common Commands

### Start a Feature

```bash
git checkout main
git pull origin main
git checkout -b feature/user-auth
# ...work...
git push -u origin feature/user-auth
```

### Update a PR

```bash
git add .
git commit -m "feat(auth): add error handling"
git push origin feature/user-auth
```

### Sync Fork with Upstream

```bash
git remote add upstream https://github.com/original/repo.git  # once
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

### Stash Work in Progress

```bash
git stash push -m "WIP: user authentication"
git stash list
git stash pop                  # most recent
git stash apply stash@{2}
```

### Clean Up Branches

```bash
git fetch -p                              # prune deleted remotes
git branch -d feature/user-auth           # safe delete (merged only)
git push origin --delete feature/user-auth
```

When `git merge` or `git rebase` reports `CONFLICT`, or planning to avoid conflicts on a long-running branch, see [CONFLICTS.md](CONFLICTS.md).

## Releases

Cut versioned releases with annotated tags and a generated changelog so consumers can pin and audit.

When cutting a versioned release, creating annotated tags, or generating a changelog, see [RELEASES.md](RELEASES.md).

## Hooks

Enforce lint, tests, and secret scans locally before commits or pushes leave the developer's machine.

When setting up pre-commit or pre-push enforcement of lint/test/secret-scan gates, see [HOOKS.md](HOOKS.md).

## Never

- Commit directly to `main`
- Commit secrets or `.env` files
- Ship 1000+ line PRs
- `git push --force` to shared/protected branches
- Let feature branches live for weeks
- Commit generated files (`dist/`, `node_modules/`)
