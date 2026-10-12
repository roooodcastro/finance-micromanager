# Backend (Ruby on Rails) — read only when writing Ruby code

See `AGENTS.md` for the stack overview, domain model, and shared commands. This file covers backend-specific
architecture, style, and testing conventions.

## Architecture patterns

Beyond the standard Rails `app/{models,controllers,views,mailers,jobs}`, this codebase adds four extra layers,
each with an `Application<X>` base class that concrete classes inherit from:

| Folder | Base class | Purpose |
|---|---|---|
| `app/services/` | `ApplicationService` | Business logic / side effects. `.call(...)` class method delegates to `new(...).call`. |
| `app/queries/` | `ApplicationQuery` | Hand-written, parameterized SQL for read-heavy/aggregate queries (see `ApplicationQuery::QueryBind`). `.run(...)` class method. |
| `app/searches/` | `ApplicationSearch` | Chainable ActiveRecord scope builders driven by request params (e.g. `TransactionSearch`). |
| `app/serializers/` | `ApplicationSerializer` | Custom JSON shaping beyond a model's own `as_json`. `.from_collection` for arrays. |

`app/validators/` holds `ActiveModel::Validator` classes for validation logic shared across models
(e.g. `TransactionAutomationValidator`).

This "base class + `.call`/`.run` entry point + private helper methods" shape repeats throughout the codebase,
including in submodules like `app/services/transaction_imports/` (parsers, processors, and import actions all
follow the same base-class-per-family pattern). Follow it for new services/queries/searches/serializers rather
than introducing a new shape.

Example service:

```ruby
class ApplicationService
  def self.call(...)
    new(...).call
  end

  def initialize(...); end

  def call
    raise NotImplementedError
  end
end

module Transactions
  class UpdateAssociatedBalances < ApplicationService
    def initialize(transaction, operation)
      super()
      @transaction = transaction
      @operation   = operation
    end

    def call
      update_profile_balance!
      update_wallet_balance!
    end

    private

    # ...
  end
end
```

## Controllers

- Inherit from `AbstractAuthenticatedController` (requires login, shares `user` / `currentProfile` /
  `availableProfiles` into every Inertia page) or `AbstractPublicController` (redirects to login).
  `ApplicationController` itself stays thin — shared concerns only.
- Render pages with `render inertia: 'namespace/PageName', props: camelize_props(props)`. `PageName` matches a
  `.vue` file under `app/javascript/views/`.
- Rails-side prop keys are `snake_case`; always pass them through `camelize_props` (from the
  `CamelizeableProps` concern) before handing them to Inertia/JSON, since the Vue side expects `camelCase`.
- Scope domain data through `Current.profile` (e.g. `Current.profile.transactions`), not directly through
  `current_user`.
- Flash/response messages use scoped translations: `t('.success')` / `t('.error', error: ...)`, resolved from
  `config/locales/controllers.<locale>.yml` under `<controller>.<action>.<key>`. Add new keys there, mirrored
  across `en` and `pt-BR`.
- Strong params use Rails 8's `params.expect(...)` where applicable (not just `require(...).permit(...)`).

## Money

Monetary columns are stored as integer `_cents` columns and exposed via money-rails' `monetize`, with currency
resolved per-`Profile`. Never do arithmetic directly on a `_cents` column in application code — go through the
`Money`-wrapped attribute (e.g. `transaction.amount`, not raw `transaction.amount_cents` math) so currency
handling stays correct.

## Generated JS routes — don't hand-edit

Routes marked `export: true` in `config/routes.rb` are compiled by the `js_from_routes` gem into
`app/javascript/api/**/*.js`. Those files carry a `DO NOT MODIFY: ... automatically generated` header — never
edit them by hand. To add or change a frontend-callable route: edit `config/routes.rb` (with `export: true` on
the relevant block), then regenerate via the gem's `js_from_routes:generate` rake task.

## Localisation

Translation files are managed in the backend, through the `config/locales/*.<locale>.yml` files. New and updated
translations write to these files. The frontend's `.json` files are auto-generated whenever the `.yml` file changes,
so don't hand-edit frontned translation files. Instead, edit the `.yml` files.

## Background jobs

