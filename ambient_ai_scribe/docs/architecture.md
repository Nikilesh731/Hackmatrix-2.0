# Architecture Overview

## System Architecture

The Ambient AI Scribe follows a modular, scalable architecture with clear separation of concerns.

## High-Level Components

### Frontend (Flutter Mobile App)
- **Framework**: Flutter 3.10+
- **Language**: Dart
- **Architecture**: Feature-based modular structure
- **State Management**: Provider pattern
- **Real-time Communication**: WebSocket connections

### Backend (NestJS API)
- **Framework**: NestJS 10+
- **Language**: TypeScript
- **Database**: PostgreSQL with Prisma ORM
- **Real-time**: Socket.IO for WebSocket connections
- **Authentication**: JWT-based auth

### Shared Contracts
- **Format**: JSON Schema definitions
- **Purpose**: Type safety across frontend/backend
- **Location**: `shared_contracts/` directory

## Data Flow

```
Mobile App (Flutter) ←→ WebSocket ←→ NestJS Backend ←→ PostgreSQL Database
                      ↓
                   AI Services (Transcription, NLP)
```

## Module Structure

### Frontend Modules

#### Core Layer
- `core/constants/` - App-wide constants
- `core/services/` - API, WebSocket, Audio services
- `core/models/` - Data models
- `core/widgets/` - Reusable UI components

#### Feature Modules
- `features/auth/` - Authentication
- `features/dashboard/` - Main dashboard
- `features/consultation/` - Live consultation features
- `features/post_consultation/` - Review and documentation
- `features/patients/` - Patient management

#### Shared Layer
- `shared/enums/` - Common enumerations
- `shared/helpers/` - Utility functions

### Backend Modules

#### Core Modules
- `config/` - Database and environment configuration
- `common/` - Shared utilities and constants

#### Feature Modules
- `health/` - Health check endpoints
- `auth/` - Authentication and authorization
- `consultations/` - Consultation management
- `transcription/` - Real-time transcription
- `soap/` - SOAP note generation
- `prescriptions/` - Prescription management
- `referrals/` - Referral generation
- `fhir/` - FHIR data export

#### WebSocket Module
- `websocket/` - Real-time communication

## Database Schema

### Core Entities
- **Users** - Doctor accounts
- **Patients** - Patient information
- **Consultations** - Consultation sessions
- **TranscriptTurns** - Individual speech segments
- **SoapNotes** - Clinical documentation
- **Prescriptions** - Medication prescriptions
- **Referrals** - Medical referrals
- **FhirBundles** - FHIR data exports

## API Design Principles

### RESTful Endpoints
- `GET /api/health` - Health check
- `POST /api/auth/login` - Authentication
- `GET /api/consultations` - List consultations
- `POST /api/consultations` - Create consultation
- `GET /api/consultations/:id/transcript` - Get transcript
- `POST /api/consultations/:id/soap` - Generate SOAP note

### WebSocket Events
- `consultation:join` - Join consultation room
- `transcript:turn` - New transcript turn
- `consultation:status` - Status updates
- `soap:update` - Real-time SOAP updates

## Security Considerations

### Authentication
- JWT tokens with expiration
- Refresh token mechanism
- Secure token storage

### Data Protection
- End-to-end encryption for sensitive data
- GDPR compliance considerations
- HIPAA-aligned data handling

### API Security
- Rate limiting
- Input validation
- CORS configuration

## Scalability Features

### Horizontal Scaling
- Stateless API design
- Database connection pooling
- WebSocket clustering support

### Performance Optimization
- Lazy loading in Flutter
- Database query optimization
- Caching strategies

## Development Guidelines

### Code Organization
- Maximum 300 lines per file
- Single responsibility principle
- Clear naming conventions
- Comprehensive documentation

### Testing Strategy
- Unit tests for business logic
- Integration tests for API endpoints
- Widget tests for Flutter components
- E2E tests for critical user flows

## Deployment Architecture

### Development
- Local development with hot reload
- Docker Compose for local services
- Mock AI services for testing

### Production
- Containerized deployment
- Load balancing
- Database replication
- Monitoring and logging
