# Controllers Reference — DHH Rails Style

## Table of Contents
1. REST Purity
2. Controller Structure
3. Controller Concerns
4. Routing
5. Authentication and Authorization
6. Turbo/Hotwire Responses
7. Style

---

## 1. REST Purity: 7 Actions Only

Controllers should only contain the 7 RESTful actions: `index`, `show`, `new`, `create`,
`edit`, `update`, `destroy`.

When you need something that doesn't map to these, create a new controller for a new
resource. Controllers are cheap. Create them freely.

```ruby
# Bad: custom actions
resources :cards do
  post :close
  post :reopen
  post :assign
  get :history
end

# Good: new resources for new concepts
resources :cards do
  resource :closure, only: [:create, :destroy]       # close / reopen
  resources :assignments, only: [:create, :destroy]   # assign / unassign
  resources :events, only: [:index]                   # history
end
```

From DHH: "Every single time I've regretted the state of my controllers, it's been
because I've had too few of them."

### Naming the New Controller

`Cards::ClosuresController` — the card's closure resource.
`Cards::AssignmentsController` — the card's assignments.
`Cards::PositionsController` — updating a card's position (drag and drop).

### Empty Actions Are Fine

If Rails can render the view by convention, leave the action empty or omit it:

```ruby
class Cards::ClosuresController < ApplicationController
  def create
    @card.close!(by: Current.identity)
  end

  # show action not needed — Rails renders show.html.erb automatically
end
```

---

## 2. Controller Structure

### Thin Controllers: 1–5 Lines Per Action

Controllers invoke the domain model. They don't contain business logic:

```ruby
class Cards::CommentsController < ApplicationController
  before_action :set_card

  def create
    @comment = @card.comments.create!(comment_params)
  end

  def destroy
    @comment = @card.comments.find(params[:id])
    @comment.destroy!
  end

  private
    def set_card
      @card = Current.account.cards.find(params[:card_id])
    end

    def comment_params
      params.require(:comment).permit(:body)
    end
end
```

Plain Active Record calls in controllers are perfectly fine. You don't need to wrap
`@card.comments.create!` in anything.

### Response Handling

Use `head` for bodyless responses:

```ruby
def update
  @card.update!(card_params)
  head :ok
end

def create
  @card = Card.create!(card_params)
  head :created
end
```

Use bang methods (`create!`, `update!`) for fail-fast behavior.

---

## 3. Controller Concerns

Just like model concerns, controller concerns extract reusable behavior:

```ruby
# app/controllers/concerns/account_scoped.rb
module AccountScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_account
  end

  private
    def set_account
      @account = Current.account
    end
end
```

### Common Controller Concerns

- **Authentication**: `before_action :require_authentication`
- **Authorization**: `before_action :require_authorization`
- **Parent resource loading**: `before_action :set_card` for nested controllers
- **Rate limiting**: Concern wrapping `rate_limit` declarations

---

## 4. Routing

### Nested Resources

Use shallow nesting. Go one level deep maximum:

```ruby
resources :boards do
  resources :columns, only: [:create, :update, :destroy]
  resources :cards, only: [:index, :new, :create]
end

resources :cards, only: [:show, :edit, :update, :destroy] do
  resource :closure, only: [:create, :destroy]
  resources :comments, only: [:create, :destroy]
end
```

### Namespace for Grouped Controllers

Use namespaces to organize related controllers:

```ruby
namespace :my do
  resource :identity, only: [:show, :edit, :update]
  resource :notifications, only: [:show, :update]
end
```

From DHH's Fizzy review: "This should be My::IdentitiesController. We're putting
everything that derives from Current.identity on that to imply there won't be a /identities/x."

### URL-Based State

Prefer URL parameters for filter state over session or hidden fields:

```ruby
# Good: state in URL
# GET /boards/1/cards?column=backlog&assignee=david
def index
  @cards = @board.cards
  @cards = @cards.where(column: params[:column]) if params[:column]
  @cards = @cards.assigned_to(params[:assignee]) if params[:assignee]
end
```

---

## 5. Authentication and Authorization

### Current Attributes

Use `Current` for thread-local request context:

```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :identity
  attribute :account
  attribute :request_id
end
```

Set in a controller concern:

```ruby
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :signed_in?
  end

  private
    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      if session = find_session_by_cookie
        Current.identity = session.identity
      end
    end

    def signed_in?
      Current.identity.present?
    end
end
```

### Authorization in Models

Put authorization logic in models, not in a separate policy layer:

```ruby
class Card < ApplicationRecord
  def editable_by?(identity)
    board.accessible_by?(identity)
  end
end

# In controller:
before_action :require_card_access

def require_card_access
  head :forbidden unless @card.editable_by?(Current.identity)
end
```

---

## 6. Turbo/Hotwire Responses

### Turbo Stream Responses

```ruby
def create
  @comment = @card.comments.create!(comment_params)
  respond_to do |format|
    format.turbo_stream
    format.html { redirect_to @card }
  end
end
```

With a corresponding `create.turbo_stream.erb`:

```erb
<%= turbo_stream.append "comments" do %>
  <%= render @comment %>
<% end %>
```

### Model-Level Broadcasting

Broadcast from models using concerns, not from controllers:

```ruby
module Card::Broadcasting
  extend ActiveSupport::Concern

  included do
    after_create_commit  -> { broadcast_prepend_to board, :cards }
    after_update_commit  -> { broadcast_replace_to board, :cards }
    after_destroy_commit -> { broadcast_remove_to board, :cards }
  end
end
```

---

## 7. Style

### Respond To Blocks

Only use `respond_to` when you genuinely serve multiple formats. If it's HTML only,
skip it. Rails handles it:

```ruby
# If you only serve HTML, just let Rails render:
def show
end

# Only add respond_to when serving multiple formats:
def show
  respond_to do |format|
    format.html
    format.turbo_stream
  end
end
```

### Expression-less Case

Use expression-less `case` for cleaner conditionals:

```ruby
case
when params[:before].present?
  @room.messages.page_before(params[:before])
when params[:after].present?
  @room.messages.page_after(params[:after])
else
  @room.messages.last_page
end
```

### Symbol Arrays

```ruby
before_action :set_message, only: %i[ show edit update destroy ]
```
