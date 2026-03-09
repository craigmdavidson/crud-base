# Models Reference — DHH Rails Style

## Table of Contents
1. Concerns: The Primary Organizational Tool
2. Delegated Types
3. Associations and Scopes
4. Callbacks
5. State as Records
6. Validations
7. Database Patterns
8. Naming and Style

---

## 1. Concerns: The Primary Organizational Tool

### Two Uses of Concerns

**Use 1: Shared cross-cutting behavior** (Trashable, Searchable, Taggable)
Multiple models share the same capability. Classic mixin use.

**Use 2: Single-model SRP decomposition** (Withdrawable, Dropboxed, Rollable)
A concern mixed into only ONE model to isolate a coherent slice of responsibility.
This is equally valid and equally encouraged. The question is not "will multiple models
use this?" but "is this a coherent, nameable slice of what this model does?"

### Concern Structure

```ruby
# app/models/concerns/withdrawable.rb
module Withdrawable
  extend ActiveSupport::Concern

  included do
    has_one :withdrawal, dependent: :destroy
    scope :withdrawn, -> { joins(:withdrawal) }
    scope :active, -> { where.missing(:withdrawal) }

    after_commit :notify_withdrawal_later, on: :update, if: :just_withdrawn?
  end

  def withdraw!(reason: nil)
    create_withdrawal!(reason: reason, withdrawn_at: Time.current)
  end

  def withdrawn?
    withdrawal.present?
  end

  private
    def just_withdrawn?
      withdrawal.present? && withdrawal.previously_new_record?
    end

    def notify_withdrawal_later
      WithdrawalNotificationJob.perform_later(self)
    end
end
```

### Model File as Table of Contents

The model file itself should read like a table of contents. A developer opening it should
immediately grasp the roles this model plays:

```ruby
class Card < ApplicationRecord
  include Closable
  include Assignable
  include Commentable
  include Subscribable
  include Movable
  include Labelable
  include Filterable

  belongs_to :board
  belongs_to :column
  belongs_to :creator, class_name: "Identity"

  has_rich_text :body

  validates :title, presence: true
end
```

### Concern Naming Conventions

- Use adjective form when possible: `Taggable`, `Searchable`, `Closable`, `Withdrawable`
- For process-oriented slices: `Event::Relaying`, `Card::Positioning`
- Namespace model-specific concerns under the model: `Card::Closable` vs shared `Closable`

### What Goes in a Concern vs the Model File

**In the model file:**
- `include` declarations (the table of contents)
- Core associations that define identity (belongs_to, core has_many)
- Core validations
- Core scopes that are truly fundamental

**In concerns:**
- Associations added by the concern (e.g., `has_one :withdrawal`)
- Scopes related to the concern's domain
- Callbacks related to the concern's domain
- Instance methods for the concern's behavior
- Class methods / scopes for the concern's queries

---

## 2. Delegated Types

Use delegated types instead of STI when you have a polymorphic parent that can take
different specific forms.

```ruby
# The parent model
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[Message Comment Task], dependent: :destroy

  def title
    entryable.title
  end
end

# Each delegated type
class Message < ApplicationRecord
  has_one :entry, as: :entryable, touch: true
end

class Comment < ApplicationRecord
  has_one :entry, as: :entryable, touch: true
end
```

### When to Use Delegated Types vs STI

**Use delegated types when:**
- The subtypes have meaningfully different columns
- You want to avoid null columns
- The subtypes are genuinely different things that share a common wrapper

**Use STI (sparingly) when:**
- The subtypes share almost all columns
- The differences are primarily behavioral, not structural

**Use neither when:**
- A simple boolean or enum on the model would suffice
- State-as-records (see below) would be cleaner

---

## 3. Associations and Scopes

### Association Style

```ruby
# Use has_many :through for join models
has_many :taggings, dependent: :destroy
has_many :tags, through: :taggings

# Scope associations when needed
has_many :active_assignments, -> { where(completed: false) }, class_name: "Assignment"

# Use dependent: :destroy for owned associations
has_many :comments, dependent: :destroy
```

### Scope Style

