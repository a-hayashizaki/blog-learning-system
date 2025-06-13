# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an AI-powered Blog Learning System designed to help users maintain high-frequency blog posting (2-3 times per week) while continuously improving article quality through AI learning from past performance. The system focuses on coaching and self-compassion experience sharing blogs.

## Technology Stack

- **Framework**: Ruby on Rails 8.0
- **Language**: Ruby
- **Database**: SQLite3
- **Styling**: Tailwind CSS
- **Frontend**: Turbo + Stimulus (Hotwire)
- **Caching**: Solid Cache
- **Background Jobs**: Solid Queue
- **WebSockets**: Solid Cable
- **Asset Pipeline**: Propshaft + Importmap

## Development Commands

```bash
# Install dependencies
bundle install

# Development server
bin/rails server
# or use Procfile.dev for full development setup
bin/dev

# Run tests
bin/rails test
bin/rails test:system

# Database operations  
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
bin/rails db:reset

# Generate new resources
bin/rails generate controller ControllerName
bin/rails generate model ModelName
bin/rails generate migration MigrationName

# Code quality
bundle exec rubocop
bundle exec brakeman

# Console
bin/rails console

# Run background jobs
bin/rails solid_queue:start
```

## Core Architecture

### Main Workflow
```
気づきメモ → AI対話で骨格作成 → 学習済み調整指示適用 → 記事完成
```

### Learning System (Most Critical Feature)
Two-phase learning approach:
- **Phase 1**: Prompt-based learning (simple, immediate implementation)
- **Phase 2**: Vector embedding learning (high precision, future implementation)

### Learning Data Sources
- Self-feedback (5-level rating + comments)
- External reactions from note platform (views, likes, comment count/content)
- Article generation parameters (experience description ratio, tone, structure)

### Key Learning Elements
1. **Experience Description Ratio**: Optimal balance between experience vs theory
2. **Tone Level**: Casual friendliness without being overly polite  
3. **Structure Patterns**: Optimized kishōtenketsu (introduction-development-twist-conclusion)
4. **Theme Optimization**: Coaching vs Self-compassion specific patterns
5. **Engagement Factors**: Elements that drive likes and comments

## Data Models

### Article
- Basic info: title, content, original memo, theme
- Generation parameters: experience ratio, casualness level, structure type  
- Feedback: self-evaluation, external reactions
- note integration: URL, ID, reaction data

### Feedback  
- Unified management of self-feedback and external reactions

### LearningPattern
- Success pattern extraction and effectiveness measurement

## Development Phases

### Phase 1 (MVP): Prompt-based Learning
- Basic workflow construction
- Article generation and storage
- Self-feedback functionality
- Simple statistical analysis and prompt generation

### Phase 2: note API Integration  
- note API implementation
- External reaction data collection and accumulation
- Multi-feedback learning system
- Data visualization dashboard

### Phase 3: Advanced Features
- Vector embedding learning
- Prediction models (expected view counts)
- Trend analysis
- Advanced optimization algorithms

## Current File Structure

```
/app/                     # Rails MVC architecture
  ├── controllers/        # Request handling and business logic
  ├── models/            # Data models and Active Record classes
  ├── views/             # ERB templates and layouts
  ├── jobs/              # Background job classes
  ├── mailers/           # Email handling
  ├── helpers/           # View helper methods
  ├── assets/            # CSS, JavaScript, images
  └── javascript/        # Stimulus controllers and JS modules
/config/                 # Application configuration
  ├── environments/      # Environment-specific settings
  ├── initializers/      # Initialization code
  └── routes.rb          # URL routing configuration
/db/                     # Database files and schemas
/lib/                    # Custom libraries and extensions
/test/                   # Test files (controllers, models, system tests)
/public/                 # Static files served directly by web server
```

## Development Notes

- Focus on the learning system as the core differentiator
- Target typical manual adjustment patterns user currently uses:
  - "Add more personal experience for better empathy"
  - "Keep language casual, not overly polite" 
  - "Output in blog format, not conversational"
- Prioritize data persistence for multi-year learning accumulation
- Design for local deployment (personal use)

## Technical Configuration

- **Rails Version**: 8.0 with modern defaults enabled
- **Database**: SQLite3 for development/test, configurable for production
- **Asset Pipeline**: Propshaft for asset compilation, Importmap for JavaScript modules
- **CSS Framework**: Tailwind CSS integrated via tailwindcss-rails gem
- **Frontend Stack**: Turbo for SPA-like navigation, Stimulus for JavaScript sprinkles
- **Background Processing**: Solid Queue for job processing
- **Caching**: Solid Cache for Rails.cache backend
- **WebSockets**: Solid Cable for Action Cable
- **Development Server**: Runs on `http://localhost:3000` by default
- **Code Quality**: RuboCop with Rails Omakase styling, Brakeman for security analysis