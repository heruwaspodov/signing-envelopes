# Mekari Sign (Backend)

## Project Overview

This is the backend for Mekari Sign, a Ruby on Rails application designed to replicate the core functionality of DocuSign. It handles user authentication, document management, signing workflows, and various integrations. The application uses PostgreSQL for its database, Redis for background jobs with Sidekiq, and interfaces with services like AWS S3 for storage and other external APIs for features like e-meterai and KYC.

### Key Technologies:

*   **Backend:** Ruby on Rails
*   **Database:** PostgreSQL
*   **Background Jobs:** Redis & Sidekiq
*   **API Documentation:** Rswag (Swagger)
*   **Testing:** RSpec, FactoryBot, SimpleCov
*   **Linting:** RuboCop
*   **Deployment:** Docker

## Building and Running

### Prerequisites:

*   Ruby (version 3.0.7)
*   Bundler (version 2.3.6)
*   PostgreSQL
*   Docker & Docker Compose
*   ImageMagick

### Setup and Installation:

1.  **Clone the repository:**
    ```bash
    git clone git@bitbucket.org:jurnal/msign-backend.git
    cd msign-backend
    ```

2.  **Install Ruby and Bundler:**
    *   It is recommended to use a version manager like `mise` or `rvm`.
    *   Ensure you have Ruby 3.0.7 and Bundler 2.3.6 installed.

3.  **Install dependencies:**
    ```bash
    bundle install
    ```

4.  **Setup the database:**
    ```bash
    bundle exec rails db:setup
    ```

### Running the Application:

*   **Locally:**
    ```bash
    bundle exec rails server
    ```
    The application will be available at `http://localhost:3001`.

*   **With Docker:**
    ```bash
    docker-compose up -d
    ```

### Running Tests:

*   **Run all tests:**
    ```bash
    bundle exec rake spec
    ```

*   **Run tests in parallel:**
    ```bash
    RAILS_ENV=test bundle exec rake parallel:spec
    ```

### Linting:

*   **Run RuboCop:**
    ```bash
    bundle exec rubocop -A
    ```

## Development Conventions

*   **API Documentation:** The project uses Rswag to generate Swagger API documentation. The documentation can be accessed at `http://localhost:3001/api-docs` when the application is running locally.
*   **Code Style:** The project uses RuboCop to enforce a consistent code style.
*   **Continuous Integration:** The project uses Bitbucket Pipelines for CI/CD.
*   **Git Hooks:** The project uses `overcommit` for managing Git hooks.
