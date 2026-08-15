# Frontend (Vue) — read only when writing Vue/JS code

See `AGENTS.md` for the stack overview and shared commands. This file covers frontend-specific architecture,
style, and testing conventions. Everything below lives under `app/javascript/`.

## Architecture

- **Entry point**: `entrypoints/application.js` boots a single `createInertiaApp`, mounting Vue 3 + Pinia +
  Bootstrap once. There is no client-side router — Inertia + Rails routing decide which page renders.
- **Directory layout**:
  - `views/` — top-level page components resolved by Inertia (e.g. `views/transactions/Index.vue` is
    rendered by `render inertia: 'transactions/Index', ...` on the Rails side). Organized by domain,
    mirroring `app/controllers` naming.
  - `components/` — reusable pieces, organized by domain (`transactions/`, `budgets/`, `categories/`, ...)
    plus cross-cutting folders: `ui/` (generic widgets), `forms/` (form inputs with `v-model` support),
    `layout/` (app shell, page header, nav), `bootstrap/` (thin Vue wrappers around Bootstrap JS components,
    e.g. `BCard.vue`), `devise/` (shared bits for auth pages).
  - `stores/` — Pinia stores, one per resource (`TransactionStore.js`, `WalletStore.js`, ...), most built on
    top of a shared `BaseApiStore.js` factory (see below).
  - `api/` — **auto-generated** by the `js_from_routes` gem from `config/routes.rb`. Never hand-edit; see
    `AGENTS.backend.md` for how to regenerate.
  - `lib/` — non-trivial, domain-specific logic that's too complex for `utils/` (e.g.
    `lib/transaction_predictions/RulesParser.js`, `RulesProcessor.js`).
  - `utils/` — small generic helpers (dates, currency formatting, cookies, CSRF, responsiveness, etc.).
  - `locales/` — `en.json` / `pt-BR.json` **auto-generated** frontend translation strings, used via the
    global `t()` helper. Never hand-edit; see `AGENTS.backend.md` for how to regenerate.

## State management (Pinia)

Stores use the **Options-style** `defineStore(name, { state, getters, actions })`, not the setup-function
store style. Most resource stores are built with the shared `defineBaseApiStore(name, storeOptions)` factory
(`stores/BaseApiStore.js`), which wires up common CRUD behavior (`fetchCollection`, `fetchSingle`, `create`,
`update`, `destroy`, form-modal state, cache-aware fetching) against the matching generated API client:

```js
export default defineBaseApiStore('transaction', {
  resourceName: 'transaction',
  resourcesName: 'transactions',
  formId: TRANSACTION_FORM_ID,
  api: transactionsApi,
  state: { /* resource-specific state */ },
  getters: { /* resource-specific getters */ },
  actions: { /* overrides/extra actions, e.g. massUpdate, remove */ },
});
```

When adding a store for a new resource, start from `defineBaseApiStore` rather than writing CRUD boilerplate
from scratch, and only add custom `actions`/`getters` for behavior the base store doesn't cover.

## Components

- Every component uses a plain `<script>` block (Options API, sometimes combined with a `setup(props, { emit })`
  function for composables/Pinia access) — do not use `<script setup>`.
- Declare `props` with types (and `required`/`default`) and an explicit `emits` array —
  `vue/require-explicit-emits` is enforced.
- `v-model` support on form components follows the standard `modelValue` prop / `update:modelValue` emit
  pattern (see `components/forms/CheckboxField.vue`).
- Custom event names are `kebab-case` (`vue/custom-event-name-casing`).
- Scoped styles use `<style lang="scss" scoped>`, with a root class matching the component name in
  PascalCase (e.g. `.HelpButton` inside `HelpButton.vue`) rather than a kebab-case/BEM class — follow this
  naming for new classes in existing components, but use BEM naming for new components.
- Props/data coming from Rails are already `camelCase` (converted server-side by `camelize_props`) — don't
  re-convert casing on the frontend.
- `vue/multi-word-component-names` is off, so single-word component names are permitted.

## JS/Vue style (ESLint — see `.eslintrc.js`)

- Single-quoted strings (`quotes: single`), no `var` (`no-var`), strict equality (`eqeqeq`), no `console.*`
  calls (`no-console`), unused vars must be prefixed with `_` to be allowed.
- **`vue/no-bare-strings-in-template` is enforced** — user-facing text in templates must go through the i18n
  `t()` helper, never a hardcoded string, so it stays translated across `en`/`pt-BR`.
- `vue/html-indent`, `vue/max-attributes-per-line`, `vue/singleline-html-element-content-newline`, and
  `vue/html-closing-bracket-newline` govern template formatting — let `yarn eslint --fix` handle wrapping
  rather than hand-formatting multi-attribute tags.
- Object shorthand is enforced for properties (`object-shorthand: properties`).
- Statements are consistently semicolon-terminated in existing code (not itself ESLint-enforced, but match
  the style).
- Path aliases (from `vite.config.js`): `~` → `app/javascript`, `~bootstrap` → `node_modules/bootstrap`.
  Prefer `~/stores/...`, `~/utils/...` imports over deep relative paths.
- 2-space indentation, LF line endings, final newline (`.editorconfig`).
- Run `yarn eslint` before committing (also enforced by the Overcommit pre-commit hook locally on
  `**/*.js` / `**/*.vue`).

## Testing

**There is currently no automated frontend test suite** — no Jest/Vitest configured, no `*.test.js` /
`*.spec.js` files under `app/javascript/`, and `package.json`'s `scripts` block is empty. `yarn eslint` is the
only automated frontend check.

If you change a `.vue` page's expected props, check whether a backend controller spec
needs updating to match, and vice versa — the two aren't kept in sync automatically by any tooling.

Do not introduce frontend tests without explicit approval. If approval is given, follow the existing
`.eslintrc.js` / `vite.config.js` conventions and update this file with the new commands/patterns
so future agents pick them up.
