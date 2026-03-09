# Architecture Reference — DHH Rails Style

## Table of Contents
1. Application Structure
2. Current Attributes
3. Jobs
4. Caching
5. Background Infrastructure (Solid*)
6. Multi-tenancy
7. Deployment
8. Configuration
9. Logging

---

## 1. Application Structure

### Standard Rails Directory Layout

No custom directories. Use what Rails gives you:

```
app/
  controllers/
    concerns/          # Controller concerns (Authentication, AccountScoped, etc.)
    cards/             # Namespaced controllers (Cards::ClosuresController)
  models/
    concerns/          # Model concerns (Withdrawable, Closable, etc.)
    card/              # Namespaced models (Card::Closure)
  views/
  jobs/
  mailers/
  helpers/
config/
db/
test/
lib/
```

### What Does NOT Exist

- `app/services/` — No service objects directory
- `app/interactors/` — No interactors
- `app/commands/` — No command objects
- `app/policies/` — No policy objects (authorization lives in models)
- `app/presenters/` — No presenters (use helpers or partials)
- `app/decorators/` — No decorators (use concerns)
- `app/queries/` — No query objects (use scopes)
- `app/serializers/` — No serializers (use Jbuilder)
- `app/forms/` — No form objects as standard pattern

### Namespaced Models

Group related models under a namespace:

```ruby
# app/models/card.rb
class Card < ApplicationRecord; end

# app/models/card/closure.rb
class Card::Closure < ApplicationRecord
  belongs_to :card
end

# app/models/card/assignment.rb
class Card::Assignment < ApplicationRecord
  belongs_to :card
  belongs_to :assignee, class_name: "Identity"
end
```

---

## 2. Current Attributes

`Current` is the thread-local bag for request context. Set it once in authentication,
use it everywhere:

```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :identity
  attribute :account
  attribute :request_id, :user_agent, :ip_address
end
```

Access `Current.identity` and `Current.account` from models, controllers, views, jobs.
No need to pass the current user through every method signature.

---

## 3. Jobs

### Shallow Job Classes

Jobs are wrappers. Logic lives in models:

```ruby
class Card::NotifySubscribersJob < ApplicationJob
  def perform(card)
    card.notify_subscribers_now
  end
end
```

The model concern enqueues the job:

```ruby
module Card::Subscribable
  extend ActiveSupport::Concern

  included do
    after_create_commit :notify_subscribers_later
  end

  def notify_subscribers_later
    Card::NotifySubscribersJob.perform_later(self)
  end

  def notify_subscribers_now
    subscribers.each do |subscriber|
      CardMailer.new_card(subscriber, self).deliver_later
    end
  end
end
```

### Recurring Jobs

Use `config/recurring.yml` for scheduled work:

```yaml
deliver_bundled_notifications:
  command: "Notification::Bundle.deliver_all_later"
  schedule: every 30 minutes
```

---

## 4. Caching

### Russian Doll Caching

Cache at multiple levels with `touch: true` to propagate cache invalidation:

```ruby
class Comment < ApplicationRecord
  belongs_to :card, touch: true
end
```

```erb
<%# cards/_card.html.erb %>
<% cache @card do %>
  <h3><%= @card.title %></h3>
  <% @card.comments.each do |comment| %>
    <% cache comment do %>
      <%= render comment %>
    <% end %>
  <% end %>
<% end %>
```

### Fragment Caching

Cache expensive view fragments:

```erb
<% cache ["board_sidebar", @board] do %>
  <%= render @board.columns %>
<% end %>
```

---

## 5. Background Infrastructure: The Solid Stack

### No Redis

Replace Redis with database-backed alternatives:

- **Solid Queue** for background jobs (replaces Sidekiq/Resque)
- **Solid Cache** for caching (replaces Redis cache store)
- **Solid Cable** for WebSockets (replaces Redis Action Cable adapter)

These are configured in `config/` and backed by your existing database. Fewer
moving parts, simpler deployment.

```ruby
# config/environments/production.rb
config.active_job.queue_adapter = :solid_queue
config.cache_store = :solid_cache_store
config.action_cable.pubsub_adapter = :solid_cable
```

---

## 6. Multi-tenancy

Fizzy uses path-based multi-tenancy with `Current`:

```ruby
# Account slug extracted from URL path, set on Current
Current.account = account_from_request
```

Key insight: this avoids subdomains or separate databases, keeping development simple.

---

## 7. Deployment

### Kamal

Deploy with Kamal. Docker-based, zero-downtime deployments to bare metal or VPS:

```yaml
# config/deploy.yml
service: myapp
image: myorg/myapp

servers:
  web:
    - 192.168.0.1

proxy:
  ssl: true
  host: myapp.com
```

### SQLite in Production

For ONCE-style apps (self-hosted, single-server), SQLite is the production database.
For SaaS, MySQL or PostgreSQL. Fizzy supports both SQLite and MySQL.

---

## 8. Configuration

### Environment Variables

Use environment variables for secrets and environment-specific config:

```ruby
# Keep it simple
ENV.fetch("SMTP_ADDRESS", "localhost")
ENV.fetch("DATABASE_ADAPTER", "sqlite")
```

### No Heavy Config Frameworks

No `dotenv` in production, no `figaro`. Plain environment variables set via Kamal
secrets or your deployment tool.

---

## 9. Logging

### Minimal Application Logging

Let Rails handle logging. Don't litter models with log statements.

From Fizzy: only 2 explicit logging calls in the entire `app/models/` directory, both
for error cases. Rails' built-in request logging, SQL logging, and Action Mailer logging
handle everything else.

```ruby
# Only log for genuine error cases
Rails.logger.error error
Rails.logger.error error.backtrace.join("\n")
```
