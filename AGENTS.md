# AGENTS.md — Finance MicroManager

A personal finance / expense-tracking web app. It's a single Ruby on Rails 8 application that renders a Vue 3
frontend via Inertia.js — there is no separate JSON API service; Rails controllers render Vue page components
directly.

> The root `README.md` describes the product from a user's perspective and lags behind the implementation in
> places. This file (and the two it links to) reflect the current code, not the README.

## Stack

| Layer      | Technology |
|------------|------------|
| Backend    | Ruby 3.4.5, Rails 8.0 |
| Frontend   | Vue 3 (Options API, some Composition via `setup()`), Pinia, Bootstrap 5 |
| Bridge     | Inertia.js (`inertia_rails` gem + `@inertiajs/vue3`) — no separate REST/JSON API layer for the SPA |
| Routes→JS  | `js_from_routes` gem generates JS API clients from `config/routes.rb` |
| Database   | PostgreSQL |
| Jobs/Cache | Sidekiq + sidekiq-scheduler, Redis |
| Auth       | Devise |
| Money      | money-rails (`_cents` integer columns wrapped in `Money` objects) |
| Build      | Vite (`vite_rails` + `vite-plugin-ruby`) |
| Deploy     | Docker image → Kubernetes (see `DEPLOYMENT.md`) |

## Architecture

- **Monolith, not client/server.** Controllers render Inertia pages directly
  (`render inertia: 'transactions/Index', props: ...`). A handful of controllers also support `format.json`,
  used by Vue to asynchronously update the frontend page, but Inertia is the primary contract between Rails and Vue.
- **`Profile` is the tenancy boundary, not `User`.** A `User` can own or be shared into multiple `Profile`s
  (via `ProfileShare` / `ProfileShareInvite`). Almost all domain data (`Transaction`, `Wallet`, `Category`,
  `Budget`, `Reconciliation`, `Import`, ...) belongs to a `Profile`. The active profile for a request is
  resolved into `Current.profile`; backend code should scope through `Current.profile`, not `current_user`,
  when reading or writing domain data.
- **Domain model** (see `db/schema.rb` for exact columns): `User` → `Profile` → `Wallet`, `Category` /
  `Subcategory`, `Transaction`, `Budget` / `BudgetInstance`, `Reconciliation` (+ `ReconciliationWallet`),
  `Import` (+ `ImportTransaction` — bank-statement imports), `TransactionAutomation`, `TransactionPrediction`.
- **Bank-statement imports** are the most extensible subsystem: per-bank parsers (N26, PTSB, Revolut) feed an
  importer/processor pipeline, then confirm/apply actions. See `AGENTS.backend.md` before
  touching anything under `app/services/transaction_imports/`.
- **i18n**: English and Brazilian Portuguese. Backend translations live in `config/locales/*.<locale>.yml`,
  split by concern (`controllers`, `views`, `active_record`, `mailers`, `devise`). Frontend translations are
  automatically generated from backend ones, and live in `app/javascript/locales/{en,pt-BR}.json`. Never update
  these directly, as they're generated from the `.yml` ones in `config/locales`.

## Running it locally

- `bin/setup` — install gems, prepare the DB. Only run this once after a fresh repo clone.
- `bin/dev` — runs `rails s -b 0.0.0.0` and `bin/vite dev` together (via Foreman/`Procfile.dev`).
- Requires PostgreSQL and Redis running locally (see `config/database.yml`, `config/redis.yml`).
- Ruby version pinned via `.ruby-version`, Node via `.nvmrc`.

## Tests, lint, and CI

- Backend tests: `bundle exec rspec`
- Ruby lint: `bundle exec rubocop`
- Security scan: `bundle exec brakeman -q -w2`
- Frontend lint: `yarn eslint`
- GitHub Actions (`.github/workflows/rubyonrails.yml`) runs RSpec+SimpleCov and RuboCop+Brakeman on every push
  or PR to `main`. ESLint currently runs only locally via the Overcommit pre-commit hook (`.overcommit.yml`),
  not in CI.
- There is currently **no automated frontend test suite** (no Jest/Vitest, no `.vue`/`.js` spec files). Backend
  request/controller specs do assert on the exact Inertia props shape sent to each Vue page, which is the
  closest thing to frontend contract testing that exists today.

## Stack-specific guides — read only what you need

To save context, don't read both files below by default — only read the one matching the code you're about
to touch:

- **[AGENTS.backend.md](./AGENTS.backend.md)** — read only when writing or modifying Ruby/Rails code
  (`app/{models,controllers,services,queries,searches,serializers,validators,jobs,mailers}`, `config/`, `db/`,
  `spec/`). Covers backend architecture patterns, Ruby code style, and RSpec testing conventions.
- **[AGENTS.frontend.md](./AGENTS.frontend.md)** — read only when writing or modifying Vue/JS code
  (`app/javascript/**`). Covers frontend architecture, Vue/JS code style, and the current state of frontend
  testing.

If a task touches both stacks (e.g. adding a new resource end-to-end), read both.