Sidekiq + `sidekiq-scheduler` for recurring work. Jobs are small — inherit from `ApplicationJob`, `queue_as`,
and typically just delegate straight into a service's `.call`:

```ruby
class ProcessTransactionAutomationsJob < ApplicationJob
  queue_as :default

  def perform
    TransactionAutomations::ProcessTransactionAutomations.new(Date.current).call
  end
end
```

## Ruby style (enforced by RuboCop — see `.rubocop.yml`)

- See and follow custom enforced rules defined in `.rubocop.yml`; any rule not specified here follow Rubocop's default.
- Target Ruby 3.4, with `rubocop-rails`, `rubocop-rspec`, and `rubocop-factory_bot` plugins.
- Keep methods/classes small; extract a private method or a new service rather than growing one method further.
- **Table-aligned hashes and assignments** — a strong, consistently-applied house style
  (`Layout/HashAlignment: table`, `Layout/ExtraSpacing: ForceEqualSignAlignment: true`). When several
  consecutive lines assign variables or build a hash literal, align the `=` / `:` / `=>`:

  ```ruby
  props              = { transactions: transactions.as_json, pagination: pagy_metadata(pagy), filters: search_params }
  props[:statistics] = statistics if params[:include_statistics]
  ```

  ```ruby
  json.merge(
    'name'        => display_name,
    'amount'      => amount.to_f,
    'subcategory' => subcategory.as_json,
    'wallet'      => wallet.as_json,
    'category'    => category.as_json(include_subcategories: false)
  )
  ```

- Run `bundle exec rubocop -a` to auto-fix alignment rather than hand-aligning.
- Prefer guard clauses (`return unless ...` / `return if ...`) over nested `if`s.
- One class per file, namespaced with modules that mirror the folder path (e.g.
  `Transactions::UpdateAssociatedBalances` lives in `app/services/transactions/update_associated_balances.rb`),
  relying on Zeitwerk autoloading.
- Private methods are grouped under a single `private` keyword at the bottom of the class.
- Ruby 3.1+ hash shorthand (`{ profile: }` instead of `{ profile: profile }`) is used and enforced
  (`Style/HashSyntax: EnforcedShorthandSyntax: consistent`).
- `Style/Documentation` is disabled — class-level doc comments aren't required or expected.

## Testing (RSpec)

- Run with `bundle exec rspec`. `.rspec` auto-requires `spec_helper` + `rails_helper`.
- **Spec type is inferred from directory** (`infer_spec_type_from_file_location!`) — put a controller spec
  under `spec/controllers/`, a service spec under `spec/services/`, etc., and RSpec Rails wires up the right
  helpers automatically; no need for explicit `type:` metadata.
- Every `app/<layer>/foo.rb` has a matching `spec/<layer>/foo_spec.rb` — models, controllers, services,
  queries, searches, serializers, mailers, and validators are all covered. Mirror that when adding new code.
- **FactoryBot** (`spec/factories/`, one file per model, e.g. `transaction_factory.rb` defines
  `factory :transaction`). Use `sequence(...)`, `association(...)` for related records, and traits for special
  cases (e.g. `:skip_validations`).
- **Controller specs** use the classic Rails controller-spec style (`RSpec.describe SomeController do`,
  `get :action, params: { ... }`) plus `inertia_rails/rspec` matchers:

  ```ruby
  RSpec.describe TransactionsController do
    before { sign_in user }

    it 'renders the index component' do
      get :index
      expect_inertia.to render_component('transactions/Index').and include_camelized_props(expected_props)
    end
  end
  ```

  `include_props` / `include_camelized_props` are custom matchers in `spec/support/matchers/`.
- Prefer `describe '<method/behavior>' do ... context 'when ...' do ... end end`, with `let` / `let!` and a
  named `subject(:name) { ... }`, over long inline setup — see any spec under `spec/models/` or
  `spec/services/` for the house style. `it { is_expected.to ... }` one-liners are common for simple checks.
- SimpleCov tracks **branch** coverage (`enable_coverage :branch`), grouped by Controllers/Mailers/Models/
  Queries/Serializers/Services; CI posts a coverage summary on PRs.
- Before committing: `bundle exec rubocop` and `bundle exec brakeman -q -w2` (also enforced by the Overcommit
  git hook locally, and by CI's `lint` job).
