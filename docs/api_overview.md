# API Overview

## Base URL

```
Development: http://localhost:3000/api
Production: https://your-domain.com/api
```

## Authentication

All API endpoints (except health check and login) require JWT authentication.

### Headers
```
Authorization: Bearer <jwt-token>
Content-Type: application/json
```

## Endpoints

### Health Check

#### GET /health
Check API health status.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "service": "ambient-ai-scribe-api"
}
```

### Authentication

#### POST /auth/login
Authenticate user and receive JWT token.

**Request:**
```json
{
  "email": "doctor@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user123",
    "email": "doctor@example.com",
    "name": "Dr. John Doe"
  }
}
```

### Consultations

#### GET /consultations
Get list of consultations for the authenticated user.

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)
- `status` (optional): Filter by status

**Response:**
```json
{
  "data": [
    {
      "id": "consultation123",
      "patientId": "patient123",
      "status": "completed",
      "startTime": "2024-01-01T10:00:00.000Z",
      "endTime": "2024-01-01T10:30:00.000Z",
      "patient": {
        "id": "patient123",
        "name": "Jane Smith"
      }
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1
  }
}
```

#### POST /consultations
Create a new consultation.

**Request:**
```json
{
  "patientId": "patient123"
}
```

**Response:**
```json
{
  "id": "consultation123",
  "userId": "user123",
  "patientId": "patient123",
  "status": "not_started",
  "createdAt": "2024-01-01T10:00:00.000Z"
}
```

#### GET /consultations/:id
Get consultation details.

**Response:**
```json
{
  "id": "consultation123",
  "userId": "user123",
  "patientId": "patient123",
  "status": "in_progress",
  "startTime": "2024-01-01T10:00:00.000Z",
  "patient": {
    "id": "patient123",
    "name": "Jane Smith",
    "dateOfBirth": "1990-01-01",
    "gender": "F"
  }
}
```

### Transcription

#### GET /consultations/:id/transcript
Get consultation transcript.

**Response:**
```json
{
  "consultationId": "consultation123",
  "turns": [
    {
      "id": "turn123",
      "speaker": "doctor",
      "text": "Hello, how are you feeling today?",
      "timestamp": "2024-01-01T10:01:00.000Z",
      "confidence": 0.95
    },
    {
      "id": "turn124",
      "speaker": "patient",
      "text": "I've been having headaches for the past week.",
      "timestamp": "2024-01-01T10:01:30.000Z",
      "confidence": 0.92
    }
  ]
}
```

### SOAP Notes

#### GET /consultations/:id/soap
Get SOAP note for consultation.

**Response:**
```json
{
  "id": "soap123",
  "consultationId": "consultation123",
  "subjective": "Patient reports headaches for the past week...",
  "objective": "Patient appears alert and oriented...",
  "assessment": "Tension headache, likely stress-related...",
  "plan": "Recommend pain management and stress reduction..."
}
```

#### POST /consultations/:id/soap
Generate or update SOAP note.

**Request:**
```json
{
  "subjective": "Patient reports headaches for the past week...",
  "objective": "Patient appears alert and oriented...",
  "assessment": "Tension headache, likely stress-related...",
  "plan": "Recommend pain management and stress reduction..."
}
```

### Prescriptions

#### GET /consultations/:id/prescriptions
Get prescriptions for consultation.

**Response:**
```json
{
  "data": [
    {
      "id": "prescription123",
      "medication": "Ibuprofen",
      "dosage": "400mg",
      "frequency": "Every 6 hours as needed",
      "duration": "7 days",
      "instructions": "Take with food"
    }
  ]
}
```

#### POST /consultations/:id/prescriptions
Create new prescription.

**Request:**
```json
{
  "medication": "Ibuprofen",
  "dosage": "400mg",
  "frequency": "Every 6 hours as needed",
  "duration": "7 days",
  "instructions": "Take with food"
}
```

### Referrals

#### GET /consultations/:id/referrals
Get referrals for consultation.

**Response:**
```json
{
  "data": [
    {
      "id": "referral123",
      "toProvider": "Dr. Smith Neurology",
      "toSpecialty": "Neurology",
      "reason": "Persistent headaches requiring neurological evaluation",
      "urgency": "routine"
    }
  ]
}
```

#### POST /consultations/:id/referrals
Create new referral.

**Request:**
```json
{
  "toProvider": "Dr. Smith Neurology",
  "toSpecialty": "Neurology",
  "reason": "Persistent headaches requiring neurological evaluation",
  "urgency": "routine"
}
```

### FHIR Export

#### GET /consultations/:id/fhir
Get FHIR bundle for consultation.

**Response:**
```json
{
  "id": "fhir123",
  "consultationId": "consultation123",
  "bundleData": {
    "resourceType": "Bundle",
    "type": "document",
    "entry": [
      {
        "fullUrl": "urn:uuid:patient123",
        "resource": {
          "resourceType": "Patient",
          "id": "patient123"
        }
      }
    ]
  }
}
```

## WebSocket Events

### Connection
Connect to WebSocket at `ws://localhost:3000`

### Events

#### consultation:join
Join a consultation room for real-time updates.

**Payload:**
```json
{
  "consultationId": "consultation123",
  "token": "jwt-token"
}
```

#### transcript:turn
New transcript turn received.

**Payload:**
```json
{
  "consultationId": "consultation123",
  "turn": {
    "id": "turn123",
    "speaker": "doctor",
    "text": "Hello, how are you feeling today?",
    "timestamp": "2024-01-01T10:01:00.000Z",
    "confidence": 0.95
  }
}
```

#### consultation:status
Consultation status update.

**Payload:**
```json
{
  "consultationId": "consultation123",
  "status": "in_progress",
  "timestamp": "2024-01-01T10:00:00.000Z"
}
```

## Error Responses

All endpoints return error responses in the following format:

```json
{
  "statusCode": 400,
  "message": "Bad Request",
  "error": "Invalid input data"
}
```

### Common Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

## Rate Limiting

API endpoints are rate-limited to prevent abuse:
- 100 requests per minute per authenticated user
- 10 requests per minute for unauthenticated endpoints

## Data Validation

All input data is validated using class-validator decorators. Invalid data will result in a 400 Bad Request response with detailed error information.
