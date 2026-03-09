# Frontend Reference — DHH Rails Style

## Table of Contents
1. Hotwire First
2. Turbo Frames
3. Turbo Streams
4. Stimulus
5. Views and Partials
6. CSS
7. Importmaps and Propshaft

---

## 1. Hotwire First

The default approach to interactivity is Hotwire (Turbo + Stimulus). Heavy JS frameworks
(React, Vue, Svelte) are not used. The vast majority of interactivity comes from:

- **Turbo Drive**: Automatic SPA-like navigation (no code needed)
- **Turbo Frames**: Decompose pages into independently updateable regions
- **Turbo Streams**: Server-pushed HTML updates over WebSocket or HTTP
- **Stimulus**: Small, targeted JS controllers for behavior that HTML alone can't handle

### Minimal Custom JavaScript

Fizzy is ~6% JavaScript. The JS that exists is Stimulus controllers with focused,
specific responsibilities. No global state management, no build-time frameworks.

---

## 2. Turbo Frames

Use Turbo Frames to make sections of a page independently loadable and replaceable:

```erb
<%# In the page: %>
<%= turbo_frame_tag "card_#{@card.id}" do %>
  <%= render @card %>
<% end %>

<%# In the edit form — targets the same frame: %>
<%= turbo_frame_tag "card_#{@card.id}" do %>
  <%= form_with model: @card do |f| %>
    <%# ... %>
  <% end %>
<% end %>
```

### Lazy Loading with Frames

```erb
<%= turbo_frame_tag "comments", src: card_comments_path(@card), loading: :lazy do %>
  <p>Loading comments...</p>
<% end %>
```

---

## 3. Turbo Streams

### From Controllers

```erb
<%# create.turbo_stream.erb %>
<%= turbo_stream.append "comments" do %>
  <%= render @comment %>
<% end %>
```

### From Models (Broadcasting)

Broadcast directly from model concerns:

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

### Available Stream Actions

`append`, `prepend`, `replace`, `update`, `remove`, `before`, `after`.
Use the one that matches the DOM operation you need.

---

## 4. Stimulus

Stimulus controllers are small, focused, and declarative. They enhance HTML — they
don't replace it.

```javascript
// app/javascript/controllers/clipboard_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]

  copy() {
    navigator.clipboard.writeText(this.sourceTarget.value)
  }
}
```

```erb
<div data-controller="clipboard">
  <input data-clipboard-target="source" value="<%= @card.url %>" readonly>
  <button data-action="clipboard#copy">Copy</button>
</div>
```

### Stimulus Conventions

- One controller per behavior
- Name controllers after what they do: `toggle`, `clipboard`, `dropdown`, `filter`
- Use `targets` for DOM references, `values` for configuration, `classes` for CSS toggling
- Keep controllers under 50 lines — if longer, split into two controllers

---

## 5. Views and Partials

### Partials for Components

Render collections with partials:

```erb
<%= render @cards %>
<%# Renders app/views/cards/_card.html.erb for each card %>
```

### Jbuilder for JSON

Use Jbuilder for JSON responses, inlining where possible:

```ruby
# app/views/cards/show.json.jbuilder
json.steps @card.steps, partial: "steps/step", as: :step
```

### No Explicit Render When Convention Suffices

If the view matches the action name, don't call `render`:

```ruby
# Rails will render show.html.erb automatically
def show
end
```

---

## 6. CSS

### Layer-Based CSS Organization

Fizzy uses CSS layers and custom properties. No Tailwind, no CSS-in-JS:

```css
@layer base, components, utilities;

@layer components {
  .card {
    padding: var(--space-3);
    border-radius: var(--radius-md);
  }
}
```

### OKLCH Color System

Fizzy uses OKLCH for perceptually uniform color spaces with CSS custom properties.

### No CSS Frameworks

Write your own CSS. It's not that much code. Fizzy's entire stylesheet is ~15% of the
codebase and handles everything.

---

## 7. Importmaps and Propshaft

### No Bundler, No Node.js

Use importmaps for JavaScript dependencies and Propshaft for asset pipeline:

```ruby
# config/importmap.rb
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
```

### Vendored JavaScript

When you need a third-party JS library, vendor it:

```
vendor/javascript/
  some_library.js
```

Pin it in the importmap and you're done. No npm, no yarn, no package.json.
