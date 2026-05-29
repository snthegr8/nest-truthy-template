# Contributing to Nest API Starter

We welcome contributions. Please follow these guidelines.

## License

Contributions are under the same [MIT License](LICENSE) as the project.

## Report bugs

Use GitHub [issues](../../issues) with steps to reproduce, expected behavior, and environment details.

## Documentation

When behavior changes, update:

- Code comments and tests where non-obvious
- [README.md](README.md)
- [AGENTS.md](AGENTS.md) if architecture or conventions change

## Testing

Run before opening a PR:

```bash
pnpm test:unit
pnpm test:e2e
```

E2E tests require Postgres and Redis (see `docker-compose-test.yml`).

## Pull requests

- Keep PRs focused; prefer one concern per PR
- Link related issues in the description
- Ensure CI passes
