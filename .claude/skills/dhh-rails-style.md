---
name: dhh-rails-style
description: >
  Enforces 37signals/DHH Ruby on Rails conventions when writing Rails code. Use this skill whenever
  writing Ruby or Rails code, generating models, controllers, views, migrations, tests, or performing
  code reviews. Triggers on any Rails development task including: scaffolding features, creating models
  or controllers, writing migrations, designing associations, implementing business logic, adding
  Hotwire/Turbo/Stimulus, writing tests, or reviewing Rails code. Also trigger when the user mentions
  DHH, 37signals, Basecamp, HEY, Campfire, Fizzy, Writebook, or ONCE-style development. If you are
  writing ANY Ruby on Rails code, read this skill first. Do not reach for service objects, form objects,
  interactors, dry-rb, Trailblazer, or other abstraction layers without reading this skill.
---

# DHH-Style Rails Development

This skill encodes the Rails development philosophy practiced at 37signals, extracted from their
production codebases (Fizzy, Campfire, Writebook) and DHH's own writing and code reviews.

The philosophy in one sentence: **"Vanilla Rails is plenty."**

Maximize what Rails gives you out of the box. Minimize dependencies. Resist abstractions until
they have genuinely earned their keep.

## Quick Reference: What To Do vs What NOT To Do

### DO
- Put business logic in models and model concerns
- Use concerns for SRP decomposition of a single model (not just shared behavior)
- Create new controllers to stay RESTful (7 CRUD actions only)
- Use delegated types instead of STI for polymorphism
- Use callbacks and `after_create_commit` for side effects
- Use `Current` attributes for request context
- Use Hotwire (Turbo Frames, Turbo Streams, Stimulus) for interactivity
- Use Minitest and fixtures
- Use Solid Queue, Solid Cache, Solid Cable
- Use Propshaft and importmaps
- Deploy with Kamal
- Use SQLite in development (and production for ONCE-style apps)

### DO NOT
- Create `app/services/` directories or service objects (as a default pattern)
- Use RSpec or FactoryBot
- Reach for dry-rb, Trailblazer, interactors, or command objects
- Use STI when delegated types would work
- Add custom controller actions beyond the 7 RESTful ones
- Use React, Vue, or heavy JS frameworks
- Add Redis when Solid Queue/Cache/Cable will do
- Over-abstract with presenter/decorator/query objects as default patterns

## Routing: Which Reference To Read

Based on what you're doing, read the appropriate reference file:

- **Creating/editing models, concerns, associations, callbacks, scopes, state machines** →
  Read `references/models.md`
- **Creating/editing controllers, routes, authentication, authorization** →
  Read `references/controllers.md`
- **Working with Turbo, Stimulus, views, partials, CSS** →
  Read `references/frontend.md`
- **Architecture decisions: jobs, caching, Current, deployment, gems** →
  Read `references/architecture.md`
- **Writing or reviewing tests** →
  Read `references/testing.md`
- **Deciding whether to add a gem or build it yourself** →
  Read `references/gems.md`

For most tasks you will need `models.md` and `controllers.md` at minimum.

## Core Principles (Always Apply)

### 1. Abstractions Must Earn Their Keep

From DHH's code reviews on Fizzy: if you can't point to 3+ variations that need an
abstraction, inline it. Methods and classes that don't explain anything or provide
meaningful abstraction should be removed.

Ask: "Is this abstraction earning its keep?" If not, delete it.

### 2. Thin Controllers, Rich Domain Models

Controllers call the domain model directly. Plain Active Record operations in controllers
are completely fine:

```ruby
class Cards::CommentsController < ApplicationController
  def create
    @comment = @card.comments.create!(comment_params)
  end
end
```

For more complex behavior, create intention-revealing model APIs:

```ruby
class Cards::GoldnessesController < ApplicationController
  def create
    @card.gild
  end
end
```

### 3. Concerns as SRP Decomposition (Not Just Sharing)

This is critical and often misunderstood. Concerns are NOT just for shared behavior across
multiple models. They are the primary tool for decomposing a single model's responsibilities
into coherent slices.

An Offer model might include `Withdrawable` even though nothing else is withdrawable.
A ClosingDate might include `Rollable` even though nothing else rolls.
A Person might include `Dropboxed` even though no other model has a dropbox key.

From DHH (2012): "Concerns are also a helpful way of extracting a slice of model that
doesn't seem part of its essence without going full-bore Single Responsibility Principle
and running the risk of ballooning your object inventory."

The goal: opening `offer.rb` and seeing `include Withdrawable, Publishable, Scorable`
tells you the roles this model plays. Each concern is a self-contained slice you can
reason about independently.

```ruby
# app/models/offer.rb
class Offer < ApplicationRecord
  include Withdrawable   # Only Offer is withdrawable — that's fine
  include Publishable    # Maybe shared with other models — also fine
  include Scorable       # Only Offer has scores — still fine

  belongs_to :company
  has_many :applications
end

# app/models/concerns/withdrawable.rb
module Withdrawable
  extend ActiveSupport::Concern

  included do
    has_one :withdrawal, dependent: :destroy
    scope :withdrawn, -> { joins(:withdrawal) }
    scope :active, -> { where.missing(:withdrawal) }
  end

  def withdraw!(reason: nil)
    transaction do
      create_withdrawal!(reason: reason, withdrawn_at: Time.current)
      notify_applicants_of_withdrawal
    end
  end

  def withdrawn?
    withdrawal.present?
  end

  private
    def notify_applicants_of_withdrawal
      applications.pending.each(&:notify_of_withdrawal_later)
    end
end
```

### 4. REST Purity: New Controllers Over Custom Actions

When an action doesn't map to standard CRUD, introduce a new resource:

```ruby
# Bad
resources :cards do
  post :close
  post :reopen
end

# Good
resources :cards do
  resource :closure, only: [:create, :destroy]
end
```

This maps to `Cards::ClosuresController` with `create` (close) and `destroy` (reopen).

### 5. State as Records, Not Strings

Prefer modeling state transitions as the creation/deletion of associated records rather
than updating a status column:

```ruby
# Instead of card.update!(status: "closed")
# Create a Closure record:
card.closures.create!
```

### 6. The `_later` / `_now` Convention

Jobs are shallow wrappers. The model holds the logic:

```ruby
module Event::Relaying
  extend ActiveSupport::Concern

  included do
    after_create_commit :relay_later
  end

  def relay_later
    Event::RelayJob.perform_later(self)
  end

  def relay_now
    # actual relay logic lives here, in the model
  end
end
```

### 7. Naming Matters

From Fizzy's STYLE.md:
- Use expanded conditionals over guard clauses (as a default preference)
- Only use `!` for methods that have a counterpart without `!`
- Don't add newlines under visibility modifiers, and indent content under them
- If a module only has private methods, mark it `private` at the top with an extra newline

```ruby
class SomeClass
  def some_method
    # ...
  end

  private
    def some_private_method_1
      # ...
    end

    def some_private_method_2
      # ...
    end
end
```

## When Services/Form Objects Are Acceptable

The Fizzy STYLE.md says: "When justified, it is fine to use services or form objects, but
don't treat those as special artifacts." They're not a pattern to organize around — they're
an escape hatch for genuinely complex multi-step operations that don't belong to any single
model.

```ruby
# This is fine when genuinely needed — but it's a plain Ruby object,
# not a "service" in a services/ directory
Signup.new(email_address: email_address).create_identity
```

The bar is high. Most of the time, a concern on the relevant model is better.
