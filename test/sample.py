"""sample.py — smoke test fixture."""


def greet(name: str) -> str:
    return f"hello, {name}"


def test_greet() -> None:
    assert greet("world") == "hello, world"


if __name__ == "__main__":
    print(greet("world"))
