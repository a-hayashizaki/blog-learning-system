# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an AI-powered Blog Learning System designed to help users maintain high-frequency blog posting (2-3 times per week) while continuously improving article quality through AI learning from past performance. The system focuses on coaching and self-compassion experience sharing blogs.

## Technology Stack

- **Frontend**: React Router 7 with CSR
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Build Tool**: Vite
- **Database**: SQLite with Prisma ORM (planned)
- **AI API**: Gemini API (planned)
- **External API**: note API for blog platform integration (planned)
- **Environment**: Node.js 20

## Development Commands

```bash
# Install dependencies
npm install

# Development server with HMR
npm run dev

# Type checking and generation
npm run typecheck

# Build for production
npm run build

# Start production server
npm start

# Database operations (when Prisma is added)
npx prisma generate
npx prisma db push
npx prisma studio
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
/app/                  # React Router 7 routes and components
  ├── routes/          # Route modules
  ├── root.tsx         # Root layout component
  ├── routes.ts        # Route configuration
  └── app.css          # Global styles
/public/               # Static assets
react-router.config.ts # React Router configuration
vite.config.ts         # Vite build configuration
tsconfig.json          # TypeScript configuration

# To be added:
/lib/                  # Utilities and configurations
/prisma/              # Database schema and migrations
/types/               # TypeScript type definitions
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

- **React Router 7**: File-based routing with SSR enabled by default
- **Path Aliases**: `~/*` maps to `./app/*` for cleaner imports
- **Tailwind CSS**: Integrated via Vite plugin for styling
- **TypeScript**: Strict mode enabled with ES2022 target
- **Development Server**: Runs on `http://localhost:5173`
- **Production Server**: Serves on port 3000 when using `npm start`