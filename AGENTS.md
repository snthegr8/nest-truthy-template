# Agent instructions — Nest API Starter

This file defines architecture and conventions for AI coding agents working in this repository.

## Purpose

Production-oriented NestJS API template: auth, RBAC, 2FA, mail queue, refresh tokens, email templates, dashboard stats. Extend it for new products; do not strip core modules without explicit approval.

## Architecture overview

```
HTTP Request
    → Controller (guards, DTOs)
    → Service (business logic)
    → Repository (extends BaseRepository)
    → TypeORM Entity
    → Serializer (response shape)
```

Feature modules live under `src/<feature>/`. Shared code lives in `src/common/`, `src/config/`, `src/exception/`, `src/paginate/`, `src/i18n/`.

### Registered feature modules

| Module | Path | Responsibility |
|--------|------|----------------|
| Auth | `src/auth/` | Users, login, register, JWT, profile, passwords |
| Roles | `src/role/` | Role CRUD |
| Permissions | `src/permission/` | Permission CRUD + route permission loading |
| Refresh token | `src/refresh-token/` | Sessions, devices, browser/OS metadata |
| Twofa | `src/twofa/` | TOTP 2FA |
| Mail | `src/mail/` | Bull queue, Nodemailer, Pug templates |
| Email template | `src/email-template/` | DB-backed templates |
| Dashboard | `src/dashboard/` | Admin analytics (no entity table) |

## Per-feature module layout

When adding or extending a feature, follow this structure:

```
src/<feature>/
├── <feature>.module.ts
├── <feature>.controller.ts
├── <feature>.service.ts
├── <feature>.repository.ts    # extends BaseRepository<Entity, Serializer>
├── dto/                       # class-validator DTOs
├── entity/ or entities/       # TypeORM entities (match existing module naming)
└── serializer/                # optional; extends ModelSerializer
```

Register new modules in `src/app.module.ts`.

## Layer rules

### Controllers

- HTTP routing, guards, and DTO binding only
- Use `@UseGuards(JwtTwoFactorGuard, PermissionGuard)` on protected admin routes
- Use `@ApiTags`, `@ApiBearerAuth` for Swagger where applicable
- Do not call TypeORM `Repository` directly

### Services

- Business logic and orchestration
- Inject custom repositories, not raw `@InjectRepository` unless the module already does
- Throw domain exceptions from `src/exception/` (e.g. `NotFoundException`, `ForbiddenException`)

### Repositories

- Extend `src/common/repository/base.repository.ts`
- Use `get`, `paginate`, `createEntity`, `updateEntity` patterns from the base class
- Return serializers via `transform()`

### DTOs

- `class-validator` decorators on all input DTOs
- Global validation: `CustomValidationPipe` in `app.module.ts`
- Use `SearchFilterInterface` / `CommonSearchFieldDto` for list filters where applicable

### Serializers

- Extend `src/common/serializer/model.serializer.ts`
- Control exposed fields with `@Expose()` / `@Exclude()`
- Controllers return serializer types, not raw entities

### Entities

- Extend `src/common/entity/custom-base.entity.ts` when using shared id/timestamp columns
- One migration per schema change under `src/database/migrations/`
- Do not use `synchronize: true` in production

## Cross-cutting concerns

### Authentication & authorization

- JWT: `JwtAuthGuard`, `JwtTwoFactorGuard` in `src/common/guard/`
- Permissions: `PermissionGuard` checks route method + path against user role permissions
- Permission slugs and route map: `src/config/permission-config.ts`
- New protected routes need matching permission seeds in `src/database/seeds/create-permission.seed.ts`

### Errors & i18n

- Custom HTTP exceptions: `src/exception/`
- Global filter: `I18nExceptionFilterPipe`
- User-facing strings: `src/i18n/<locale>/` (`app.json`, `exception.json`, `validation.json`)

### Configuration

- Use `config` package + YAML in `config/` (`default.yml`, `development.yml`, `production.yml`, `test.yml`)
- DB connection: `src/config/ormconfig.ts` (env vars override YAML)
- Do not add `process.env` reads scattered in services; centralize in config or ormconfig

### Mail

- Templates: Pug under `src/mail/templates/email/`
- Jobs: Bull processor in `src/mail/mail.processor.ts`
- Queue name from `config` → `mail.queueName`

## Adding a new feature (checklist)

1. Generate module, controller, service under `src/<feature>/`
2. Create entity extending `CustomBaseEntity` if applicable
3. Add TypeORM migration: `pnpm orm-create <MigrationName>` then implement `up`/`down`
4. Create repository extending `BaseRepository`
5. Add DTOs with validation
6. Add serializer if API responses need field filtering
7. Wire module in `app.module.ts`
8. Add permissions + seed entries if routes are protected
9. Add unit tests under `test/unit/<feature>/`
10. Add e2e tests under `test/e2e/` when behavior is integration-critical

## Do not

- Introduce `domain/` DDD folder structure unless explicitly requested
- Skip guards on admin/mutating endpoints
- Commit secrets, Mailtrap credentials, or real SMTP passwords
- Inline validation in controllers instead of DTOs
- Remove existing modules (auth, role, permission, etc.) without approval
- Rename TypeORM migration history or edit applied migrations
- Change `expect(x).toBeTruthy()` Jest matchers — that is not product branding

## Commands

```bash
pnpm start:dev          # Development server
pnpm build              # Compile
pnpm migrate            # Run migrations
pnpm seed               # Seed roles, permissions, admin user, email templates
pnpm test:unit          # Unit tests
pnpm test:e2e           # E2E (Postgres + Redis required)
pnpm lint               # ESLint
```

## Testing conventions

- Unit tests: `test/unit/**/*.unit-spec.ts` with `jest-unit.json`
- E2E: `test/e2e/**/*.e2e-spec.ts` with `jest-e2e.json`
- Factories: `test/factories/`
- Use `AppFactory` for e2e app bootstrap

## File naming

- kebab-case files: `user.repository.ts`, `create-role.dto.ts`
- PascalCase classes: `UserEntity`, `AuthService`
- Import paths use `src/` prefix (see `tsconfig.json` paths)
