# Setup Guide

## Prerequisites

- Node.js 18+ and npm
- Flutter 3.10+ and Dart
- PostgreSQL 14+
- Git
- VS Code or similar IDE

## Environment Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd ambient_ai_scribe
```

### 2. Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your configuration

# Set up database
npx prisma generate
npx prisma db push

# Start development server
npm run start:dev
```

### 3. Mobile App Setup

```bash
cd mobile_app

# Install dependencies
flutter pub get

# Check Flutter setup
flutter doctor

# Run the app
flutter run
```

### 4. Database Setup

#### Using Local PostgreSQL

1. Install PostgreSQL on your system
2. Create a database:
   ```sql
   CREATE DATABASE ambient_ai_scribe;
   ```
3. Update your `.env` file with the database URL

#### Using Docker

```bash
docker-compose up -d postgres
```

## Configuration

### Backend Environment Variables

```env
DATABASE_URL="postgresql://username:password@localhost:5432/ambient_ai_scribe?schema=public"
JWT_SECRET="your-super-secret-jwt-key"
JWT_EXPIRES_IN="7d"
PORT=3000
NODE_ENV=development
FRONTEND_URL=http://localhost:3000
```

### Mobile App Configuration

Update `lib/core/constants/app_constants.dart` with your API endpoints:

```dart
class AppConstants {
  static const String apiBaseUrl = 'http://localhost:3000';
  static const String wsUrl = 'ws://localhost:3000';
  // ...
}
```

## Running the Application

### Development Mode

1. Start the backend:
   ```bash
   cd backend && npm run start:dev
   ```

2. Start the mobile app:
   ```bash
   cd mobile_app && flutter run
   ```

### Using Docker

```bash
docker-compose up -d
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 3000 (backend) and your Flutter debug port are available
2. **Database connection**: Verify PostgreSQL is running and credentials are correct
3. **Flutter dependencies**: Run `flutter clean && flutter pub get`
4. **Node modules**: Delete `node_modules` and run `npm install` again

### Getting Help

- Check the logs in the terminal for detailed error messages
- Refer to the [API Documentation](api_overview.md)
- Open an issue in the project repository
