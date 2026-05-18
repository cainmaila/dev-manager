# TDD Workflow Reference

## Red-Green-Refactor Cycle

The only valid development loop:

```
Write failing test → Run (RED) → Implement minimal code → Run (GREEN) → Refactor → Run (still GREEN) → repeat
```

Never skip to green. Never write code before a failing test exists for it.

## Test Structure

### Unit Tests
Test one unit of behavior in isolation. External dependencies (DB, HTTP, filesystem) are replaced with test doubles.

```python
# Python / pytest
def test_creates_user_with_hashed_password():
    repo = InMemoryUserRepo()
    svc = UserService(repo)
    user = svc.create("alice", "secret")
    assert user.password != "secret"          # not stored plain
    assert verify_password("secret", user.password)  # hash is valid
```

```typescript
// TypeScript / Jest
it("returns 404 when user not found", async () => {
  const repo = { findById: jest.fn().mockResolvedValue(null) };
  const svc = new UserService(repo as any);
  await expect(svc.getById("missing")).rejects.toThrow(NotFoundError);
});
```

### Integration Tests
Test the unit against real infrastructure (real DB, real HTTP). Separate from unit tests; slower.

```python
# pytest with real DB
@pytest.mark.integration
def test_persists_user(db_session):
    repo = SqlUserRepo(db_session)
    user = repo.save(User(name="alice", email="a@b.com"))
    found = repo.find_by_id(user.id)
    assert found.email == "a@b.com"
```

### Acceptance Tests
Map 1:1 to acceptance criteria from the task definition. If the acceptance criterion says "users can log in with email and password," there is an acceptance test for that exact scenario.

## Common Anti-Patterns

| Anti-pattern | Why it fails | Fix |
|---|---|---|
| Test written after implementation | Tests conform to bugs; wrong behavior becomes "expected" | Write test first, always |
| Only happy-path tests | Errors hide in edge cases | Explicitly test nulls, empty, boundary values, errors |
| Testing implementation details | Tests break on refactor; implementation changes = test rewrite | Test behavior, not internal state |
| Mocking everything | Tests pass; production fails against real dependencies | Separate unit (mocked) from integration (real) |
| One giant test | Failure message unclear; hard to isolate | One assertion per test, descriptive names |
| Skipping "obvious" tests | "Obvious" bugs are the most expensive | No code without a test |

## Language-Specific Patterns

### Python

```bash
# Run
pytest tests/ -v
pytest tests/ -k "test_user"      # filter by name
pytest tests/ -m "not integration" # skip integration
```

```python
# conftest.py — shared fixtures
@pytest.fixture
def user_repo():
    return InMemoryUserRepo()

# parametrize — test multiple inputs
@pytest.mark.parametrize("email", ["", None, "notanemail"])
def test_rejects_invalid_email(email):
    with pytest.raises(ValidationError):
        User(email=email)
```

### TypeScript / Node

```bash
# Run
npx jest
npx jest --watch
npx jest --coverage
```

```typescript
// Describe blocks group related tests
describe("UserService", () => {
  describe("create", () => {
    it("hashes password", () => { ... });
    it("rejects duplicate email", async () => { ... });
  });
});
```

### Go

```bash
go test ./...
go test ./... -v
go test ./... -run TestUser
```

```go
func TestUserService_Create(t *testing.T) {
    repo := &fakeUserRepo{}
    svc := NewUserService(repo)
    u, err := svc.Create("alice", "secret")
    require.NoError(t, err)
    assert.NotEqual(t, "secret", u.Password)
}
```

## Confirming Red Before Green

A test that passes before implementation exists is a broken test. Common causes:

- Test assertion always evaluates true (`assert True`, `expect(x).toBeDefined()` when x is always defined)
- Wrong import — test is not actually exercising the code it claims to
- Test condition inverted (`assertEqual` vs `assertNotEqual`)

**To confirm red:** After writing tests and before writing implementation, run the suite. If any test passes, investigate why — it is almost certainly a test defect.

## Minimum Coverage Threshold

No specific percentage target. Instead: every acceptance criterion has at least one test, every error path has at least one test, and no implementation code exists without a test that would fail if that code were deleted.
