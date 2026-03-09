# Testing Reference — DHH Rails Style

## Table of Contents
1. Minitest, Not RSpec
2. Fixtures, Not Factories
3. Test Organization
4. System Tests
5. Testing Concerns
6. Style

---

## 1. Minitest, Not RSpec

Use Minitest. It's built into Rails, it's fast, it's simple.

```ruby
class CardTest < ActiveSupport::TestCase
  test "closing a card creates a closure" do
    card = cards(:open_card)
    card.close!(by: identities(:david))

    assert card.closed?
    assert_equal identities(:david), card.closure.closer
  end
end
```

### No DSL Magic

Minitest reads like Ruby. `assert`, `assert_equal`, `assert_not`, `assert_raises`.
No `expect`, no `should`, no `describe`, no `context`, no `let`.

---

## 2. Fixtures, Not Factories

Use fixtures. They're fast (loaded once per test suite), they're declarative, and
they exercise your validations and associations at load time.

```yaml
# test/fixtures/cards.yml
open_card:
  title: "Fix the login bug"
  board: engineering
  column: backlog
  creator: david

closed_card:
  title: "Old completed task"
  board: engineering
  column: done
  creator: david
```

### Fixture References

Reference other fixtures by name:

```yaml
# test/fixtures/comments.yml
first_comment:
  body: "Looks good to me"
  card: open_card
  creator: david
```

### Why Not FactoryBot

- Fixtures are loaded once, factories create per-test — fixtures are faster
- Fixtures catch validation issues at suite start, not mid-test
- Fixtures give you a stable world to reason about
- Fixtures encourage thinking about your data as a coherent set

---

## 3. Test Organization

### Test Hierarchy

```
test/
  models/          # Unit tests for models and concerns
  controllers/     # Controller tests (functional)
  system/          # Full browser tests (Capybara)
  integration/     # Request-level tests
  mailers/         # Mailer tests
  jobs/            # Job tests
  fixtures/        # YAML fixtures
```

### Naming

Test files mirror the app structure:

```
app/models/card.rb          → test/models/card_test.rb
app/models/concerns/closable.rb → test/models/concerns/closable_test.rb
app/controllers/cards_controller.rb → test/controllers/cards_controller_test.rb
```

---

## 4. System Tests

Use system tests for end-to-end browser flows with Capybara + Selenium:

```ruby
class CardSystemTest < ApplicationSystemTestCase
  test "creating a new card" do
    sign_in_as :david
    visit board_path(boards(:engineering))

    click_on "New card"
    fill_in "Title", with: "New feature request"
    click_on "Create"

    assert_text "New feature request"
  end
end
```

### When to Use System Tests

- User-facing flows that involve multiple steps
- JavaScript-dependent behavior
- Turbo Frame and Turbo Stream interactions
- Form submissions with validation feedback

### When to Use Unit/Controller Tests Instead

- Model logic and scopes
- Authorization checks
- JSON API responses
- Edge cases and error paths

---

## 5. Testing Concerns

Test concerns through the models that include them. If a concern is used by one model,
test it through that model:

```ruby
class Card::ClosableTest < ActiveSupport::TestCase
  test "closing creates a closure record" do
    card = cards(:open_card)

    assert_difference "Card::Closure.count", 1 do
      card.close!(by: identities(:david))
    end

    assert card.closed?
  end

  test "reopening destroys the closure" do
    card = cards(:closed_card)
    card.reopen!

    assert_not card.closed?
  end
end
```

For shared concerns used by multiple models, test through one representative model
and trust the mixin.

---

## 6. Style

### Parallel Tests

Run tests in parallel:

```ruby
class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)
end
```

If you hit issues:

```bash
PARALLEL_WORKERS=1 bin/rails test
```

### CI

Use `bin/ci` to run the full suite (style checks, security, tests):

```bash
bin/ci
```

### Keep Tests Fast

- Use fixtures, not factories
- Push work to unit tests, minimize system tests
- Use `bin/rails test` for fast feedback loops
- Reserve `bin/ci` for pre-push verification
