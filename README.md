# Roomies

Roomies is a Ruby on Rails application for finding rooms and compatible roommates.

The platform allows visitors to browse available rooms and neighborhoods. Members can act as hosts by publishing rooms or as seekers by applying to listings, scheduling visits, saving listings, and reviewing properties.

This repository contains the implementation for **Assignment 2 — Rails Application, Models, and Read-Only Views** of Web Technologies.

## Technologies

- Ruby 4.0.4
- Ruby on Rails 8.0.5.1
- PostgreSQL
- Bootstrap
- Sass
- Node.js
- Yarn

## Features

The current version includes:

- Rails application configured with PostgreSQL
- Bootstrap integrated through `cssbundling-rails`
- Responsive layout with shared navbar and footer
- Landing page available at the root route
- Complete domain model implemented with Active Record
- Database foreign keys, unique indexes, and constraints
- Model validations
- Rails enums for lifecycle states
- Reusable listing card partial
- Realistic seed data
- Read-only `index` and `show` pages for:
  - Listings
  - Properties
  - Neighborhoods
  - Applications

### Listing lifecycle

Listings can have the following states:

- `draft`
- `published`
- `reserved`
- `rented`
- `withdrawn`

### Application lifecycle

Applications can have the following states:

- `pending`
- `shortlisted`
- `accepted`
- `rejected`
- `withdrawn`

### Visit lifecycle

Visits can have the following states:

- `proposed`
- `confirmed`
- `cancelled`
- `completed`

## Setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd webtech-roomies
```

### 2. Install Ruby dependencies

```bash
bundle install
```

### 3. Install JavaScript dependencies

```bash
yarn install
```

## PostgreSQL configuration

Roomies uses PostgreSQL in development and test.

The database connection can be configured using environment variables:

| Variable | Description | Default |
|---|---|---|
| `DB_HOST` | PostgreSQL host | `127.0.0.1` |
| `DB_PORT` | PostgreSQL port | `5432` |
| `DB_USER` | PostgreSQL user | `postgres` |
| `ROOMIES_DB_PASSWORD` | PostgreSQL password | Required |

Example in Git Bash:

```bash
export ROOMIES_DB_PASSWORD="your_postgresql_password"
```

If PostgreSQL is running on a different port:

```bash
export DB_PORT=5433
```

## Database setup

Create the databases:

```bash
ruby bin/rails db:create
```

Run the migrations:

```bash
ruby bin/rails db:migrate
```

Populate the database:

```bash
ruby bin/rails db:seed
```

The seed file creates realistic sample data including:

- Users
- Neighborhoods
- Amenities
- Properties
- Listings
- Applications in different states
- Competing applications for the same listing
- Visits in different states
- A completed visit with a review
- Saved listings
- Reports

The application can therefore be browsed immediately after running the seeds.

## Running the application

Start the Rails application with:

```bash
bin/dev
```

On Windows, use **Git Bash**:

```bash
./bin/dev
```

Then open:

```text
http://localhost:3000
```

If PostgreSQL uses a non-default port, environment variables can also be supplied directly:

```bash
DB_PORT=5433 ROOMIES_DB_PASSWORD="your_postgresql_password" ./bin/dev
```

## Main routes

| Route | Description |
|---|---|
| `/` | Roomies landing page |
| `/listings` | Published room listings |
| `/listings/:id` | Listing details |
| `/properties` | Properties |
| `/properties/:id` | Property details |
| `/neighborhoods` | Neighborhoods |
| `/neighborhoods/:id` | Neighborhood details |
| `/applications` | Applications |
| `/applications/:id` | Application details |

All pages in Assignment 2 are read-only. The application does not provide UI actions for creating, editing, or deleting records yet.

## Domain model

The updated domain model is located at:

```text
docs/domain-model.png
```

The main entities are:

- User
- Neighborhood
- Amenity
- Property
- PropertyAmenity
- Listing
- Application
- Visit
- Review
- SavedListing
- Report

### Changes from Assignment 1

A few implementation details were adjusted when translating the conceptual model into Rails:

- `properties_amenities` was implemented as the `PropertyAmenity` model using the Rails table name `property_amenities`.
- Join models use Rails-generated primary keys and timestamps.
- Lifecycle states are implemented using Rails enums backed by integer columns.
- `host_id`, `seeker_id`, and `reporter_id` reference the `users` table.
- Composite unique indexes are used to enforce domain rules such as:
  - A user cannot save the same listing twice.
  - A seeker cannot apply to the same listing twice.
  - An amenity cannot be attached to the same property twice.
- A review belongs to a visit, with only one review allowed per visit.

## Main model rules

Some of the implemented validations include:

- Required attributes cannot be blank.
- Emails and catalog names must be unique where appropriate.
- Rent and deposit values must be valid numerical values.
- Minimum and intended stays must be positive integers.
- Review ratings must be between 1 and 5.
- Listing availability dates cannot be in the past.
- Visits must be scheduled after their application was created.
- A seeker cannot apply to their own listing.
- Applications can only initially be made to published listings.
- Reviews require a completed visit.

## Scopes

The application includes scopes for common queries such as:

- Published listings
- Listings available from a given date
- Listings under a maximum rent
- Applications pending an answer

## Project structure

Important files include:

```text
app/models/                 Domain models and validations
app/controllers/            Read-only controllers
app/views/                  ERB views
db/migrate/                 Database migrations
db/seeds.rb                 Seed data
docs/domain-model.png       Updated domain model
config/routes.rb            Application routes
README.md                   Setup and project documentation
```

## Assignment scope

Assignment 2 focuses on:

- Rails application setup
- PostgreSQL
- Models and migrations
- Active Record relationships
- Validations
- Enums and scopes
- Seed data
- Read-only controllers and views
- Bootstrap layout and reusable partials

Create, edit, update, and delete functionality through the interface is intentionally left for later assignments.