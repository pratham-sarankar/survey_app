# Survey App Backend

Node.js backend API for the Survey App with MariaDB database.

## Features

- User authentication (login/register)
- Role-based access control (Admin/User)
- Survey entry CRUD operations
- RESTful API design
- JWT-based authentication
- MariaDB database integration
- Input validation and sanitization
- Error handling middleware
- Security best practices

## Prerequisites

- Node.js (v16 or higher)
- MariaDB or MySQL (v8 or higher)
- npm or yarn

## Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Database setup:**
   - Create a MariaDB database named `survey_app`
   - Copy `.env.example` to `.env` and configure your database credentials

3. **Environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your actual configuration
   ```

4. **Start the server:**
   ```bash
   # Development mode with auto-reload
   npm run dev

   # Production mode
   npm start
   ```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `GET /api/auth/verify` - Verify JWT token

### Survey Entries
- `GET /api/surveys` - Get all entries (Admin only)
- `GET /api/surveys/user/:userId` - Get user's entries
- `GET /api/surveys/:id` - Get specific entry
- `POST /api/surveys` - Create new entry
- `PUT /api/surveys/:id` - Update entry
- `DELETE /api/surveys/:id` - Delete entry

## Database Schema

### Users Table
- `id` (VARCHAR, Primary Key)
- `username` (VARCHAR, Unique)
- `password` (VARCHAR, Hashed)
- `role` (ENUM: 'admin', 'user')
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

### Survey Entries Table
- `id` (VARCHAR, Primary Key)
- `uid` (VARCHAR)
- `area_code` (VARCHAR)
- `qr_plate_house_number` (VARCHAR)
- `owner_name_hindi` (VARCHAR)
- `owner_name_english` (VARCHAR)
- `mobile_number` (VARCHAR)
- `whatsapp_number` (VARCHAR)
- `latitude` (DECIMAL)
- `longitude` (DECIMAL)
- `notes` (TEXT)
- `property_status` (ENUM)
- `images` (JSON)
- `user_id` (VARCHAR, Foreign Key)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

## Security Features

- JWT-based authentication
- Password hashing with bcrypt
- Rate limiting
- CORS configuration
- Input validation and sanitization
- SQL injection prevention
- Helmet.js security headers

## Development

The API automatically creates database tables on startup. For development, use:

```bash
npm run dev
```

This will start the server with nodemon for auto-reloading on code changes.

## Production Deployment

1. Set `NODE_ENV=production` in your environment
2. Configure proper database credentials
3. Use a strong JWT secret
4. Set up proper SSL/HTTPS
5. Configure firewall and security groups
6. Use PM2 or similar for process management

## Testing

Health check endpoint: `GET /health`

Example response:
```json
{
  "status": "OK",
  "timestamp": "2023-XX-XXTXX:XX:XX.XXXZ",
  "version": "1.0.0"
}
```