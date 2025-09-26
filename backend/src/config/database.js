const mysql = require('mysql2/promise');

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'survey_app',
  port: process.env.DB_PORT || 3306,
  charset: 'utf8mb4',
  connectionLimit: 10,
  acquireTimeout: 60000,
  timeout: 60000,
};

// Create connection pool
const pool = mysql.createPool(dbConfig);

// Test database connection
async function testConnection() {
  try {
    const connection = await pool.getConnection();
    console.log('Database connected successfully');
    connection.release();
  } catch (error) {
    console.error('Database connection failed:', error.message);
  }
}

// Initialize database tables
async function initializeTables() {
  try {
    const connection = await pool.getConnection();
    
    // Create users table
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(255) PRIMARY KEY,
        username VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        role ENUM('admin', 'user') DEFAULT 'user',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    `);

    // Create survey_entries table
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS survey_entries (
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
      )
    `);

    console.log('Database tables initialized successfully');
    connection.release();
  } catch (error) {
    console.error('Error initializing database tables:', error.message);
  }
}

// Initialize on module load
testConnection();
initializeTables();

module.exports = pool;