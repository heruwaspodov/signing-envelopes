# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is **Mekari Sign Backend** - a Ruby on Rails application that provides digital signature and document management services. It's designed as a DocuSign-like platform with extensive approval workflows, digital stamping (meterai), and integration capabilities.

## Commands

### Development Setup
```bash
# Install dependencies
bundle install

# Database setup
bundle exec rails db:setup

# Run the application
bundle exec rails server
```

### Testing
```bash
# Run all tests (serial)
bundle exec rake spec

# Run tests in parallel (faster)
RAILS_ENV=test bundle exec rake parallel:setup
RAILS_ENV=test bundle exec rake parallel:spec

# Generate test coverage
open coverage/index.html
```

### Code Quality
```bash
# Lint code with RuboCop
bundle exec rubocop -A

# Security analysis
brakeman

# Generate API documentation
RAILS_ENV=test rails rswag

# Generate ERD
rails erd
```

### Database
```bash
# Database migration
bundle exec rails db:migrate

# Database rollback
bundle exec rails db:rollback

# Database seeds
bundle exec rails db:seed
```

## Architecture

### Core Domain Structure

**Document Management**
- `Envelope` - Main document entity with complex state management
- `EnvelopeRecipient` - Handles signers and annotation workflow
- `Template` - Reusable document templates
- `Folder` - Hierarchical document organization

**Approval System**
- `ApprovalWorkflow` - Multi-stage approval processes
- `ApprovalForm` - Form-based approval requests
- `ApprovalRequest` - Individual approval instances
- Layered approval system with complex routing

**User & Company Management**
- `User` - Central user entity with Devise authentication
- `Company` - Multi-tenant organization structure
- `Workspace` - Team collaboration spaces
- `UserCompany` - Role-based user-company relationships

**Digital Signatures & Compliance**
- `UserSignature` - Digital signature management
- `CompanyStamp` - Company seal/stamp management
- `TilakaSigning` - PKI integration with Tilaka provider
- `EnvelopeMeterai` - Indonesian stamp duty compliance
- `IdentityVerification` - KYC/identity verification

### Service Layer Architecture

Services are organized by domain in `app/services/`:
- **Business Logic**: `envelopes/`, `approval_workflows/`, `approval_requests/`
- **Document Processing**: `attachments/`, `document_extractions/`, `meterais/`
- **User Management**: `auth/`, `user_managements/`, `access_requests/`
- **Integration**: `tilaka/`, `public/`, `integrations/`, `vida/`
- **Analytics**: `dashboard_insight/`, `audit_trails/`, `quota_usages/`
- **Communication**: `whatsapp/`, `fcm/`, `webhooks/`
- **Teams & Collaboration**: `teams/`, `envelope_shares/`, `contact_groups/`

All services follow the command pattern with `ApplicationService` base class and `call` method.

### Background Jobs Architecture

Uses **Sidekiq** with organized job categories in `app/workers/`:
- **Scheduler**: `scheduler/` - Cron-based recurring jobs
- **Document Processing**: `envelopes/`, `peruri/` - Document operations
- **User Management**: `user_managements/` - User operations
- **Analytics**: `insight/`, `counter/` - Data processing
- **Notifications**: `notifications/`, `reminders/` - Alert delivery
- **Integration**: `tilaka/`, `webhooks/` - External service integration

### API Structure

**Two-tier API Architecture:**
- **Private API**: `/api/v1/` - Internal application API with user authentication
- **Public API**: `/public/api/v1/` - External client API with HMAC authentication

**Authentication:**
- Private API: Bearer token authentication
- Public API: HMAC/OAuth2 for external clients
- Encryption-based access for public documents

### Controller Organization

Controllers are organized by feature domain with extensive use of concerns:
- **Authentication**: `ApiPermission`, `OwnerPermission`, `ClientAuthsHandler`
- **Business Logic**: `Stampable`, `Trailable`, `ApprovalPermissionConcern`
- **Response Handling**: `Response`, `ExceptionHandler`, `RateLimitHandler`

### Database Patterns

**Multi-tenancy**: Company-based with workspace sub-organization
**State Management**: Complex enums for document/approval states
**Performance**: Counter caches for expensive aggregations
**Compliance**: Comprehensive audit trails via `Audited` gem

## Key Integrations

- **Tilaka PKI**: Digital certificate provider for PKI-based signatures
- **Vida**: Alternative PKI provider for digital signatures
- **Meterai (Peruri)**: Indonesian stamp duty system for legal compliance
- **Mekari SSO**: Single sign-on integration with Mekari ecosystem
- **WhatsApp API**: Notification delivery via WhatsApp
- **FCM (Firebase)**: Push notifications for mobile apps
- **AWS S3**: Primary document storage
- **Aliyun OSS**: Alternative storage provider
- **Gotenberg**: PDF conversion service

## Development Guidelines

### Code Structure
- Use service objects for business logic
- Implement concerns for shared functionality
- Follow Rails conventions for MVC separation
- Use Strong Parameters for controller inputs

### Testing
- Write comprehensive specs for all services
- Use FactoryBot for test data generation
- Mock external API calls with WebMock
- Maintain test coverage above 90%

### Security
- All external inputs must be sanitized
- Use Pundit for authorization
- Implement rate limiting for public APIs
- Log all security-relevant events

### Performance
- Use counter caches for expensive counts
- Implement database indexing for queries
- Use background jobs for heavy operations
- Monitor with Datadog metrics

## Environment Configuration

**Required Environment Variables:**
- `RAILS_ENV`, `SECRET_KEY_BASE`
- Database: `MEKARI_SIGN_DATABASE_*`
- AWS: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- SMTP: `SMTP_*` configuration
- Redis: `REDIS_URL`
- Monitoring: `SENTRY_DNS`, `DATADOG_*`

## Testing Framework

**RSpec** with comprehensive testing setup:
- **Parallel Testing**: Use `parallel_tests` gem for faster test execution
- **Factories**: FactoryBot for test data generation
- **Mocking**: WebMock for external API calls
- **Coverage**: SimpleCov for test coverage tracking
- **Database**: Database cleaner for test isolation

### Running Tests
```bash
# Parallel test setup (faster)
RAILS_ENV=test bundle exec rake parallel:setup
RAILS_ENV=test bundle exec rake parallel:spec

# Single process tests
bundle exec rake spec

# Specific test file
bundle exec rspec spec/models/envelope_spec.rb
```

## Deployment

- **Docker**: Multi-stage builds with base image
- **Kubernetes**: Helm charts for different environments
- **CI/CD**: Bitbucket Pipelines with environment promotion
- **Monitoring**: Datadog, Sentry, and custom health checks

## Important Notes

- This is a compliance-heavy application with audit requirements
- Document states follow complex business rules
- Multi-tenant architecture requires careful scoping
- All document operations must maintain audit trails
- External integrations have specific error handling patterns

## Common Development Patterns

### Service Object Pattern
```ruby
# All services inherit from ApplicationService
class MyService < ApplicationService
  def call
    # Business logic here
  end
end

# Usage
result = MyService.call(params)
```

### Error Handling
- Use custom exceptions in `lib/esign_exceptions/`
- Implement circuit breakers for external APIs
- Log errors with structured data for monitoring

### Database Queries
- Use `ransack` gem for complex search queries
- Implement pagination with `kaminari`
- Use counter caches for expensive aggregations
- Scope queries by company/workspace for multi-tenancy

### API Development
- Use `jsonapi-serializer` for API responses
- Implement proper authentication and authorization
- Use `rails_param` for parameter validation
- Document APIs with `rswag` for OpenAPI spec