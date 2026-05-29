# Nest API Starter

NestJS API template with authentication, RBAC, two-factor auth, email (Bull + Redis), refresh tokens, and dashboard analytics. Use it to bootstrap new backend projects without rebuilding auth and admin foundations.

**AI contributors:** read [AGENTS.md](AGENTS.md) before changing code.

## Features

- JWT auth with refresh tokens and session management
- Role-based access control (roles + permissions)
- TOTP two-factor authentication
- Queued mail (Nodemailer + Bull + Redis)
- DB-backed email templates
- Rate limiting (Redis-backed throttler)
- i18n (English + Nepali sample locale)
- Swagger in development (`/api-docs`)

## Prerequisites

- Node.js 16+
- PostgreSQL 12+
- Redis
- pnpm 9+ (`corepack enable` then use the version pinned in `package.json`)

## Quick start

```bash
# Clone and install
git clone <your-repo-url> my-api
cd my-api
pnpm install

# Environment
cp .env.example .env
# Edit .env with DB and Redis settings

# Database
pnpm migrate
pnpm seed

# Run (development)
pnpm start:dev
```

- API: `http://localhost:7777`
- Health: `GET /health`
- Swagger (dev only): `http://localhost:7777/api-docs`

### Default seed user

After `pnpm seed`:

| Field | Value |
|-------|--------|
| Email | `admin@example.com` |
| Username | `admin` |
| Password | `Truthy@123` |

Change this password immediately in any non-local environment.

## Docker

```bash
cp .env.example .env
docker-compose up -d
pnpm migrate
pnpm seed
```

## Scripts

| Script | Description |
|--------|-------------|
| `pnpm start:dev` | Dev server with watch |
| `pnpm build` | Production build |
| `pnpm test:unit` | Unit tests |
| `pnpm test:e2e` | E2E tests (needs Postgres + Redis) |
| `pnpm migrate` | Run migrations |
| `pnpm seed` | Run database seeds |
| `pnpm lint` | ESLint |

E2E tests use `docker-compose-test.yml`:

```bash
docker-compose -f docker-compose-test.yml up -d
pnpm test:e2e
docker-compose -f docker-compose-test.yml down
```

## Configuration

Runtime config lives in [`config/`](config/) (via [node-config](https://github.com/node-config/node-config)). Environment variables override DB settings in [`src/config/ormconfig.ts`](src/config/ormconfig.ts).

Set mail credentials via `.env` or `config/local.yml` — do not commit SMTP secrets.

## Project structure

```
src/
├── auth/              # Users, login, JWT, profile
├── role/              # Roles CRUD
├── permission/        # Permissions + RBAC loading
├── refresh-token/     # Sessions / devices
├── twofa/             # TOTP 2FA
├── mail/              # Mail queue + Pug templates
├── email-template/    # DB email templates
├── dashboard/         # Admin stats
├── common/            # Guards, pipes, base repository, serializers
├── config/            # ORM, throttle, Winston, permissions
├── database/          # Migrations + seeds
├── exception/         # HTTP exceptions
├── paginate/          # Pagination helpers
└── i18n/              # Locales
```

## Fork checklist

1. Rename `package.json` `name` and `config/*.yml` `app.name` / mail `from` fields
2. Replace seed admin in `src/database/seeds/create-user.seed.ts`
3. Update `.env.example` and create `.env`
4. Rotate JWT secrets in `config/development.yml` / production secrets
5. Read [AGENTS.md](AGENTS.md) and add project-specific rules if needed

## Acknowledgments

Derived from [Truthy CMS](https://github.com/gobeam/truthy) (MIT). See [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md).

## License

MIT — see [LICENSE](LICENSE).
