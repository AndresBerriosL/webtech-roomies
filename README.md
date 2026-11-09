
# Roomies — Web Technologies

Roomies is a Ruby on Rails 8 web application for finding rooms and managing shared housing.

This repository includes the implementation of **Assignment 4: Authentication, Authorization, JSON API, Dynamic Search and Notifications**.

## Technologies

- Ruby 4.0.4
- Ruby on Rails 8
- PostgreSQL
- Bootstrap 5 and Sass
- JavaScript, Stimulus and Fetch API
- Pundit
- Active Job and Action Mailer

## Features

### Authentication

- User registration and sign-in
- Secure password authentication
- Sign-out
- Password reset through email
- Editable profile: name, contact information and biography

### Authorization

Pundit controls access according to the user's role.

**Visitor**
- Browse published listings
- Search available rooms
- View public neighborhoods and amenities

**Member**
- Create and manage their own properties and listings
- Apply to listings owned by other users
- Manage applications for their own listings
- Propose and manage visits with participants
- Review properties after completed visits
- Report listings

**Moderator**
- Browse private records according to moderation policies
- Manage neighborhoods and amenities
- View and resolve reports
- Edit or delete properties and listings
- Cannot accept applications on behalf of hosts

Sensitive resources use Pundit policies and policy scopes.

### Listings and applications

- Property management
- Draft and published listings
- Applications with pending, shortlisted, accepted, rejected and withdrawn states
- Visit scheduling and status management
- Property reviews
- Listing reports

### Dynamic search

The `/listings` page uses JavaScript Fetch API to search published listings without reloading the page.

Available filters:
- Maximum monthly rent
- Neighborhood
- Furnished or unfurnished

### Versioned JSON API

Base path: `/api/v1`

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/v1/listings` | List published rooms |
| GET | `/api/v1/listings/:id` | Retrieve one published room |

Supported query parameters:

| Parameter | Example |
|---|---|
| `max_rent` | `400000` |
| `neighborhood_id` | `1` |
| `furnished` | `true` or `false` |

Example:

`/api/v1/listings?max_rent=400000&furnished=true`

Successful responses use a `data` field. Listing collections also include `meta.count`.

Invalid filters return HTTP 400. Missing or non-public listings return HTTP 404.

The API excludes user email addresses, passwords and private profile information.

### Email notifications

- Hosts receive notifications when applications are created.
- Seekers receive notifications when their application status changes.
- Password recovery emails include reset links.
- Active Job handles background email delivery.

In development, emails are saved to `tmp/mails` instead of being sent to real addresses.

## Installation

### Requirements

Install Ruby, Bundler, PostgreSQL, Node.js and Yarn.

Clone the project:

```bash
git clone https://github.com/AndresBerriosL/webtech-roomies.git
cd webtech-roomies
```

Install Ruby dependencies:

```bash
bundle install
```

Install JavaScript dependencies and compile CSS.

On Windows PowerShell:

```powershell
yarn.cmd install
yarn.cmd build:css
```

### Database configuration

The project reads these environment variables:

| Variable | Default |
|---|---|
| `DB_HOST` | `127.0.0.1` |
| `DB_PORT` | `5432` |
| `DB_USER` | `postgres` |
| `ROOMIES_DB_PASSWORD` | No default |

Example for PowerShell:

```powershell
$env:DB_PORT = "5433"
$env:ROOMIES_DB_PASSWORD = Read-Host "PostgreSQL password"
```

Create and migrate the database:

```powershell
ruby bin/rails db:create
ruby bin/rails db:migrate
```

For a fresh demonstration database only:

```powershell
ruby bin/rails db:seed
```

**Warning:** the current seed script deletes existing sample records before recreating them. Do not run it against a database containing data you want to keep.

Start the application:

```powershell
ruby bin/rails server
```

Open `http://localhost:3000`.

## Demonstration accounts

The seed script creates sample accounts using this password:

`RoomiesDemo2026!`

| Role | Email |
|---|---|
| Member | `andres@example.com` |
| Member | `sofia@example.com` |
| Member | `matias@example.com` |
| Member | `camila@example.com` |
| Moderator | `moderator@roomies.cl` |

These are development-only credentials. Passwords changed using the reset feature will differ from the seed password.

## Important pages

| Path | Purpose |
|---|---|
| `/` | Public home page |
| `/listings` | Dynamic room search |
| `/properties` | Properties |
| `/applications` | Applications |
| `/neighborhoods` | Neighborhoods |
| `/amenities` | Amenities |
| `/reports` | Moderator report management |
| `/registration/new` | Registration |
| `/session/new` | Sign-in |
| `/passwords/new` | Password recovery |
| `/profile/edit` | Edit profile |

## Automated tests

Run tests on the separate PostgreSQL test database.

In Windows PowerShell, CSS compilation can be skipped when running Ruby tests:

```powershell
$env:SKIP_CSS_BUILD = "1"
ruby bin/rails test
Remove-Item Env:SKIP_CSS_BUILD
```

The authorization suite includes 9 tests and 28 assertions covering roles, properties, applications, visits, reviews, reports and policy scopes.

## Project structure

- `app/models` — Active Record models
- `app/policies` — Pundit authorization policies
- `app/controllers` — Web controllers
- `app/controllers/api/v1` — JSON API
- `app/javascript/controllers` — Stimulus controllers
- `app/mailers` — Email notifications
- `app/views` — HTML and ERB templates
- `db/migrate` — Database migrations
- `db/seeds.rb` — Demonstration data
- `test/policies` — Authorization tests

## Notes

- This project is intended for educational use.
- The development mail adapter writes emails to local files.
- Production deployments require a real email provider and a persistent background job queue.
