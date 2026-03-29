# Ambient AI Scribe

A mobile-first AI-powered medical scribe application for doctors, featuring real-time transcription, SOAP note generation, and clinical documentation.

## Architecture

- **Frontend**: Flutter mobile app
- **Backend**: NestJS TypeScript API
- **Database**: PostgreSQL with Prisma ORM
- **Real-time**: WebSocket connections
- **Contracts**: Shared JSON schemas for data consistency

## Project Structure

```
ambient_ai_scribe/
├── mobile_app/          # Flutter mobile application
├── backend/             # NestJS TypeScript API
├── shared_contracts/    # JSON schemas and type definitions
├── docs/               # Documentation
├── scripts/            # Development scripts
└── docker-compose.yml  # Development environment
```

## Quick Start

### Prerequisites

- Node.js 18+
- Flutter 3.10+
- PostgreSQL 14+
- Docker (optional)

### Backend Setup

1. Navigate to backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment:
   ```bash
   cp .env.example .env
   # Edit .env with your database configuration
   ```

4. Set up database:
   ```bash
   npx prisma generate
   npx prisma db push
   ```

5. Start development server:
   ```bash
   npm run start:dev
   ```

### Mobile App Setup

1. Navigate to mobile app directory:
   ```bash
   cd mobile_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Docker Setup (Optional)

```bash
docker-compose up -d
```

## Features

- **Real-time Transcription**: Live audio-to-text conversion during consultations
- **SOAP Notes**: Automatic generation of Subjective, Objective, Assessment, Plan notes
- **Prescriptions**: Digital prescription management
- **Referrals**: Electronic referral generation
- **FHIR Integration**: Export clinical data in FHIR format
- **Offline Support**: Core functionality available without internet
- **Secure Storage**: End-to-end encryption for patient data

## Development

### Code Style

- Maximum 300 lines per file
- Modular, reusable components
- No hardcoded medical data
- Generic and flexible architecture

### Testing

```bash
# Backend tests
cd backend && npm test

# Flutter tests
cd mobile_app && flutter test
```

## Documentation

- [Architecture Overview](docs/architecture.md)
- [Setup Guide](docs/setup.md)
- [API Documentation](docs/api_overview.md)

## License

Private project - All rights reserved.
