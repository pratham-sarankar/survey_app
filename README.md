# Survey App

A comprehensive mobile application for conducting property surveys, built with Flutter and Node.js backend.

## Features

### 🔐 Authentication & Authorization
- User registration and login with username/password
- Role-based access control (Admin/User)
- JWT-based authentication
- Demo credentials included for testing

### 📝 Survey Management
- Create, view, edit, and delete survey entries
- Comprehensive survey form with validation
- Role-based entry visibility (Admin sees all, Users see their own)
- Real-time data synchronization

### 📍 Location Integration
- GPS location capture for surveys
- Interactive Google Maps integration
- Manual location editing with map tap
- Latitude/longitude validation

### 📸 Image Management
- Multiple image capture from camera or gallery
- Image preview and removal functionality
- Optimized image handling

### 🎯 Property Status Tracking
- Owner Changed
- New Property
- Extended
- Demolished

### 📱 Mobile-First Design
- Material Design 3 UI
- Responsive layouts
- Drawer navigation
- Pull-to-refresh functionality
- Loading states and error handling

## Technology Stack

### Frontend (Flutter)
- **Flutter**: Cross-platform mobile framework
- **Provider**: State management
- **get_it**: Dependency injection
- **Google Maps**: Location services and mapping
- **Image Picker**: Camera and gallery integration
- **Geolocator**: GPS location services
- **HTTP**: API communication

### Backend (Node.js)
- **Express.js**: Web framework
- **MariaDB/MySQL**: Database
- **JWT**: Authentication
- **bcrypt**: Password hashing
- **Helmet**: Security middleware
- **CORS**: Cross-origin resource sharing
- **Rate limiting**: API protection

## Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Node.js (16+)
- MariaDB/MySQL (8+)
- Android Studio / Xcode for mobile development

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Setup database:**
   - Create a MariaDB database named `survey_app`
   - Copy `.env.example` to `.env` and configure your database credentials

4. **Start the server:**
   ```bash
   # Development mode
   npm run dev
   
   # Production mode
   npm start
   ```

### Frontend Setup

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate model files:**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

3. **Configure Google Maps API:**
   - Get a Google Maps API key
   - Add it to `android/app/src/main/AndroidManifest.xml`
   - Add it to `ios/Runner/AppDelegate.swift`
   - Update `lib/config/app_config.dart`

4. **Run the app:**
   ```bash
   flutter run
   ```

## Demo Credentials

For testing purposes, use these credentials:

**Admin Account:**
- Username: `admin`
- Password: `admin`

**User Account:**
- Username: `user`
- Password: `user`

## API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/verify` - Token verification

### Survey Entries
- `GET /api/surveys` - Get all entries (Admin only)
- `GET /api/surveys/user/:userId` - Get user's entries
- `GET /api/surveys/:id` - Get specific entry
- `POST /api/surveys` - Create new entry
- `PUT /api/surveys/:id` - Update entry
- `DELETE /api/surveys/:id` - Delete entry

## Database Schema

### Users Table
```sql
CREATE TABLE users (
  id VARCHAR(255) PRIMARY KEY,
  username VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin', 'user') DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Survey Entries Table
```sql
CREATE TABLE survey_entries (
  id VARCHAR(255) PRIMARY KEY,
  uid VARCHAR(255) NOT NULL,
  area_code VARCHAR(255) NOT NULL,
  qr_plate_house_number VARCHAR(255) NOT NULL,
  owner_name_hindi VARCHAR(255) NOT NULL,
  owner_name_english VARCHAR(255) NOT NULL,
  mobile_number VARCHAR(20) NOT NULL,
  whatsapp_number VARCHAR(20) NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  notes TEXT,
  property_status ENUM('owner_changed', 'new_property', 'extended', 'demolished'),
  images JSON,
  user_id VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

## Project Structure

```
survey_app/
├── lib/
│   ├── config/          # App configuration
│   ├── models/          # Data models
│   ├── providers/       # State management
│   ├── screens/         # UI screens
│   ├── services/        # API and business logic
│   ├── utils/           # Utility functions
│   ├── widgets/         # Reusable widgets
│   └── main.dart        # App entry point
├── backend/
│   ├── src/
│   │   ├── config/      # Database configuration
│   │   ├── middleware/  # Express middleware
│   │   ├── routes/      # API routes
│   │   └── server.js    # Server entry point
│   └── package.json
├── android/            # Android platform files
├── ios/               # iOS platform files
└── pubspec.yaml       # Flutter dependencies
```

## Security Features

- Password hashing with bcrypt
- JWT token-based authentication
- Role-based access control
- Input validation and sanitization
- Rate limiting
- CORS configuration
- SQL injection prevention
- Security headers with Helmet.js

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions, please open an issue in the GitHub repository.