```ruby
# Prefer scopes over class methods for queries
scope :recent, -> { order(created_at: :desc) }
scope :visible_to, ->(person) { where(board: person.accessible_boards) }
scope :active, -> { where.missing(:closure) }

# Push work to the database
# Good:
scope :with_comment_count, -> { left_joins(:comments).select("cards.*, COUNT(comments.id) AS comments_count").group(:id) }

# Avoid:
def self.with_comment_count
  all.map { |card| [card, card.comments.count] }  # N+1, in-memory
end
```

### Use pluck and database operations

Prefer `pluck(:name)` over `map(&:name)`. Prefer `messages.count` over `messages.to_a.count`.
Push work to the database.

---

## 4. Callbacks

Callbacks are embraced, not feared. They are the primary mechanism for side effects.

```ruby
included do
  after_create_commit :notify_subscribers_later
  after_update_commit :sync_search_index_later
  after_destroy_commit :cleanup_later
end
```

### The `_later` Pattern

Side effects that involve I/O (email, external APIs, heavy computation) should be
dispatched to jobs via callbacks:

```ruby
def notify_subscribers_later
  Card::NotifySubscribersJob.perform_later(self)
end

def notify_subscribers_now
  subscribers.each do |subscriber|
    CardMailer.new_comment(subscriber, self).deliver_later
  end
end
```

### Callback Ordering

Put callbacks in the `included` block of concerns. The concern owns its callbacks.

---

## 5. State as Records

Model state transitions by creating/destroying associated records:

```ruby
# Instead of: card.update!(status: "closed")
# Model closure as a record:

class Card::Closure < ApplicationRecord
  belongs_to :card
  belongs_to :closer, class_name: "Identity"
end

# In Card::Closable concern:
module Card::Closable
  extend ActiveSupport::Concern

  included do
    has_one :closure, dependent: :destroy
    scope :open, -> { where.missing(:closure) }
    scope :closed, -> { joins(:closure) }
  end

  def close!(by:)
    create_closure!(closer: by)
  end

  def reopen!
    closure&.destroy!
  end

  def closed?
    closure.present?
  end
end
```

This gives you: a timestamp (created_at), an actor (closer), a clean boolean check,
and scopes — all without a status column.

---

## 6. Validations

Keep validations in the model or in concerns when they belong to that concern's domain:

```ruby
# In the model
validates :title, presence: true
validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

# In a concern, when the validation is part of that slice
module Publishable
  extend ActiveSupport::Concern

  included do
    validates :published_at, comparison: { less_than_or_equal_to: -> { Time.current } },
      allow_nil: true
  end
end
```

---

## 7. Database Patterns

### UUIDs

Fizzy uses UUIDs as primary keys:

```ruby
create_table "cards", id: :uuid do |t|
  t.uuid "board_id", null: false
  t.uuid "creator_id", null: false
end
```

### Counter Caches

Use counter caches for counts you display frequently:

```ruby
belongs_to :board, counter_cache: true
```

### Indexes

Always add indexes for foreign keys and columns you query on:

```ruby
add_index :cards, :board_id
add_index :cards, [:board_id, :position]
```

---

## 8. Naming and Style

### Expanded Conditionals Over Guard Clauses

```ruby
# Preferred
def todos_for_new_group
  if ids = params.require(:todolist)[:todo_ids]
    @bucket.recordings.todos.find(ids.split(","))
  else
    []
  end
end

# Acceptable for early returns at method start when body is complex
def after_recorded_as_commit(recording)
  return if recording.parent.was_created?

  # ... many lines of logic
end
```

### Bang Methods

Only use `!` for methods that have a counterpart without `!`. Don't use `!` just to
flag destructive actions.

### Privacy

```ruby
class SomeClass
  def public_method
    # ...
  end

  private
    def private_method_1
      # ...
    end

    def private_method_2
      # ...
    end
end
```

No newline after `private`. Indent methods under it. If a module is all private:

```ruby
module SomeModule
  private

  def some_private_method
    # ...
  end
end
```

### String Inquiry

Use `.inquiry` on string enums for clean predicates:

```ruby
class Event < ApplicationRecord
  def action
    super.inquiry
  end
end

# Then:
event.action.completed?
event.action.pending?
```
