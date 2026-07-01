# pytest Async Testing — Reference

`pytest-asyncio`, async fixtures, awaitable assertions. For when you are testing `async def` functions, coroutines, or `aiohttp`/`httpx`/`asyncio`-based code.

## Async Tests with pytest-asyncio

```python
import pytest

@pytest.mark.asyncio
async def test_async_function():
    """Test async function."""
    result = await async_add(2, 3)
    assert result == 5

@pytest.mark.asyncio
async def test_async_with_fixture(async_client):
    """Test async with async fixture."""
    response = await async_client.get("/api/users")
    assert response.status_code == 200
```

## Async Fixture

```python
@pytest.fixture
async def async_client():
    """Async fixture providing async test client."""
    app = create_app()
    async with app.test_client() as client:
        yield client

@pytest.mark.asyncio
async def test_api_endpoint(async_client):
    """Test using async fixture."""
    response = await async_client.get("/api/data")
    assert response.status_code == 200
```

For mocking awaitables, see [MOCKING.md](MOCKING.md) — `assert_awaited_once()` is the async-aware sibling of `assert_called_once()`.
