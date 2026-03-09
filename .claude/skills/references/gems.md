# Gems Reference — DHH Rails Style

## Decision Framework

Before adding a gem, ask:

1. **Can Rails do this out of the box?** If yes, use Rails. Always.
2. **Is this a 37signals gem?** If yes, it's likely a good fit.
3. **Does this gem introduce a competing philosophy?** If yes, don't use it.
4. **Is this gem well-maintained and focused?** Prefer small, focused gems.
5. **Could I write this in under 100 lines?** If yes, write it yourself.

## Use These (37signals / Rails Ecosystem)

| Need | Use | Instead of |
|------|-----|------------|
| Background jobs | Solid Queue | Sidekiq, Resque |
| Caching | Solid Cache | Redis, Memcached |
| WebSockets | Solid Cable | Redis adapter |
| Rich text | Action Text | Trix alternatives |
| File uploads | Active Storage | Shrine, CarrierWave |
| Email | Action Mailer | SendGrid gem |
| Asset pipeline | Propshaft | Sprockets, Webpacker |
| JS modules | Importmaps | Webpack, esbuild, Vite |
| Deployment | Kamal | Capistrano, Heroku |
| Auth (basic) | Rails built-in `has_secure_password` / custom | Devise |
| Auth (sessions) | Custom with `Current` | Devise, Warden |
| CSS | Write your own | Tailwind, Bootstrap |
| Testing | Minitest + fixtures | RSpec + FactoryBot |
| Pagination | Custom or Pagy | Kaminari, will_paginate |
| Search | Database queries / LIKE / FTS | Elasticsearch, Algolia |
| State machines | State-as-records pattern | AASM, statesman |
| Authorization | Model methods | Pundit, CanCanCan |
| Serialization | Jbuilder | ActiveModelSerializers, Blueprinter |
| HTTP client | Net::HTTP or `httpx` | Faraday, HTTParty |

## Avoid These

| Gem/Pattern | Why |
|-------------|-----|
| **Devise** | Over-engineered for most apps. Write auth yourself with `has_secure_password` or magic links |
| **RSpec** | Competing testing philosophy. Use Minitest |
| **FactoryBot** | Slow, hides data issues. Use fixtures |
| **dry-rb** | Competing philosophy (functional over OOP) |
| **Trailblazer** | Adds layers Rails doesn't need |
| **Pundit/CanCanCan** | Authorization belongs in models |
| **ActiveModelSerializers** | Use Jbuilder |
| **Webpacker/Vite** | Use importmaps + Propshaft |
| **Tailwind** | Write your own CSS |
| **AASM/statesman** | Use state-as-records pattern |
| **Interactors** | Use model methods and concerns |
| **Sorbet/steep** | Type checking adds ceremony Rails doesn't need |

## When a Gem Is Justified

Some things genuinely warrant a gem:

- **Database drivers** (pg, mysql2, sqlite3)
- **Image processing** (image_processing, vips)
- **PDF generation** (prawn, wicked_pdf)
- **Payment processing** (stripe)
- **OAuth** (omniauth, when you need SSO)
- **Web push** (web-push)
- **Markdown** (redcarpet, commonmarker)

The test: does this gem solve a genuinely hard problem that would take thousands of
lines to replicate? If yes, use it. If it's just organizing your own code differently,
write your own code.
